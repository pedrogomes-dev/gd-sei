-- Executar uma vez em sei_gd após 005. Compatibilidade >=130.
-- Preserva cadastros e vínculos existentes; não instala autenticação por e-mail.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
GO
BEGIN TRY
 BEGIN TRANSACTION;
 IF NOT EXISTS(SELECT 1 FROM dbo.usuario WHERE email='pg@setic.ro.gov.br' AND sin_ativo='S')
  THROW 51200,'Usuario inicial de teste ausente ou inativo.',1;
 IF EXISTS(SELECT LOWER(LTRIM(RTRIM(email))) FROM dbo.usuario
  GROUP BY LOWER(LTRIM(RTRIM(email))) HAVING COUNT(*)>1)
  THROW 51201,'Ha emails duplicados apos normalizacao. Revise antes de instalar.',1;
 ALTER TABLE dbo.usuario ADD nome nvarchar(150) NULL,
  sin_admin char(1) NOT NULL CONSTRAINT DF_usuario_admin DEFAULT 'N'
   CONSTRAINT CK_usuario_admin CHECK(sin_admin IN('S','N')),
  revisao int NOT NULL CONSTRAINT DF_usuario_revisao DEFAULT 0,
  versao_sessao int NOT NULL CONSTRAINT DF_usuario_sessao DEFAULT 0;
 ALTER TABLE dbo.usuario ADD email_normalizado AS LOWER(LTRIM(RTRIM(email))) PERSISTED;
 -- Compila após o ALTER, evitando referência à coluna nova no mesmo batch.
 EXEC sys.sp_executesql N'CREATE UNIQUE INDEX UQ_usuario_email_normalizado ON dbo.usuario(email_normalizado);';
 CREATE TABLE dbo.auditoria_administrativa (
  id_evento bigint IDENTITY PRIMARY KEY,
  data_evento datetime2 NOT NULL DEFAULT SYSUTCDATETIME(),
  id_usuario_responsavel int NOT NULL REFERENCES dbo.usuario(id_usuario),
  id_usuario_alvo int NOT NULL REFERENCES dbo.usuario(id_usuario),
  responsavel_nome nvarchar(150) NULL,
  responsavel_email varchar(250) NOT NULL,
  evento varchar(40) NOT NULL,
  antes nvarchar(max) NULL,
  depois nvarchar(max) NOT NULL,
  CHECK(antes IS NULL OR ISJSON(antes)=1), CHECK(ISJSON(depois)=1)
 );
 CREATE INDEX IX_auditoria_admin_alvo ON dbo.auditoria_administrativa(id_usuario_alvo,id_evento DESC);
 COMMIT;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK;
 THROW;
END CATCH;
GO
CREATE OR ALTER TRIGGER dbo.tr_auditoria_admin_imutavel ON dbo.auditoria_administrativa
INSTEAD OF UPDATE,DELETE AS
BEGIN
 THROW 51202,'Historico administrativo nao pode ser sobrescrito.',1;
END;
GO
-- Bootstrap explícito e auditado do usuário de teste. Não altera seu nome/órgãos.
BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @inicial int,@antes nvarchar(max),@depois nvarchar(max);
 SELECT @inicial=id_usuario FROM dbo.usuario WITH(UPDLOCK,HOLDLOCK)
  WHERE email_normalizado='pg@setic.ro.gov.br' AND sin_ativo='S';
 IF @inicial IS NULL THROW 51200,'Usuario inicial de teste ausente ou inativo.',1;
 SELECT @antes=(SELECT nome,email,sin_ativo,sin_admin,revisao,
  JSON_QUERY((SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@inicial ORDER BY id_orgao FOR JSON PATH)) AS orgaos
  FROM dbo.usuario WHERE id_usuario=@inicial FOR JSON PATH,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
 UPDATE dbo.usuario SET sin_admin='S',revisao=revisao+1,versao_sessao=versao_sessao+1 WHERE id_usuario=@inicial;
 SELECT @depois=(SELECT nome,email,sin_ativo,sin_admin,revisao,
  JSON_QUERY((SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@inicial ORDER BY id_orgao FOR JSON PATH)) AS orgaos
  FROM dbo.usuario WHERE id_usuario=@inicial FOR JSON PATH,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
 INSERT dbo.auditoria_administrativa(id_usuario_responsavel,id_usuario_alvo,responsavel_nome,responsavel_email,evento,antes,depois)
  SELECT @inicial,@inicial,nome,email,'ADMINISTRADOR_INICIAL',@antes,@depois FROM dbo.usuario WHERE id_usuario=@inicial;
 COMMIT;
END TRY
BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
GO
CREATE OR ALTER PROCEDURE dbo.sp_salvar_usuario
 @responsavel int,@id_usuario int,@revisao_esperada int,
 @nome nvarchar(max),@email nvarchar(max),@ativo char(1),@admin char(1),@orgaos nvarchar(max)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 SET ANSI_PADDING ON; SET ANSI_WARNINGS ON; SET ARITHABORT ON;
 SET CONCAT_NULL_YIELDS_NULL ON; SET NUMERIC_ROUNDABORT OFF;
 SET @nome=LTRIM(RTRIM(@nome)); SET @email=LOWER(LTRIM(RTRIM(@email)));
 IF @id_usuario IS NULL OR @id_usuario<0 OR @revisao_esperada IS NULL OR @revisao_esperada<0
  OR @nome IS NULL OR LEN(@nome)=0 OR DATALENGTH(@nome)>300
  OR @email IS NULL OR LEN(@email)=0 OR DATALENGTH(@email)>500
  OR @email LIKE N'%[^ -~]%' COLLATE Latin1_General_BIN2 OR @email LIKE N'% %' OR @email NOT LIKE N'%_@_%._%'
  OR @ativo IS NULL OR @ativo NOT IN('S','N') OR @admin IS NULL OR @admin NOT IN('S','N')
  THROW 51210,'Cadastro invalido.',1;
 IF @orgaos IS NULL OR ISJSON(@orgaos)<>1 OR LEFT(LTRIM(@orgaos),1)<>'['
  THROW 51210,'Lista de orgaos invalida.',1;
 DECLARE @lista TABLE(id_orgao int PRIMARY KEY);
 IF EXISTS(SELECT 1 FROM OPENJSON(@orgaos) WHERE type<>2 OR TRY_CONVERT(int,value) IS NULL
  OR value LIKE '%[.eE]%') OR EXISTS(SELECT value FROM OPENJSON(@orgaos) GROUP BY value HAVING COUNT(*)>1)
  THROW 51210,'Lista de orgaos invalida ou duplicada.',1;
 INSERT @lista SELECT CONVERT(int,value) FROM OPENJSON(@orgaos);
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @lock int,@revisao int,@antes nvarchar(max),@depois nvarchar(max),@revogar bit=0,
   @responsavel_nome nvarchar(150),@responsavel_email varchar(250);
  -- Serializa alterações de perfil e vínculos, inclusive do administrador responsável.
  EXEC @lock=sys.sp_getapplock @Resource='administracao_usuarios',@LockMode='Exclusive',
   @LockOwner='Transaction',@LockTimeout=15000;
  IF @lock<0 THROW 51215,'Administracao ocupada. Tente novamente.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.usuario WITH(UPDLOCK,HOLDLOCK)
   WHERE id_usuario=@responsavel AND sin_ativo='S' AND sin_admin='S')
   THROW 51211,'Administracao nao autorizada.',1;
  SELECT @responsavel_nome=nome,@responsavel_email=email FROM dbo.usuario WHERE id_usuario=@responsavel;
  IF EXISTS(SELECT 1 FROM @lista l WHERE NOT EXISTS(SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=l.id_orgao))
   THROW 51214,'Orgao inexistente.',1;
  IF EXISTS(SELECT 1 FROM dbo.usuario WITH(UPDLOCK,HOLDLOCK)
   WHERE email_normalizado=@email AND id_usuario<>@id_usuario)
   THROW 51213,'Email ja cadastrado.',1;
  IF @id_usuario=0
  BEGIN
   IF @revisao_esperada<>0 THROW 51212,'Revisao invalida para novo usuario.',1;
   INSERT dbo.usuario(nome,email,sin_ativo,sin_admin) VALUES(@nome,CONVERT(varchar(250),@email),@ativo,@admin);
   SET @id_usuario=CONVERT(int,SCOPE_IDENTITY());
  END
  ELSE
  BEGIN
   SELECT @revisao=revisao FROM dbo.usuario WITH(UPDLOCK,HOLDLOCK) WHERE id_usuario=@id_usuario;
   IF @revisao IS NULL THROW 51216,'Usuario inexistente.',1;
   IF @revisao<>@revisao_esperada THROW 51212,'Cadastro alterado. Recarregue antes de salvar.',1;
   SELECT @antes=(SELECT nome,email,sin_ativo,sin_admin,revisao,
    JSON_QUERY((SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@id_usuario ORDER BY id_orgao FOR JSON PATH)) AS orgaos
    FROM dbo.usuario WHERE id_usuario=@id_usuario FOR JSON PATH,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
   IF EXISTS(SELECT 1 FROM dbo.usuario WHERE id_usuario=@id_usuario
     AND (email_normalizado<>@email OR sin_ativo<>@ativo OR sin_admin<>@admin))
    OR EXISTS(SELECT id_orgao FROM @lista EXCEPT SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@id_usuario)
    OR EXISTS(SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@id_usuario EXCEPT SELECT id_orgao FROM @lista)
    SET @revogar=1;
   UPDATE dbo.usuario SET nome=@nome,email=CONVERT(varchar(250),@email),sin_ativo=@ativo,sin_admin=@admin,
    revisao=revisao+1,versao_sessao=versao_sessao+CONVERT(int,@revogar) WHERE id_usuario=@id_usuario;
  END;
  DELETE u FROM dbo.usuario_orgao u WHERE id_usuario=@id_usuario AND NOT EXISTS(SELECT 1 FROM @lista l WHERE l.id_orgao=u.id_orgao);
  INSERT dbo.usuario_orgao(id_usuario,id_orgao)
   SELECT @id_usuario,l.id_orgao FROM @lista l WHERE NOT EXISTS(
    SELECT 1 FROM dbo.usuario_orgao u WHERE u.id_usuario=@id_usuario AND u.id_orgao=l.id_orgao);
  SELECT @depois=(SELECT nome,email,sin_ativo,sin_admin,revisao,
   JSON_QUERY((SELECT id_orgao FROM dbo.usuario_orgao WHERE id_usuario=@id_usuario ORDER BY id_orgao FOR JSON PATH)) AS orgaos
   FROM dbo.usuario WHERE id_usuario=@id_usuario FOR JSON PATH,INCLUDE_NULL_VALUES,WITHOUT_ARRAY_WRAPPER);
  INSERT dbo.auditoria_administrativa(id_usuario_responsavel,id_usuario_alvo,responsavel_nome,responsavel_email,evento,antes,depois)
   VALUES(@responsavel,@id_usuario,@responsavel_nome,@responsavel_email,CASE WHEN @antes IS NULL THEN 'USUARIO_CRIADO' ELSE 'USUARIO_ATUALIZADO' END,@antes,@depois);
  SELECT @revisao=revisao FROM dbo.usuario WHERE id_usuario=@id_usuario;
  COMMIT;
  SELECT @id_usuario AS id_usuario,@revisao AS revisao,CONVERT(int,@revogar) AS sessoes_revogadas;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

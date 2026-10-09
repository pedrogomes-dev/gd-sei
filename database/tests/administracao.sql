-- SOMENTE homologação, após 007. Fixtures desfeitas; identidades podem avançar.
-- Requer ao menos um órgão cadastrado. Executar com ferramenta que interprete GO.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET ARITHABORT ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET NUMERIC_ROUNDABORT OFF;
SET XACT_ABORT ON;
GO
CREATE PROCEDURE #fixture_admin @admin int OUTPUT,@alvo int OUTPUT,@orgao int OUTPUT AS
BEGIN
 SET NOCOUNT ON;
 DECLARE @sufixo varchar(36)=CONVERT(varchar(36),NEWID());
 SELECT TOP(1) @orgao=id_orgao FROM dbo.orgao ORDER BY id_orgao;
 IF @orgao IS NULL THROW 51900,'Cadastre um orgao na homologacao.',1;
 INSERT dbo.usuario(nome,email,sin_admin) VALUES(N'Administrador teste','admin-'+@sufixo+'@example.test','S');
 SET @admin=CONVERT(int,SCOPE_IDENTITY());
 INSERT dbo.usuario(nome,email) VALUES(N'Avaliador teste','alvo-'+@sufixo+'@example.test');
 SET @alvo=CONVERT(int,SCOPE_IDENTITY());
END;
GO
-- Criação, normalização, vínculos, revisão, revogação e antes/depois.
BEGIN TRY
 BEGIN TRANSACTION;
 DECLARE @a int,@u int,@o int,@novo int,@json nvarchar(max);
 EXEC #fixture_admin @a OUTPUT,@u OUTPUT,@o OUTPUT;
 SET @json=N'['+CONVERT(nvarchar(20),@o)+N']';
 EXEC dbo.sp_salvar_usuario @a,0,0,N'Novo usuário',N' NOVO-ADMIN-TESTE@example.test ','S','N',@json;
 SELECT @novo=id_usuario FROM dbo.usuario WHERE email_normalizado='novo-admin-teste@example.test';
 IF @novo IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.usuario_orgao WHERE id_usuario=@novo AND id_orgao=@o)
  THROW 51901,'Criacao ou vinculo falhou.',1;
 IF NOT EXISTS(SELECT 1 FROM dbo.auditoria_administrativa WHERE id_usuario_alvo=@novo AND evento='USUARIO_CRIADO' AND antes IS NULL)
  THROW 51902,'Auditoria de criacao ausente.',1;
 DECLARE @email nvarchar(max)=(SELECT email FROM dbo.usuario WHERE id_usuario=@u);
 EXEC dbo.sp_salvar_usuario @a,@u,0,N'Nome atualizado',@email,'S','N','[]';
 IF NOT EXISTS(SELECT 1 FROM dbo.usuario WHERE id_usuario=@u AND revisao=1 AND versao_sessao=0)
  THROW 51903,'Alterar apenas nome nao deve revogar sessao.',1;
 EXEC dbo.sp_salvar_usuario @a,@u,1,N'Nome atualizado',@email,'N','S',@json;
 IF NOT EXISTS(SELECT 1 FROM dbo.usuario WHERE id_usuario=@u AND revisao=2 AND versao_sessao=1 AND sin_ativo='N' AND sin_admin='S')
  THROW 51904,'Alteracao de permissao nao revogou sessao.',1;
 IF NOT EXISTS(SELECT 1 FROM dbo.auditoria_administrativa WHERE id_usuario_alvo=@u AND
  JSON_VALUE(antes,'$.sin_ativo')='S' AND JSON_VALUE(depois,'$.sin_ativo')='N' AND responsavel_email IS NOT NULL)
  THROW 51905,'Antes/depois ou identidade historica ausente.',1;
 EXEC dbo.sp_salvar_usuario @a,@u,2,N'Nome atualizado',@email,'S','N','[]';
 IF EXISTS(SELECT 1 FROM dbo.usuario_orgao WHERE id_usuario=@u) OR
  NOT EXISTS(SELECT 1 FROM dbo.usuario WHERE id_usuario=@u AND versao_sessao=2)
  THROW 51906,'Remocao de vinculo ou reativacao falhou.',1;
 -- Sem bloqueio de auto-desativação/retirada do perfil administrativo.
 SET @email=(SELECT email FROM dbo.usuario WHERE id_usuario=@a);
 EXEC dbo.sp_salvar_usuario @a,@a,0,N'Administrador teste',@email,'N','N','[]';
 IF NOT EXISTS(SELECT 1 FROM dbo.usuario WHERE id_usuario=@a AND sin_ativo='N' AND sin_admin='N')
  THROW 51907,'Auto-desativacao deveria ser permitida.',1;
 ROLLBACK;
 PRINT 'PASSOU: criacao, normalizacao, vinculos, revisao, auditoria e revogacao.';
END TRY
BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
GO
-- Cada erro deve reverter toda a operação; fixtures isoladas por caso.
DECLARE @caso int=1;
WHILE @caso<=7
BEGIN
 DECLARE @admin int,@alvo int,@orgao int,@esperado int,@email nvarchar(max),@orgs nvarchar(max)=N'[]',@rev int=0;
 BEGIN TRANSACTION;
 EXEC #fixture_admin @admin OUTPUT,@alvo OUTPUT,@orgao OUTPUT;
 SET @email=(SELECT email FROM dbo.usuario WHERE id_usuario=@alvo);
 IF @caso=1 BEGIN SET @admin=@alvo; SET @esperado=51211; END;
 IF @caso=2 BEGIN UPDATE dbo.usuario SET sin_ativo='N' WHERE id_usuario=@admin; SET @esperado=51211; END;
 IF @caso=3 BEGIN SET @rev=99; SET @esperado=51212; END;
 IF @caso=4 BEGIN SET @email=UPPER((SELECT email FROM dbo.usuario WHERE id_usuario=@admin)); SET @esperado=51213; END;
 IF @caso=5 BEGIN SET @orgs=N'['+CONVERT(nvarchar(20),@orgao)+N','+CONVERT(nvarchar(20),@orgao)+N']'; SET @esperado=51210; END;
 IF @caso=6
 BEGIN
  DECLARE @inexistente int=-2147483648;
  WHILE EXISTS(SELECT 1 FROM dbo.orgao WHERE id_orgao=@inexistente) SET @inexistente+=1;
  SET @orgs=N'['+CONVERT(nvarchar(20),@inexistente)+N']'; SET @esperado=51214;
 END;
 IF @caso=7 BEGIN SET @orgs=N'["1"]'; SET @esperado=51210; END;
 BEGIN TRY
  EXEC dbo.sp_salvar_usuario @admin,@alvo,@rev,N'Avaliador alterado',@email,'S','N',@orgs;
  IF XACT_STATE()<>0 ROLLBACK;
  THROW 51908,'Operacao indevida foi aceita.',1;
 END TRY
 BEGIN CATCH
  DECLARE @obtido int=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @obtido<>@esperado THROW;
 END CATCH;
 SET @caso+=1;
END;
PRINT 'PASSOU: autorizacao, revisao obsoleta, email duplicado e orgaos invalidos.';
GO
-- Imutabilidade do histórico.
BEGIN TRANSACTION;
DECLARE @a int,@u int,@o int;
EXEC #fixture_admin @a OUTPUT,@u OUTPUT,@o OUTPUT;
DECLARE @e nvarchar(max)=(SELECT email FROM dbo.usuario WHERE id_usuario=@u);
EXEC dbo.sp_salvar_usuario @a,@u,0,N'Avaliador teste',@e,'S','N','[]';
BEGIN TRY
 DELETE dbo.auditoria_administrativa WHERE id_usuario_alvo=@u;
 IF XACT_STATE()<>0 ROLLBACK;
 THROW 51909,'Exclusao de auditoria foi aceita.',1;
END TRY
BEGIN CATCH
 DECLARE @codigo int=ERROR_NUMBER();
 IF XACT_STATE()<>0 ROLLBACK;
 IF @codigo<>51202 THROW;
END CATCH;
PRINT 'PASSOU: auditoria imutavel.';
GO
DROP PROCEDURE #fixture_admin;
GO

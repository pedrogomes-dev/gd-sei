-- Executar em sei_gd após 007, antes de atualizar backend/frontend.
-- Não altera tabelas de referência nem o SEI.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET XACT_ABORT ON;
GO
BEGIN TRANSACTION;
IF COL_LENGTH('dbo.manifestacao_tipo','decisao_tipo') IS NULL
BEGIN
    ALTER TABLE dbo.manifestacao_tipo ADD
        decisao_tipo varchar(15) NULL,
        justificativa_tipo nvarchar(2000) NULL;

END;
COMMIT;
GO
BEGIN TRANSACTION;
    -- Submissões anteriores equivalem ao fluxo legado de manutenção.
    -- Rascunhos permanecem sem decisão explícita.
    UPDATE manifestacao
    SET decisao_tipo='MANTER'
    FROM dbo.manifestacao_tipo manifestacao
    JOIN dbo.consulta_orgao_tipo atribuicao ON atribuicao.id_atribuicao=manifestacao.id_atribuicao
    JOIN dbo.consulta_orgao grupo
      ON grupo.id_consulta=atribuicao.id_consulta AND grupo.id_orgao=atribuicao.id_orgao
    WHERE grupo.status='FINALIZADA' AND manifestacao.decisao_tipo IS NULL;

    INSERT dbo.manifestacao_tipo
        (id_atribuicao,versao,observacao,id_usuario_alteracao,decisao_tipo)
    SELECT atribuicao.id_atribuicao,atribuicao.versao,N'',grupo.id_usuario_finalizacao,'MANTER'
    FROM dbo.consulta_orgao_tipo atribuicao
    JOIN dbo.consulta_orgao grupo
      ON grupo.id_consulta=atribuicao.id_consulta AND grupo.id_orgao=atribuicao.id_orgao
    WHERE grupo.status='FINALIZADA'
      AND NOT EXISTS (SELECT 1 FROM dbo.manifestacao_tipo m WHERE m.id_atribuicao=atribuicao.id_atribuicao);
COMMIT;
GO
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name='CK_manifestacao_decisao_tipo')
    ALTER TABLE dbo.manifestacao_tipo ADD CONSTRAINT CK_manifestacao_decisao_tipo CHECK (
        decisao_tipo IS NULL OR decisao_tipo='MANTER' OR
        (decisao_tipo='DESCONTINUAR' AND NULLIF(LTRIM(RTRIM(justificativa_tipo)),N'') IS NOT NULL)
    );
GO
CREATE OR ALTER PROCEDURE dbo.sp_salvar_manifestacao
 @id_usuario int, @id_atribuicao int, @revisao_esperada int,
 @observacao nvarchar(max), @vinculos nvarchar(max),
 @decisao_tipo varchar(15), @justificativa_tipo nvarchar(max)
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @revisao_esperada IS NULL OR @revisao_esperada<0 THROW 51033,'Revisao invalida.',1;
 IF @decisao_tipo IS NULL OR @decisao_tipo NOT IN ('MANTER','DESCONTINUAR')
  THROW 51041,'Decida manter ou sugerir descontinuacao do Tipo.',1;
 IF LEN(ISNULL(@justificativa_tipo,N''))>2000
  THROW 51040,'Justificativa excede 2000 caracteres.',1;
 IF @decisao_tipo='DESCONTINUAR' AND NULLIF(LTRIM(RTRIM(@justificativa_tipo)),N'') IS NULL
  THROW 51042,'Justifique a sugestao de descontinuacao.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @consulta int,@orgao int,@versao int,@tipo int,@status varchar(12),@revisao int,@antes nvarchar(max),@depois nvarchar(max);
  SELECT @consulta=id_consulta,@orgao=id_orgao,@versao=versao,@tipo=id_tipo_procedimento
   FROM dbo.consulta_orgao_tipo WHERE id_atribuicao=@id_atribuicao;
  IF @consulta IS NULL THROW 51030,'Atribuicao nao autorizada.',1;
  SELECT @status=status FROM dbo.consulta_orgao WITH(UPDLOCK,HOLDLOCK)
   WHERE id_consulta=@consulta AND id_orgao=@orgao;
  IF NOT EXISTS(SELECT 1 FROM dbo.usuario_orgao u WITH(HOLDLOCK)
   JOIN dbo.usuario p WITH(HOLDLOCK) ON p.id_usuario=u.id_usuario AND p.sin_ativo='S'
   WHERE u.id_usuario=@id_usuario AND u.id_orgao=@orgao)
   THROW 51030,'Atribuicao nao autorizada.',1;
  IF @status='FINALIZADA' THROW 51031,'Manifestacao finalizada.',1;
  SELECT @revisao=revisao FROM dbo.manifestacao_tipo WITH(UPDLOCK,HOLDLOCK) WHERE id_atribuicao=@id_atribuicao;
  IF ISNULL(@revisao,0)<>@revisao_esperada THROW 51032,'Outro usuario alterou este Tipo. Recarregue.',1;
  IF LEN(ISNULL(@observacao,N''))>5000 THROW 51040,'Observacao excede 5000 caracteres.',1;
  IF @decisao_tipo='DESCONTINUAR' SET @vinculos=N'[]';
  IF @vinculos IS NULL OR ISJSON(@vinculos)<>1 OR LEFT(LTRIM(@vinculos),1)<>'[' THROW 51033,'Lista de vinculos invalida.',1;
  DECLARE @itens TABLE(id_assunto int NULL,acao nvarchar(max) NULL,justificativa nvarchar(max) NULL);
  INSERT @itens SELECT id_assunto,acao,justificativa FROM OPENJSON(@vinculos)
   WITH(id_assunto int '$.id_assunto',acao nvarchar(max) '$.acao',justificativa nvarchar(max) '$.justificativa');
  IF EXISTS(SELECT 1 FROM @itens WHERE id_assunto IS NULL OR acao IS NULL OR acao NOT IN('MANTER','REMOVER','ADICIONAR'))
   OR EXISTS(SELECT 1 FROM @itens GROUP BY id_assunto HAVING COUNT(*)>1)
   THROW 51033,'Lista de vinculos invalida ou duplicada.',1;
  IF EXISTS(SELECT 1 FROM @itens WHERE LEN(ISNULL(justificativa,N''))>2000)
   THROW 51040,'Justificativa excede 2000 caracteres.',1;
  IF EXISTS(SELECT 1 FROM @itens WHERE acao IN('REMOVER','ADICIONAR') AND NULLIF(LTRIM(RTRIM(justificativa)),N'') IS NULL)
   THROW 51036,'Justificativa obrigatoria para remover e adicionar.',1;
  IF EXISTS(SELECT 1 FROM @itens i LEFT JOIN dbo.assunto s ON s.versao=@versao AND s.id_assunto=i.id_assunto
   WHERE s.id_assunto IS NULL OR (i.acao='ADICIONAR' AND s.sin_ativo<>'S'))
   THROW 51035,'Assunto inexistente ou inclusao de assunto inativo.',1;
  IF EXISTS(SELECT 1 FROM @itens i WHERE
   (i.acao='ADICIONAR' AND EXISTS(SELECT 1 FROM dbo.rel_tipo_procedimento_assunto r
     WHERE r.versao=@versao AND r.id_tipo_procedimento=@tipo AND r.id_assunto_proxy=i.id_assunto))
   OR (i.acao IN('MANTER','REMOVER') AND NOT EXISTS(SELECT 1 FROM dbo.rel_tipo_procedimento_assunto r
     WHERE r.versao=@versao AND r.id_tipo_procedimento=@tipo AND r.id_assunto_proxy=i.id_assunto)))
   THROW 51034,'Acao incompatível com vinculo original.',1;
  SELECT @antes=(SELECT m.observacao,m.revisao,m.decisao_tipo,m.justificativa_tipo,
    JSON_QUERY((SELECT id_assunto,acao,justificativa FROM dbo.manifestacao_vinculo WHERE id_atribuicao=@id_atribuicao ORDER BY id_assunto FOR JSON PATH)) AS vinculos
    FROM dbo.manifestacao_tipo m WHERE m.id_atribuicao=@id_atribuicao FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
  IF @revisao IS NULL
   INSERT dbo.manifestacao_tipo(id_atribuicao,versao,observacao,id_usuario_alteracao,decisao_tipo,justificativa_tipo)
    VALUES(@id_atribuicao,@versao,@observacao,@id_usuario,@decisao_tipo,@justificativa_tipo);
  ELSE
   UPDATE dbo.manifestacao_tipo SET observacao=@observacao,decisao_tipo=@decisao_tipo,justificativa_tipo=@justificativa_tipo,revisao=revisao+1,id_usuario_alteracao=@id_usuario,data_alteracao=SYSUTCDATETIME()
    WHERE id_atribuicao=@id_atribuicao;
  IF @decisao_tipo='MANTER'
  BEGIN
  DELETE dbo.manifestacao_vinculo WHERE id_atribuicao=@id_atribuicao;
  INSERT dbo.manifestacao_vinculo(id_atribuicao,versao,id_assunto,acao,justificativa)
   SELECT @id_atribuicao,@versao,id_assunto,acao,justificativa FROM @itens;
  END;
  UPDATE dbo.consulta_orgao SET revisao=revisao+1 WHERE id_consulta=@consulta AND id_orgao=@orgao;
  SELECT @depois=(SELECT observacao,revisao,decisao_tipo,justificativa_tipo,
    JSON_QUERY((SELECT id_assunto,acao,justificativa FROM dbo.manifestacao_vinculo WHERE id_atribuicao=@id_atribuicao FOR JSON PATH)) AS vinculos FROM dbo.manifestacao_tipo WHERE id_atribuicao=@id_atribuicao FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
  INSERT dbo.auditoria(id_usuario,evento,detalhe)
   SELECT @id_usuario,'ALTERACAO_MANIFESTACAO',
    (SELECT @id_atribuicao AS id_atribuicao,JSON_QUERY(@antes) AS antes,JSON_QUERY(@depois) AS depois FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
  -- Registra propostas atuais explicitamente, com valores anteriores no evento principal.
  INSERT dbo.auditoria(id_usuario,evento,detalhe)
   SELECT @id_usuario,CASE acao WHEN 'ADICIONAR' THEN 'INCLUSAO_PROPOSTA' ELSE 'REMOCAO_PROPOSTA' END,
    (SELECT @id_atribuicao AS id_atribuicao,i.id_assunto,i.acao,i.justificativa FOR JSON PATH,WITHOUT_ARRAY_WRAPPER)
    FROM @itens i WHERE acao IN('ADICIONAR','REMOVER');
  SELECT @revisao=revisao FROM dbo.manifestacao_tipo WHERE id_atribuicao=@id_atribuicao;
  COMMIT;
  SELECT @revisao AS revisao;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO
CREATE OR ALTER PROCEDURE dbo.sp_finalizar_manifestacao_orgao
 @id_usuario int,@id_consulta int,@id_orgao int,@revisao_esperada int
AS
BEGIN
 SET NOCOUNT ON; SET XACT_ABORT ON;
 IF @revisao_esperada IS NULL OR @revisao_esperada<0 THROW 51033,'Revisao invalida.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @status varchar(12),@revisao int;
  SELECT @status=status,@revisao=revisao FROM dbo.consulta_orgao WITH(UPDLOCK,HOLDLOCK)
   WHERE id_consulta=@id_consulta AND id_orgao=@id_orgao;
  IF @status IS NULL OR NOT EXISTS(SELECT 1 FROM dbo.usuario_orgao u WITH(HOLDLOCK)
   JOIN dbo.usuario p WITH(HOLDLOCK) ON p.id_usuario=u.id_usuario AND p.sin_ativo='S'
   WHERE u.id_usuario=@id_usuario AND u.id_orgao=@id_orgao)
   THROW 51030,'Orgao nao autorizado.',1;
  IF @status='FINALIZADA' THROW 51031,'Manifestacao ja finalizada.',1;
  IF @revisao<>@revisao_esperada THROW 51032,'Manifestacao alterada. Atualize o resumo.',1;
  IF NOT EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo WHERE id_consulta=@id_consulta AND id_orgao=@id_orgao)
   THROW 51039,'Nenhum Tipo atribuido ao orgao.',1;
  IF EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo a LEFT JOIN dbo.visualizacao_tipo v ON v.id_atribuicao=a.id_atribuicao
   WHERE a.id_consulta=@id_consulta AND a.id_orgao=@id_orgao AND v.id_atribuicao IS NULL)
   THROW 51037,'Visualize todos os Tipos antes de finalizar.',1;
  IF EXISTS (
    SELECT 1 FROM dbo.consulta_orgao_tipo a
    LEFT JOIN dbo.manifestacao_tipo m ON m.id_atribuicao=a.id_atribuicao
    WHERE a.id_consulta=@id_consulta AND a.id_orgao=@id_orgao
      AND (m.decisao_tipo IS NULL OR
        (m.decisao_tipo='DESCONTINUAR' AND NULLIF(LTRIM(RTRIM(m.justificativa_tipo)),N'') IS NULL))
  ) THROW 51041,'Decida todos os Tipos e justifique as descontinuacoes.',1;
  IF EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo a
   JOIN dbo.manifestacao_tipo mt ON mt.id_atribuicao=a.id_atribuicao AND mt.decisao_tipo='MANTER'
   JOIN dbo.rel_tipo_procedimento_assunto r ON r.versao=a.versao AND r.id_tipo_procedimento=a.id_tipo_procedimento
   LEFT JOIN dbo.manifestacao_vinculo m ON m.id_atribuicao=a.id_atribuicao AND m.id_assunto=r.id_assunto_proxy
    AND m.acao IN('MANTER','REMOVER')
   WHERE a.id_consulta=@id_consulta AND a.id_orgao=@id_orgao AND m.id_assunto IS NULL)
   THROW 51038,'Decida todos os vinculos existentes antes de finalizar.',1;
  UPDATE dbo.consulta_orgao SET status='FINALIZADA',data_finalizacao=SYSUTCDATETIME(),id_usuario_finalizacao=@id_usuario,revisao=revisao+1
   WHERE id_consulta=@id_consulta AND id_orgao=@id_orgao;
  INSERT dbo.auditoria(id_usuario,evento,detalhe) SELECT @id_usuario,'FINALIZACAO',
   (SELECT @id_consulta AS id_consulta,@id_orgao AS id_orgao,@revisao AS revisao_aprovada FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
  COMMIT;
  SELECT 'FINALIZADA' AS status;
 END TRY
 BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK; THROW; END CATCH;
END;
GO

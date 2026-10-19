-- Instalação nova: executar 001 e 009 antes deste script.
-- Pode ser reaplicado para atualizar a procedure, sem publicar dados.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE dbo.sp_publicar_versao_sei
 @usuario_carga nvarchar(150),
 @origem nvarchar(250),
 @observacao nvarchar(1000) = NULL
AS
BEGIN
 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 IF @@TRANCOUNT <> 0 THROW 51001, 'Execute fora de outra transacao.', 1;
 IF NULLIF(LTRIM(RTRIM(@usuario_carga)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@origem)), '') IS NULL
  THROW 51002, 'Informe usuario e origem.', 1;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @lock int, @versao int, @quantidade bigint;
  EXEC @lock = sys.sp_getapplock @Resource='publicacao_base_sei',
   @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=15000;
  IF @lock < 0 THROW 51003, 'Publicacao concorrente: tente novamente.', 1;
  -- Bloqueia inclusive INSERT durante validacao e copia. Mesma ordem em toda publicacao.
  SELECT @quantidade=COUNT_BIG(*) FROM dbo.ref_assunto WITH (TABLOCKX,HOLDLOCK);
  IF @quantidade=0 THROW 51004, 'Carga de assuntos vazia.', 1;
  SELECT @quantidade=COUNT_BIG(*) FROM dbo.ref_tipo_procedimento WITH (TABLOCKX,HOLDLOCK);
  IF @quantidade=0 THROW 51005, 'Carga de tipos vazia.', 1;
  SELECT @quantidade=COUNT_BIG(*) FROM dbo.ref_rel_tipo_procedimento_assunto WITH (TABLOCKX,HOLDLOCK);
  IF EXISTS (SELECT 1 FROM dbo.ref_assunto WHERE sin_ativo NOT IN ('S','N'))
   OR EXISTS (SELECT 1 FROM dbo.ref_tipo_procedimento WHERE sin_ativo NOT IN ('S','N'))
   THROW 51006, 'sin_ativo deve ser S ou N.', 1;
  IF EXISTS (SELECT 1 FROM dbo.ref_rel_tipo_procedimento_assunto r
   LEFT JOIN dbo.ref_assunto a ON a.id_assunto=r.id_assunto_proxy
   LEFT JOIN dbo.ref_tipo_procedimento t ON t.id_tipo_procedimento=r.id_tipo_procedimento
   WHERE a.id_assunto IS NULL OR t.id_tipo_procedimento IS NULL)
   THROW 51007, 'Vinculo com referencia inexistente.', 1;
  IF EXISTS (SELECT 1 FROM dbo.ref_rel_tipo_procedimento_assunto
   GROUP BY id_tipo_procedimento,id_assunto_proxy HAVING COUNT(*)>1)
   THROW 51008, 'Vinculo Tipo x Assunto duplicado.', 1;
  IF EXISTS (SELECT 1 FROM dbo.ref_assunto filho
   WHERE filho.id_assunto_pai IS NOT NULL AND (
    filho.id_assunto_pai=filho.id_assunto OR NOT EXISTS (
     SELECT 1 FROM dbo.ref_assunto pai WHERE pai.id_assunto=filho.id_assunto_pai)))
   THROW 51009, 'Pai de Assunto inexistente ou igual ao proprio Assunto.', 1;
  -- Uma base antiga pode ter hierarquia apenas no snapshot. Não a perder
  -- silenciosamente: a referência deve ser completada pela fonte oficial.
  IF EXISTS (SELECT 1 FROM dbo.ref_assunto fonte
   JOIN dbo.assunto anterior ON anterior.id_assunto=fonte.id_assunto AND anterior.sin_ultima='S'
   WHERE anterior.id_assunto_pai IS NOT NULL AND fonte.id_assunto_pai IS NULL)
   THROW 51010, 'Carregue a hierarquia explicita na referencia antes de publicar.', 1;
  SELECT @versao=ISNULL(MAX(versao),-1)+1 FROM dbo.versao_base WITH (UPDLOCK,HOLDLOCK);
  -- Registro pai precede as copias por causa das FKs; tudo participa da mesma transacao.
  INSERT dbo.versao_base(versao,usuario_carga,origem,observacao)
   VALUES(@versao,@usuario_carga,@origem,@observacao);
  UPDATE dbo.assunto SET sin_ultima='N' WHERE sin_ultima='S';
  INSERT dbo.assunto(id_assunto,codigo_estruturado,descricao,observacao,idx_assunto,sin_ativo,prazo_intermediario,prazo_corrente,sta_destinacao,sin_estrutural,id_tabela_assuntos,id_assunto_pai,versao,sin_ultima)
   SELECT id_assunto,codigo_estruturado,descricao,observacao,idx_assunto,sin_ativo,prazo_intermediario,prazo_corrente,sta_destinacao,sin_estrutural,id_tabela_assuntos,id_assunto_pai,@versao,'S' FROM dbo.ref_assunto;
  UPDATE dbo.tipo_procedimento SET sin_ultima='N' WHERE sin_ultima='S';
  INSERT dbo.tipo_procedimento(id_tipo_procedimento,nome,descricao,sin_ativo,sta_nivel_acesso_sugestao,sin_interno,sin_ouvidoria,sin_individual,id_hipotese_legal_sugestao,sta_grau_sigilo_sugestao,id_plano_trabalho,sin_ouvidoria_anonimo,versao,sin_ultima)
   SELECT id_tipo_procedimento,nome,descricao,sin_ativo,sta_nivel_acesso_sugestao,sin_interno,sin_ouvidoria,sin_individual,id_hipotese_legal_sugestao,sta_grau_sigilo_sugestao,id_plano_trabalho,sin_ouvidoria_anonimo,@versao,'S' FROM dbo.ref_tipo_procedimento;
  UPDATE dbo.rel_tipo_procedimento_assunto SET sin_ultima='N' WHERE sin_ultima='S';
  INSERT dbo.rel_tipo_procedimento_assunto(id_tipo_procedimento,sequencia,id_assunto_proxy,versao,sin_ultima)
   SELECT id_tipo_procedimento,sequencia,id_assunto_proxy,@versao,'S' FROM dbo.ref_rel_tipo_procedimento_assunto;
  COMMIT;
  SELECT @versao AS versao;
 END TRY
 BEGIN CATCH
  IF XACT_STATE() <> 0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO

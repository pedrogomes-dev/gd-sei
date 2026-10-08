USE sei_gd;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE dbo.sp_completar_atribuicoes
 @id_consulta int,
 @aplicar bit = 0
AS
BEGIN
 SET NOCOUNT ON;
 SET XACT_ABORT ON;
 IF @@TRANCOUNT<>0 THROW 51110,'Execute fora de outra transacao.',1;
 IF @aplicar IS NULL THROW 51111,'Informe aplicar como 0 ou 1.',1;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @versao int,@lock int;
  EXEC @lock=sys.sp_getapplock @Resource='carga_atribuicoes',
   @LockMode='Exclusive',@LockOwner='Transaction',@LockTimeout=15000;
  IF @lock<0 THROW 51112,'Carga concorrente. Tente novamente.',1;
  SELECT @versao=versao FROM dbo.consulta WITH(UPDLOCK,HOLDLOCK)
   WHERE id_consulta=@id_consulta;
  IF @versao IS NULL THROW 51113,'Rodada inexistente.',1;
  SELECT id_tipo_procedimento,id_orgao INTO #fonte
   FROM dbo.tipo_procedimento_restricao WITH(HOLDLOCK);
  IF NOT EXISTS(SELECT 1 FROM #fonte) THROW 51114,'Distribuicao vazia.',1;
  IF EXISTS(SELECT 1 FROM #fonte f WHERE NOT EXISTS(
   SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=f.id_orgao))
   THROW 51115,'Orgao nao cadastrado.',1;
  IF EXISTS(SELECT 1 FROM #fonte f WHERE NOT EXISTS(
   SELECT 1 FROM dbo.tipo_procedimento WITH(HOLDLOCK)
   WHERE id_tipo_procedimento=f.id_tipo_procedimento AND versao=@versao))
   THROW 51116,'Tipo de Processo inexistente na versao da rodada.',1;

  -- Bloqueia os grupos contra salvamento/finalizacao durante a carga.
  SELECT id_orgao,status INTO #grupos
   FROM dbo.consulta_orgao WITH(UPDLOCK,HOLDLOCK)
   WHERE id_consulta=@id_consulta;

  SELECT f.id_orgao,f.id_tipo_procedimento,
   CASE
    WHEN EXISTS(SELECT 1 FROM dbo.consulta_orgao_tipo a WITH(HOLDLOCK)
     WHERE a.id_consulta=@id_consulta AND a.id_orgao=f.id_orgao
      AND a.id_tipo_procedimento=f.id_tipo_procedimento) THEN 'JA_ATRIBUIDO'
    WHEN EXISTS(SELECT 1 FROM #grupos g
     WHERE g.id_orgao=f.id_orgao AND g.status='FINALIZADA') THEN 'ORGAO_FINALIZADO'
    ELSE 'INCLUIR'
   END AS situacao INTO #plano
   FROM #fonte f;

  -- Mostra historico para decisao humana; nao presume equivalencia entre rodadas.
  SELECT p.*,o.sigla,
   (SELECT COUNT(*) FROM dbo.consulta_orgao_tipo a
    JOIN dbo.consulta_orgao co ON co.id_consulta=a.id_consulta AND co.id_orgao=a.id_orgao
    WHERE a.id_consulta<>@id_consulta AND a.id_orgao=p.id_orgao
     AND a.id_tipo_procedimento=p.id_tipo_procedimento AND a.versao=@versao
     AND co.status='FINALIZADA') AS finalizacoes_em_outras_rodadas
   FROM #plano p JOIN dbo.orgao o ON o.id_orgao=p.id_orgao
   ORDER BY o.sigla,p.id_tipo_procedimento;

  IF @aplicar=1
  BEGIN
   -- Nao abrir nem alterar grupo finalizado.
   INSERT dbo.consulta_orgao(id_consulta,id_orgao,status)
    SELECT DISTINCT @id_consulta,p.id_orgao,'RASCUNHO' FROM #plano p
    WHERE p.situacao='INCLUIR' AND NOT EXISTS(
     SELECT 1 FROM dbo.consulta_orgao co
     WHERE co.id_consulta=@id_consulta AND co.id_orgao=p.id_orgao);

   INSERT dbo.consulta_orgao_tipo(id_consulta,id_orgao,versao,id_tipo_procedimento)
    SELECT @id_consulta,id_orgao,@versao,id_tipo_procedimento
    FROM #plano WHERE situacao='INCLUIR';

   -- Invalida resumo aberto antes de incluir atribuicoes.
   UPDATE co SET revisao=revisao+1
    FROM dbo.consulta_orgao co
    WHERE co.id_consulta=@id_consulta AND co.status='RASCUNHO'
     AND EXISTS(SELECT 1 FROM #plano p WHERE p.id_orgao=co.id_orgao AND p.situacao='INCLUIR');
  END;

  SELECT @id_consulta AS id_consulta,@versao AS versao,@aplicar AS aplicado,
   situacao,COUNT(*) AS quantidade FROM #plano GROUP BY situacao;
  COMMIT;
 END TRY
 BEGIN CATCH
  IF XACT_STATE()<>0 ROLLBACK;
  THROW;
 END CATCH;
END;
GO
-- Descubra a rodada correta antes de executar:
SELECT c.id_consulta,c.nome,c.versao,co.id_orgao,o.sigla,co.status,
 COUNT(a.id_atribuicao) AS atribuicoes
FROM dbo.consulta c
LEFT JOIN dbo.consulta_orgao co ON co.id_consulta=c.id_consulta
LEFT JOIN dbo.orgao o ON o.id_orgao=co.id_orgao
LEFT JOIN dbo.consulta_orgao_tipo a ON a.id_consulta=co.id_consulta AND a.id_orgao=co.id_orgao
GROUP BY c.id_consulta,c.nome,c.versao,co.id_orgao,o.sigla,co.status
ORDER BY c.id_consulta,o.sigla;
GO
-- Previa (trocar 123 pelo ID correto):
-- EXEC dbo.sp_completar_atribuicoes @id_consulta=123,@aplicar=0;
-- Aplicacao explicita, somente depois da previa:
-- EXEC dbo.sp_completar_atribuicoes @id_consulta=123,@aplicar=1;

-- Executar SOMENTE em homologação após 005. Fixtures são desfeitas.
-- Não publica nem modifica a base SEI. Sequências IDENTITY podem avançar mesmo após rollback.
SET NOCOUNT ON;
SET XACT_ABORT ON;
DECLARE @usuario int=(SELECT MIN(id_usuario) FROM dbo.usuario WHERE sin_ativo='S');
DECLARE @versao int,@tipo int,@assunto int;
SELECT TOP(1) @versao=versao,@tipo=id_tipo_procedimento,@assunto=id_assunto_proxy
 FROM dbo.rel_tipo_procedimento_assunto ORDER BY versao,id_tipo_procedimento,sequencia;
IF @usuario IS NULL OR @versao IS NULL THROW 51990,'Teste exige usuario ativo e Tipo com vinculo na base.',1;
DECLARE @cenario int=0;
WHILE @cenario<10
BEGIN
 DECLARE @esperado int=CASE @cenario WHEN 0 THEN 0 WHEN 1 THEN 51032 WHEN 2 THEN 51036
  WHEN 3 THEN 51037 WHEN 4 THEN 51038 WHEN 5 THEN 51031 WHEN 6 THEN 51030
  WHEN 7 THEN 51034 WHEN 8 THEN 51035 WHEN 9 THEN 51033 END;
 BEGIN TRY
  BEGIN TRANSACTION;
  DECLARE @sigla varchar(30)='TEST-'+LEFT(CONVERT(varchar(36),NEWID()),20);
  INSERT dbo.orgao(nome,sigla) VALUES(N'Fixture de teste de manifestação',@sigla);
  DECLARE @orgao int=CONVERT(int,SCOPE_IDENTITY());
  INSERT dbo.usuario_orgao VALUES(@usuario,@orgao);
  INSERT dbo.consulta(nome,versao) VALUES(N'Fixture de teste',@versao);
  DECLARE @consulta int=CONVERT(int,SCOPE_IDENTITY());
  INSERT dbo.consulta_orgao(id_consulta,id_orgao) VALUES(@consulta,@orgao);
  INSERT dbo.consulta_orgao_tipo(id_consulta,id_orgao,versao,id_tipo_procedimento)
   VALUES(@consulta,@orgao,@versao,@tipo);
  DECLARE @atribuicao int=CONVERT(int,SCOPE_IDENTITY()),@revisao int,@json nvarchar(max);
  SELECT @json=(SELECT id_assunto_proxy AS id_assunto,'MANTER' AS acao,N'' AS justificativa
   FROM dbo.rel_tipo_procedimento_assunto WHERE versao=@versao AND id_tipo_procedimento=@tipo FOR JSON PATH);
  IF @cenario=2
  BEGIN
   SELECT @json=(SELECT @assunto AS id_assunto,'REMOVER' AS acao,N'' AS justificativa FOR JSON PATH);
   EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'',@json;
  END
  ELSE IF @cenario=7
  BEGIN
   SELECT @json=(SELECT @assunto AS id_assunto,'ADICIONAR' AS acao,N'Proposta invalida: ja vinculado' AS justificativa FOR JSON PATH);
   EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'',@json;
  END
  ELSE IF @cenario=8
  BEGIN
   DECLARE @inexistente int=-2147483648;
   WHILE EXISTS(SELECT 1 FROM dbo.assunto WHERE versao=@versao AND id_assunto=@inexistente) SET @inexistente+=1;
   SELECT @json=(SELECT @inexistente AS id_assunto,'ADICIONAR' AS acao,N'Proposta de assunto inexistente' AS justificativa FOR JSON PATH);
   EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'',@json;
  END
  ELSE IF @cenario=9
  BEGIN
   SELECT @json=(SELECT @assunto AS id_assunto,'MANTER' AS acao,N'' AS justificativa
    FROM (VALUES(1),(2)) x(n) FOR JSON PATH);
   EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'',@json;
  END
  ELSE IF @cenario=6
  BEGIN
   INSERT dbo.usuario(email) VALUES(@sigla+'@test.invalid');
   DECLARE @outro int=CONVERT(int,SCOPE_IDENTITY());
   EXEC dbo.sp_salvar_manifestacao @outro,@atribuicao,0,N'',@json;
  END
  ELSE
  BEGIN
   IF @cenario=4 SET @json=N'[]';
   EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'Teste inicial',@json;
   IF @cenario=1 EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,0,N'Revisao obsoleta',@json;
   IF @cenario<>3 INSERT dbo.visualizacao_tipo(id_atribuicao,id_usuario) VALUES(@atribuicao,@usuario);
   IF @cenario=0
   BEGIN
    EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,1,N'Teste atualizado',@json;
    IF NOT EXISTS(SELECT 1 FROM dbo.manifestacao_tipo WHERE id_atribuicao=@atribuicao AND revisao=2 AND observacao=N'Teste atualizado')
     THROW 51991,'Falha no salvamento e incremento de revisao.',1;
   END;
   SELECT @revisao=revisao FROM dbo.consulta_orgao WHERE id_consulta=@consulta AND id_orgao=@orgao;
   EXEC dbo.sp_finalizar_manifestacao_orgao @usuario,@consulta,@orgao,@revisao;
   IF NOT EXISTS(SELECT 1 FROM dbo.consulta_orgao WHERE id_consulta=@consulta AND id_orgao=@orgao AND status='FINALIZADA')
    THROW 51992,'Falha na finalizacao.',1;
   IF NOT EXISTS(SELECT 1 FROM dbo.auditoria WHERE id_usuario=@usuario AND evento='FINALIZACAO'
    AND TRY_CONVERT(int,JSON_VALUE(detalhe,'$.id_consulta'))=@consulta)
    THROW 51993,'Auditoria de finalizacao ausente.',1;
   IF @cenario=5 EXEC dbo.sp_salvar_manifestacao @usuario,@atribuicao,1,N'Edicao proibida',@json;
  END;
  IF @esperado<>0 THROW 51994,'Operacao deveria ter sido recusada.',1;
  ROLLBACK;
  PRINT CONCAT('Cenario ',@cenario,': OK');
 END TRY
 BEGIN CATCH
  DECLARE @erro int=ERROR_NUMBER();
  IF XACT_STATE()<>0 ROLLBACK;
  IF @esperado=0 OR @erro<>@esperado THROW;
  PRINT CONCAT('Cenario ',@cenario,': bloqueio esperado ',@erro,' OK');
 END CATCH;
 SET @cenario+=1;
END;

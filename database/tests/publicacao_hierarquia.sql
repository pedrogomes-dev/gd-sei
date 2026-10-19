-- SOMENTE em banco descartável e vazio após 001, 009 e 002.
-- Executa INSERT e publicação reais. Descarte o banco após a homologação.
-- Não envolve a procedure em transação: ela exige @@TRANCOUNT=0.
SET NOCOUNT ON;
SET XACT_ABORT ON;
IF EXISTS(SELECT 1 FROM dbo.versao_base)
 OR EXISTS(SELECT 1 FROM dbo.ref_assunto)
 OR EXISTS(SELECT 1 FROM dbo.ref_tipo_procedimento)
 THROW 51310,'O teste exige banco descartavel sem carga ou publicacoes.',1;

INSERT dbo.ref_assunto
 (id_assunto,codigo_estruturado,descricao,sin_ativo,id_tabela_assuntos,id_assunto_pai)
 VALUES (1,'085','Raiz','S',1,NULL),
        (2,'085.61','Filho da raiz','S',1,1),
        (3,'085.611','Outro filho da raiz','S',1,1),
        (4,'085.61.a','Neto','S',1,2);
INSERT dbo.ref_tipo_procedimento
 (id_tipo_procedimento,nome,sin_ativo,sta_nivel_acesso_sugestao,sin_interno,
  sin_ouvidoria,sin_individual,sin_ouvidoria_anonimo)
 VALUES (1,'Tipo de teste','S','1','S','N','N','N');
INSERT dbo.ref_rel_tipo_procedimento_assunto
 (id_tipo_procedimento,sequencia,id_assunto_proxy) VALUES (1,1,4);

EXEC dbo.sp_publicar_versao_sei N'teste',N'Fixture de hierarquia';
EXEC dbo.sp_publicar_versao_sei N'teste',N'Segunda publicacao';

IF (SELECT COUNT(*) FROM dbo.assunto)<>8
 OR (SELECT COUNT(*) FROM dbo.assunto WHERE id_assunto IN (2,3) AND id_assunto_pai=1)<>4
 OR (SELECT COUNT(*) FROM dbo.assunto WHERE id_assunto=4 AND id_assunto_pai=2)<>2
 OR (SELECT COUNT(*) FROM dbo.assunto WHERE id_assunto=1 AND id_assunto_pai IS NULL)<>2
 THROW 51311,'Os pais explicitos nao foram preservados nas duas versoes.',1;
IF EXISTS(SELECT 1 FROM dbo.assunto WHERE
 (versao=0 AND sin_ultima<>'N') OR (versao=1 AND sin_ultima<>'S'))
 THROW 51312,'Marcacao de ultima versao incorreta.',1;
IF (SELECT COUNT(*) FROM dbo.rel_tipo_procedimento_assunto r
 JOIN dbo.assunto a ON a.versao=r.versao AND a.id_assunto=r.id_assunto_proxy
 WHERE a.id_assunto=4 AND a.id_assunto_pai=2)<>2
 THROW 51313,'Vinculo Tipo x Assunto nao preservado por versao.',1;

INSERT dbo.ref_assunto
 (id_assunto,codigo_estruturado,descricao,sin_ativo,id_tabela_assuntos,id_assunto_pai)
 VALUES (5,'999','Pai inexistente','S',1,999);
BEGIN TRY
 EXEC dbo.sp_publicar_versao_sei N'teste',N'Publicacao invalida';
 THROW 51314,'A publicacao deveria rejeitar pai inexistente.',1;
END TRY
BEGIN CATCH
 IF ERROR_NUMBER()<>51009 THROW;
END CATCH;
IF (SELECT COUNT(*) FROM dbo.versao_base)<>2
 OR (SELECT COUNT(*) FROM dbo.assunto)<>8
 THROW 51315,'A publicacao invalida alterou o historico.',1;
PRINT 'Hierarquia explicita, vinculos versionados e rollback: OK';

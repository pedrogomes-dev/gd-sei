-- Roteiro manual após carga real; executar em homologação.
-- 1. Publicar pela primeira vez: retorna 0.
-- 2. Publicar novamente: retorna 1; versão 0 permanece, sin_ultima=N.
SELECT * FROM dbo.versao_base ORDER BY versao;
SELECT versao,sin_ultima,COUNT(*) quantidade FROM dbo.assunto GROUP BY versao,sin_ultima;
SELECT versao,sin_ultima,COUNT(*) quantidade FROM dbo.tipo_procedimento GROUP BY versao,sin_ultima;
SELECT versao,sin_ultima,COUNT(*) quantidade FROM dbo.rel_tipo_procedimento_assunto GROUP BY versao,sin_ultima;
-- 3. Em outra sessão publicar simultaneamente: versões distintas, nunca dados parciais.
-- 4. Tentar UPDATE/DELETE nas ref_*: deve falhar, sem alterar dados.
-- 5. Em base isolada, carregar sin_ativo inválido e publicar: deve falhar,
--    sem nova versao_base e sem mudança do sin_ultima anterior.
-- 6. Duplicar Tipo x Assunto com outra sequencia: publicação deve falhar.
-- 7. Verificar que INSERT concorrente na referencia aguarda publicação terminar.
-- Não executar testes destrutivos na base oficial.

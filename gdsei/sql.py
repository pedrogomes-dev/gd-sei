"""Consultas e transações preservadas do backend anterior; valores parametrizados."""

TIPOS = """
SELECT atribuicao.id_atribuicao, atribuicao.id_consulta, atribuicao.id_orgao,
        atribuicao.id_tipo_procedimento, atribuicao.versao, tipo.nome, orgao.sigla,
        consulta.nome AS consulta, grupo.status, manifestacao.decisao_tipo,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado,
        CASE
          WHEN manifestacao.decisao_tipo = 'DESCONTINUAR' THEN 0
          ELSE (
            SELECT COUNT(*)
            FROM dbo.rel_tipo_procedimento_assunto vinculo
            WHERE vinculo.versao = atribuicao.versao
              AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
              AND NOT EXISTS (
                SELECT 1 FROM dbo.manifestacao_vinculo decisao
                WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                  AND decisao.id_assunto = vinculo.id_assunto_proxy
                  AND decisao.acao IN ('MANTER','REMOVER')
              )
          ) + CASE WHEN manifestacao.decisao_tipo IS NULL THEN 1 ELSE 0 END
        END AS pendentes
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.usuario_orgao usuario ON usuario.id_orgao = atribuicao.id_orgao AND usuario.id_usuario = ?
      JOIN dbo.orgao orgao ON orgao.id_orgao = atribuicao.id_orgao
      JOIN dbo.consulta consulta ON consulta.id_consulta = atribuicao.id_consulta
      JOIN dbo.consulta_orgao grupo ON grupo.id_consulta = atribuicao.id_consulta AND grupo.id_orgao = atribuicao.id_orgao
      JOIN dbo.tipo_procedimento tipo ON tipo.versao = atribuicao.versao AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      LEFT JOIN dbo.visualizacao_tipo visualizacao ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.manifestacao_tipo manifestacao ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
      ORDER BY consulta.nome, orgao.sigla, tipo.nome
"""

TIPO = """
SELECT tipo.*, atribuicao.id_atribuicao, atribuicao.id_consulta,
        atribuicao.id_orgao, grupo.status,
        hipotese.nome AS hipotese_legal_nome,
        hipotese.base_legal AS hipotese_legal_base,
        hipotese.descricao AS hipotese_legal_descricao,
        hipotese.sin_ativo AS hipotese_legal_ativa,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.usuario_orgao usuario
        ON usuario.id_orgao = atribuicao.id_orgao AND usuario.id_usuario = ?
      JOIN dbo.tipo_procedimento tipo
        ON tipo.versao = atribuicao.versao
        AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      JOIN dbo.consulta_orgao grupo
        ON grupo.id_consulta = atribuicao.id_consulta
        AND grupo.id_orgao = atribuicao.id_orgao
      LEFT JOIN dbo.visualizacao_tipo visualizacao
        ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.hipotese_legal hipotese
        ON hipotese.id_hipotese_legal = tipo.id_hipotese_legal_sugestao
      WHERE atribuicao.id_atribuicao = ?
"""

RODADAS = """
SELECT consulta.id_consulta, consulta.nome, consulta.versao
      FROM dbo.consulta consulta
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      WHERE usuario.sin_admin = 'S'
        OR EXISTS (
          SELECT 1
          FROM dbo.consulta_orgao grupo
          JOIN dbo.usuario_orgao vinculo ON vinculo.id_orgao = grupo.id_orgao
          WHERE grupo.id_consulta = consulta.id_consulta
            AND vinculo.id_usuario = usuario.id_usuario
        )
      ORDER BY consulta.id_consulta DESC
"""

INICIO = """
WITH atribuicoes AS (
        SELECT atribuicao.id_atribuicao, atribuicao.id_consulta, atribuicao.id_orgao,
          CASE WHEN visualizacao.id_atribuicao IS NULL THEN 0 ELSE 1 END AS visualizado,
          CASE WHEN visualizacao.id_atribuicao IS NOT NULL AND (
            manifestacao.decisao_tipo = 'DESCONTINUAR'
            OR (manifestacao.decisao_tipo = 'MANTER' AND NOT EXISTS (
            SELECT 1
            FROM dbo.rel_tipo_procedimento_assunto vinculo
            WHERE vinculo.versao = atribuicao.versao
              AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
              AND NOT EXISTS (
                SELECT 1
                FROM dbo.manifestacao_vinculo decisao
                WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                  AND decisao.id_assunto = vinculo.id_assunto_proxy
                  AND decisao.acao IN ('MANTER', 'REMOVER')
              )
          ))) THEN 1 ELSE 0 END AS analisado
        FROM dbo.consulta_orgao_tipo atribuicao
        LEFT JOIN dbo.visualizacao_tipo visualizacao
          ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
        LEFT JOIN dbo.manifestacao_tipo manifestacao
          ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
        WHERE atribuicao.id_consulta = ?
      )
      SELECT grupo.id_orgao, orgao.sigla, grupo.status, grupo.data_finalizacao,
        COUNT(atribuicao.id_atribuicao) AS atribuidos,
        COALESCE(SUM(atribuicao.visualizado), 0) AS visualizados,
        COALESCE(SUM(atribuicao.analisado), 0) AS analisados
      FROM dbo.consulta_orgao grupo
      JOIN dbo.orgao orgao ON orgao.id_orgao = grupo.id_orgao
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      LEFT JOIN atribuicoes atribuicao
        ON atribuicao.id_consulta = grupo.id_consulta AND atribuicao.id_orgao = grupo.id_orgao
      WHERE grupo.id_consulta = ?
        AND (
          usuario.sin_admin = 'S'
          OR EXISTS (
            SELECT 1
            FROM dbo.usuario_orgao vinculo
            WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
          )
        )
      GROUP BY grupo.id_orgao, orgao.sigla, grupo.status, grupo.data_finalizacao
      ORDER BY orgao.sigla
"""

MANIFESTACAO = """
SELECT observacao, revisao, decisao_tipo, justificativa_tipo
      FROM dbo.manifestacao_tipo
      WHERE id_atribuicao = ?
"""

DECISOES = """
SELECT assunto.*, manifestacao.acao, manifestacao.justificativa
      FROM dbo.manifestacao_vinculo manifestacao
      JOIN dbo.assunto assunto
        ON assunto.versao = manifestacao.versao
        AND assunto.id_assunto = manifestacao.id_assunto
      WHERE manifestacao.id_atribuicao = ?
      ORDER BY assunto.codigo_estruturado
"""

ESTRUTURAIS = """
SELECT assunto.id_assunto
      FROM dbo.assunto assunto
      JOIN OPENJSON(?) WITH (id_assunto int '$.id_assunto') inclusao
        ON inclusao.id_assunto = assunto.id_assunto
      WHERE assunto.versao = ? AND assunto.sin_estrutural = 'S'
        AND NOT EXISTS (
          SELECT 1 FROM dbo.manifestacao_vinculo existente
          WHERE existente.id_atribuicao = ?
            AND existente.versao = assunto.versao
            AND existente.id_assunto = assunto.id_assunto
            AND existente.acao = 'ADICIONAR'
        )
"""

RESUMO = """
SELECT grupo.*, consulta.nome AS consulta, orgao.sigla,
        CASE WHEN EXISTS (
          SELECT 1 FROM dbo.usuario_orgao vinculo
          WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
        ) THEN 'S' ELSE 'N' END AS pode_revisar
      FROM dbo.consulta_orgao grupo
      JOIN dbo.consulta consulta ON consulta.id_consulta = grupo.id_consulta
      JOIN dbo.orgao orgao ON orgao.id_orgao = grupo.id_orgao
      JOIN dbo.usuario usuario ON usuario.id_usuario = ? AND usuario.sin_ativo = 'S'
      WHERE grupo.id_consulta = ? AND grupo.id_orgao = ?
        AND (
          usuario.sin_admin = 'S'
          OR EXISTS (
            SELECT 1 FROM dbo.usuario_orgao vinculo
            WHERE vinculo.id_usuario = usuario.id_usuario AND vinculo.id_orgao = grupo.id_orgao
          )
        )
"""

RESUMO_TIPOS = """
SELECT atribuicao.id_atribuicao, tipo.nome, manifestacao.observacao,
        manifestacao.decisao_tipo, manifestacao.justificativa_tipo,
        CASE WHEN visualizacao.id_atribuicao IS NULL THEN 'N' ELSE 'S' END AS visualizado,
        (
          SELECT COUNT(*)
          FROM dbo.rel_tipo_procedimento_assunto vinculo
          WHERE vinculo.versao = atribuicao.versao
            AND vinculo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
            AND NOT EXISTS (
              SELECT 1
              FROM dbo.manifestacao_vinculo decisao
              WHERE decisao.id_atribuicao = atribuicao.id_atribuicao
                AND decisao.id_assunto = vinculo.id_assunto_proxy
                AND decisao.acao IN ('MANTER', 'REMOVER')
            )
        ) AS pendentes
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.tipo_procedimento tipo
        ON tipo.versao = atribuicao.versao
        AND tipo.id_tipo_procedimento = atribuicao.id_tipo_procedimento
      LEFT JOIN dbo.manifestacao_tipo manifestacao
        ON manifestacao.id_atribuicao = atribuicao.id_atribuicao
      LEFT JOIN dbo.visualizacao_tipo visualizacao
        ON visualizacao.id_atribuicao = atribuicao.id_atribuicao
      WHERE atribuicao.id_consulta = ? AND atribuicao.id_orgao = ?
      ORDER BY tipo.nome
"""

RESUMO_DECISOES = """
SELECT atribuicao.id_atribuicao, assunto.*, decisao.acao, decisao.justificativa
      FROM dbo.consulta_orgao_tipo atribuicao
      JOIN dbo.manifestacao_tipo manifestacao
        ON manifestacao.id_atribuicao = atribuicao.id_atribuicao AND manifestacao.decisao_tipo = 'MANTER'
      JOIN dbo.manifestacao_vinculo decisao
        ON decisao.id_atribuicao = atribuicao.id_atribuicao
      JOIN dbo.assunto assunto
        ON assunto.versao = decisao.versao
        AND assunto.id_assunto = decisao.id_assunto
      WHERE atribuicao.id_consulta = ? AND atribuicao.id_orgao = ?
      ORDER BY atribuicao.id_atribuicao, assunto.codigo_estruturado
"""

ADMIN = """
SELECT id_usuario
      FROM dbo.usuario
      WHERE id_usuario = ?
        AND sin_ativo = 'S'
        AND sin_admin = 'S'
"""

ORGAOS = """
SELECT id_orgao, sigla
      FROM dbo.orgao
      ORDER BY sigla
"""

PROCESSAMENTO = """
SELECT a.id_atribuicao, a.id_consulta, a.id_orgao, a.versao,
        a.id_tipo_procedimento, t.nome, t.descricao, t.sin_interno,
        t.sin_ouvidoria, t.sin_individual, t.sin_ouvidoria_anonimo,
        t.id_hipotese_legal_sugestao, t.sta_nivel_acesso_sugestao,
        t.sta_grau_sigilo_sugestao, h.nome AS hipotese_legal_nome,
        h.base_legal AS hipotese_legal_base, o.sigla, c.nome AS consulta,
        m.decisao_tipo, m.justificativa_tipo,
        p.parecer AS parecer_tipo, u.nome AS responsavel_tipo,
        CONVERT(varchar(33), p.data_avaliacao, 126) + 'Z' AS data_avaliacao_tipo
      FROM dbo.consulta_orgao_tipo a
      JOIN dbo.consulta_orgao g ON g.id_consulta = a.id_consulta AND g.id_orgao = a.id_orgao
      JOIN dbo.consulta c ON c.id_consulta = a.id_consulta AND c.versao = a.versao
      JOIN dbo.orgao o ON o.id_orgao = a.id_orgao
      JOIN dbo.tipo_procedimento t ON t.versao = a.versao AND t.id_tipo_procedimento = a.id_tipo_procedimento
      LEFT JOIN dbo.hipotese_legal h ON h.id_hipotese_legal = t.id_hipotese_legal_sugestao
      LEFT JOIN dbo.manifestacao_tipo m ON m.id_atribuicao = a.id_atribuicao AND m.versao = a.versao
      LEFT JOIN dbo.avaliacao_setic_tipo p ON p.id_atribuicao = a.id_atribuicao
      LEFT JOIN dbo.usuario u ON u.id_usuario = p.id_usuario_avaliacao
      WHERE g.status = 'FINALIZADA'
      ORDER BY a.id_consulta DESC, o.sigla, a.id_orgao, t.nome, a.id_atribuicao
"""

PROCESSAMENTO_ASSUNTOS = """
SELECT a.id_atribuicao, s.*,
        v.acao, v.justificativa, p.parecer, u.nome AS responsavel,
        CONVERT(varchar(33), p.data_avaliacao, 126) + 'Z' AS data_avaliacao
      FROM dbo.consulta_orgao_tipo a
      JOIN dbo.consulta_orgao g ON g.id_consulta = a.id_consulta AND g.id_orgao = a.id_orgao
      JOIN dbo.manifestacao_tipo m ON m.id_atribuicao = a.id_atribuicao AND m.versao = a.versao
      JOIN dbo.manifestacao_vinculo v ON v.id_atribuicao = m.id_atribuicao AND v.versao = m.versao
      JOIN dbo.assunto s ON s.id_assunto = v.id_assunto AND s.versao = v.versao
      LEFT JOIN dbo.avaliacao_setic_assunto p ON p.id_atribuicao = v.id_atribuicao AND p.id_assunto = v.id_assunto
      LEFT JOIN dbo.usuario u ON u.id_usuario = p.id_usuario_avaliacao
      WHERE g.status = 'FINALIZADA' AND m.decisao_tipo = 'MANTER'
      ORDER BY a.id_atribuicao, s.codigo_estruturado, v.id_assunto
"""

AVALIAR = """
SET NOCOUNT ON; SET XACT_ABORT ON;
      BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @administrador int = ?, @atribuicao int = ?, @parecer varchar(8) = ?,
          @tem_assunto bit = ?, @assunto int = ?, @status varchar(12), @decisao varchar(15), @anterior varchar(8);
        IF NOT EXISTS (SELECT 1 FROM dbo.usuario WITH(HOLDLOCK)
          WHERE id_usuario = @administrador AND sin_ativo = 'S' AND sin_admin = 'S')
          THROW 51500, 'Administrador nao autorizado.', 1;
        SELECT @status = g.status FROM dbo.consulta_orgao_tipo a WITH(HOLDLOCK)
          JOIN dbo.consulta_orgao g WITH(HOLDLOCK)
            ON g.id_consulta = a.id_consulta AND g.id_orgao = a.id_orgao
          WHERE a.id_atribuicao = @atribuicao;
        IF @status IS NULL THROW 51501, 'Atribuicao inexistente.', 1;
        IF @status <> 'FINALIZADA' THROW 51502, 'Manifestacao ainda nao submetida.', 1;
        SELECT @decisao = m.decisao_tipo FROM dbo.manifestacao_tipo m WITH(HOLDLOCK)
          JOIN dbo.consulta_orgao_tipo a ON a.id_atribuicao = m.id_atribuicao AND a.versao = m.versao
          WHERE m.id_atribuicao = @atribuicao;
        IF @decisao IS NULL OR @decisao NOT IN ('MANTER','DESCONTINUAR')
          THROW 51505, 'Decisao do Tipo nao submetida.', 1;
        IF @tem_assunto = 1
        BEGIN
          IF @decisao <> 'MANTER' OR NOT EXISTS (
            SELECT 1 FROM dbo.manifestacao_vinculo v WITH(HOLDLOCK)
            JOIN dbo.consulta_orgao_tipo a ON a.id_atribuicao = v.id_atribuicao AND a.versao = v.versao
            JOIN dbo.assunto s ON s.id_assunto = v.id_assunto AND s.versao = v.versao
            WHERE v.id_atribuicao = @atribuicao AND v.id_assunto = @assunto)
            THROW 51503, 'Assunto nao pertence a decisao submetida.', 1;
          SELECT @anterior = parecer FROM dbo.avaliacao_setic_assunto WITH(UPDLOCK,HOLDLOCK)
            WHERE id_atribuicao = @atribuicao AND id_assunto = @assunto;
          IF @anterior IS NOT NULL AND @anterior <> @parecer THROW 51504, 'Avaliacao ja registrada.', 1;
          IF @anterior IS NULL
            INSERT dbo.avaliacao_setic_assunto(id_atribuicao,id_assunto,parecer,id_usuario_avaliacao)
              VALUES(@atribuicao,@assunto,@parecer,@administrador);
        END
        ELSE
        BEGIN
          SELECT @anterior = parecer FROM dbo.avaliacao_setic_tipo WITH(UPDLOCK,HOLDLOCK)
            WHERE id_atribuicao = @atribuicao;
          IF @anterior IS NOT NULL AND @anterior <> @parecer THROW 51504, 'Avaliacao ja registrada.', 1;
          IF @anterior IS NULL
            INSERT dbo.avaliacao_setic_tipo(id_atribuicao,parecer,id_usuario_avaliacao)
              VALUES(@atribuicao,@parecer,@administrador);
        END;
        COMMIT;
      END TRY
      BEGIN CATCH
        IF XACT_STATE() <> 0 ROLLBACK;
        THROW;
      END CATCH;
"""

DISTRIBUIR = """
SET NOCOUNT ON; SET XACT_ABORT ON;
      BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @administrador int=?, @tipo int=?, @versao int=?,
          @antes nvarchar(max)=?, @depois nvarchar(max)=?, @lock int;
        -- Mesma trava da carga 006: uma carga vê a distribuição inteira.
        EXEC @lock=sys.sp_getapplock @Resource='carga_atribuicoes',
          @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=15000;
        IF @lock<0 THROW 51400,'Distribuicao ocupada.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.usuario WITH(HOLDLOCK)
          WHERE id_usuario=@administrador AND sin_ativo='S' AND sin_admin='S')
          THROW 51401,'Administrador nao autorizado.',1;
        IF @versao<>(SELECT MAX(versao) FROM dbo.versao_base WITH(HOLDLOCK))
          THROW 51402,'A base publicada mudou.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.tipo_procedimento WITH(HOLDLOCK)
          WHERE versao=@versao AND id_tipo_procedimento=@tipo)
          THROW 51403,'Tipo inexistente nesta versao.',1;
        DECLARE @anteriores TABLE(id_orgao int PRIMARY KEY);
        DECLARE @selecionados TABLE(id_orgao int PRIMARY KEY);
        INSERT @anteriores SELECT CONVERT(int,value) FROM OPENJSON(@antes);
        INSERT @selecionados SELECT CONVERT(int,value) FROM OPENJSON(@depois);
        IF EXISTS(SELECT id_orgao FROM @anteriores EXCEPT
          SELECT id_orgao FROM dbo.tipo_procedimento_restricao WITH(UPDLOCK,HOLDLOCK)
          WHERE id_tipo_procedimento=@tipo)
          OR EXISTS(SELECT id_orgao FROM dbo.tipo_procedimento_restricao WITH(UPDLOCK,HOLDLOCK)
          WHERE id_tipo_procedimento=@tipo EXCEPT SELECT id_orgao FROM @anteriores)
          THROW 51404,'Vinculos alterados por outro administrador.',1;
        IF EXISTS(SELECT 1 FROM @selecionados s WHERE NOT EXISTS(
          SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=s.id_orgao))
          THROW 51405,'Orgao inexistente.',1;
        -- Somente a distribuição atual; não altera rodadas ou avaliações.
        DELETE FROM dbo.tipo_procedimento_restricao
          WHERE id_tipo_procedimento=@tipo AND id_orgao NOT IN(
            SELECT id_orgao FROM @selecionados);
        INSERT dbo.tipo_procedimento_restricao(id_tipo_procedimento,id_orgao)
          SELECT @tipo,s.id_orgao FROM @selecionados s WHERE NOT EXISTS(
            SELECT 1 FROM dbo.tipo_procedimento_restricao r
            WHERE r.id_tipo_procedimento=@tipo AND r.id_orgao=s.id_orgao);
        DECLARE @detalhe nvarchar(max)=(
            SELECT @tipo AS id_tipo_procedimento,@versao AS versao,
              JSON_QUERY(@antes) AS orgaos_antes,JSON_QUERY(@depois) AS orgaos_depois
            FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
        INSERT dbo.auditoria(id_usuario,evento,detalhe)
          VALUES(@administrador,'DISTRIBUICAO_TIPO',@detalhe);
        COMMIT;
      END TRY
      BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
      END CATCH;
"""

DISTRIBUIR_LOTE = """
SET NOCOUNT ON; SET XACT_ABORT ON;
      BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @administrador int=?, @versao int=?,
          @tiposJson nvarchar(max)=?, @orgaosJson nvarchar(max)=?, @lock int;
        EXEC @lock=sys.sp_getapplock @Resource='carga_atribuicoes',
          @LockMode='Exclusive', @LockOwner='Transaction', @LockTimeout=15000;
        IF @lock<0 THROW 51400,'Distribuicao ocupada.',1;
        IF NOT EXISTS(SELECT 1 FROM dbo.usuario WITH(HOLDLOCK)
          WHERE id_usuario=@administrador AND sin_ativo='S' AND sin_admin='S')
          THROW 51401,'Administrador nao autorizado.',1;
        IF @versao<>(SELECT MAX(versao) FROM dbo.versao_base WITH(HOLDLOCK))
          THROW 51402,'A base publicada mudou.',1;
        DECLARE @tipos TABLE(id_tipo_procedimento int PRIMARY KEY);
        DECLARE @orgaos TABLE(id_orgao int PRIMARY KEY);
        DECLARE @novos TABLE(id_tipo_procedimento int,id_orgao int);
        INSERT @tipos SELECT CONVERT(int,value) FROM OPENJSON(@tiposJson);
        INSERT @orgaos SELECT CONVERT(int,value) FROM OPENJSON(@orgaosJson);
        IF EXISTS(SELECT 1 FROM @tipos t WHERE NOT EXISTS(
          SELECT 1 FROM dbo.tipo_procedimento WITH(HOLDLOCK)
          WHERE versao=@versao AND id_tipo_procedimento=t.id_tipo_procedimento))
          THROW 51403,'Tipo inexistente nesta versao.',1;
        IF EXISTS(SELECT 1 FROM @orgaos o WHERE NOT EXISTS(
          SELECT 1 FROM dbo.orgao WITH(HOLDLOCK) WHERE id_orgao=o.id_orgao))
          THROW 51405,'Orgao inexistente.',1;
        -- Somente acrescenta os pares ausentes; preserva vínculos atuais.
        INSERT dbo.tipo_procedimento_restricao(id_tipo_procedimento,id_orgao)
          OUTPUT inserted.id_tipo_procedimento,inserted.id_orgao INTO @novos
          SELECT t.id_tipo_procedimento,o.id_orgao FROM @tipos t CROSS JOIN @orgaos o
          WHERE NOT EXISTS(SELECT 1 FROM dbo.tipo_procedimento_restricao r WITH(UPDLOCK,HOLDLOCK)
            WHERE r.id_tipo_procedimento=t.id_tipo_procedimento AND r.id_orgao=o.id_orgao);
        DECLARE @detalhe nvarchar(max)=(
          SELECT @versao AS versao,JSON_QUERY(@tiposJson) AS tipos,
            JSON_QUERY(@orgaosJson) AS orgaos,
            JSON_QUERY((SELECT id_tipo_procedimento,id_orgao FROM @novos
              ORDER BY id_tipo_procedimento,id_orgao FOR JSON PATH)) AS vinculos_incluidos
          FOR JSON PATH,WITHOUT_ARRAY_WRAPPER);
        INSERT dbo.auditoria(id_usuario,evento,detalhe)
          VALUES(@administrador,'DISTRIBUICAO_TIPOS',@detalhe);
        COMMIT;
        SELECT COUNT(*) AS vinculos_incluidos,
          COUNT(DISTINCT id_tipo_procedimento) AS tipos_alterados FROM @novos;
      END TRY
      BEGIN CATCH
        IF XACT_STATE()<>0 ROLLBACK;
        THROW;
      END CATCH;
"""

USUARIO = """
SELECT id_usuario, nome, email, sin_ativo, sin_admin, revisao
      FROM dbo.usuario
      WHERE id_usuario = ?
"""

USUARIO_ORGAOS = """
SELECT id_orgao
      FROM dbo.usuario_orgao
      WHERE id_usuario = ?
      ORDER BY id_orgao
"""

HISTORICO = """
SELECT id_evento, data_evento, evento, antes, depois,
        id_usuario_responsavel, responsavel_nome, responsavel_email
      FROM dbo.auditoria_administrativa
      WHERE id_usuario_alvo = ?
      ORDER BY id_evento DESC
      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY
"""

CATALOGO_VINCULOS = "\n      SELECT\n        rel.id_tipo_procedimento,\n        tipo.nome AS tipo_nome,\n        tipo.sin_ativo AS tipo_sin_ativo,\n        rel.id_assunto_proxy AS id_assunto,\n        assunto.codigo_estruturado AS assunto_codigo,\n        assunto.descricao AS assunto_descricao,\n        assunto.sin_ativo AS assunto_sin_ativo,\n        assunto.sin_estrutural,\n        assunto.prazo_corrente,\n        assunto.prazo_intermediario,\n        assunto.sta_destinacao,\n        assunto.observacao\n      FROM dbo.rel_tipo_procedimento_assunto rel\n      JOIN dbo.tipo_procedimento tipo\n        ON tipo.versao = rel.versao\n       AND tipo.id_tipo_procedimento = rel.id_tipo_procedimento\n      JOIN dbo.assunto assunto\n        ON assunto.versao = rel.versao\n       AND assunto.id_assunto = rel.id_assunto_proxy\n      WHERE rel.versao = ?\n      ORDER BY rel.id_tipo_procedimento, rel.sequencia\n    "

CATALOGO_ORGAOS = "\n      SELECT DISTINCT\n        atribuicao.id_tipo_procedimento,\n        orgao.id_orgao,\n        orgao.sigla,\n        orgao.nome\n      FROM dbo.consulta_orgao_tipo atribuicao\n      JOIN dbo.orgao orgao ON orgao.id_orgao = atribuicao.id_orgao\n      WHERE atribuicao.versao = ?\n      ORDER BY atribuicao.id_tipo_procedimento, orgao.sigla\n    "

CATALOGO_ARVORE = "WITH arvore AS (\n        SELECT raiz.versao, raiz.id_assunto, 0 AS nivel_hierarquia,\n          CAST(raiz.codigo_estruturado AS nvarchar(max)) AS caminho\n        FROM dbo.assunto raiz\n        WHERE raiz.versao = ?\n          AND (raiz.id_assunto_pai IS NULL OR NOT EXISTS (\n            SELECT 1 FROM dbo.assunto pai\n            WHERE pai.versao = raiz.versao AND pai.id_assunto = raiz.id_assunto_pai\n          ))\n        UNION ALL\n        SELECT filho.versao, filho.id_assunto, arvore.nivel_hierarquia + 1,\n          CAST(arvore.caminho + N'/' + filho.codigo_estruturado AS nvarchar(max))\n        FROM dbo.assunto filho\n        JOIN arvore ON filho.versao = arvore.versao\n          AND filho.id_assunto_pai = arvore.id_assunto\n      )\n      SELECT registro.*, arvore.nivel_hierarquia\n      FROM dbo.assunto registro\n      JOIN arvore ON arvore.versao = registro.versao\n        AND arvore.id_assunto = registro.id_assunto\n      WHERE {filtro}\n      ORDER BY arvore.caminho, registro.id_assunto\n      OFFSET ? ROWS FETCH NEXT 51 ROWS ONLY\n      OPTION (MAXRECURSION 100)"

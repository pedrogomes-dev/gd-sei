# Próxima etapa

Implementar `usuario`, `orgao`, `usuario_orgao`; `token_acesso` e `sessao` separados; `consulta`, `consulta_orgao`, `consulta_orgao_tipo`; `manifestacao_tipo`, `manifestacao_vinculo` e auditoria. Não criar administração por interface.

Escolher e validar o driver SQL Server para o ambiente de execução antes de adicionar dependência. Usar parâmetros SQL e transações; nunca concatenar dados do usuário. Configurar TLS no banco e SMTP.

Autenticação: token aleatório temporário de uso único, armazenado como hash, limite de tentativas e solicitações, resposta genérica para e-mail não cadastrado. Sessão independente, revogável no logout, com expiração e cookie HttpOnly/Secure/SameSite. Não registrar tokens em logs. Proteger operações mutáveis contra CSRF.

Autorizar no backend cada consulta, Tipo e manifestação pelo vínculo usuário × órgão × consulta. Fixar versão da base na consulta e usar chaves estrangeiras compostas para impedir vínculos entre versões. A autorização não depende de esconder componentes no frontend.

Vínculo existente: MANTER (justificativa opcional), REMOVER (obrigatória). Novo vínculo: ADICIONAR (obrigatória). Pesquisa apenas de assuntos ativos da versão da consulta por código, descrição, observação e índice. Tipo tem apenas observação geral.

RASCUNHO permite alterações. FINALIZADA bloqueia alterações normais, sem reabertura. Gravação e finalização devem bloquear a mesma manifestação na transação, evitando alterações concorrentes após finalizar. Auditoria append-only de login, logout, alterações, propostas e finalização, sem sobrescrever histórico.

Ainda precisa definir com o responsável: manifestação compartilhada por órgão ou individual por usuário; finalização por Tipo ou por consulta/órgão. Não inferir essas regras no código.

Rotas de tela preparadas: /login, /verificar-token, /inicio, /tipos, /tipos/{id}, /resumo. /tipos/{id} concentrará propriedades, vínculos, pesquisa, justificativas, observação e salvar.

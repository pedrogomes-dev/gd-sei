# Administração de usuários

Primeira etapa: cadastro/edição de nome e e-mail, múltiplos órgãos, acesso ativo/inativo, perfil administrador e histórico administrativo. Não exclui usuários ou manifestações. Não cria órgãos nem modifica sua distribuição de processos. Administrador continua precisando de vínculo com órgão para avaliar.

## Instalação

1. Fazer backup e executar uma vez `database/007_administracao.sql` em `sei_gd`, após 005, com compatibilidade SQL >=130. O script exige `pg@setic.ro.gov.br` ativo, mantém seu cadastro/vínculos e o promove a administrador com evento de bootstrap. E-mails duplicados após normalização impedem a instalação. Não executar novamente scripts 001–005.
2. Atualizar backend/frontend juntos; executar `dart analyze`, `flutter analyze`, `flutter build web` e reiniciar ambos. O código novo depende da migração. Entrar novamente com o acesso de teste existente.
3. Abrir Administração > Usuários. Cadastros anteriores permanecem com nome não informado; preencher pela edição, sem inferir nome do e-mail.

Nome e e-mail são obrigatórios ao salvar; e-mail é normalizado para minúsculas e sem espaços externos, com índice único normalizado. Usuários podem ficar sem órgão; nessa situação não terão processos atribuídos disponíveis. Perfil administrativo dá acesso à gestão global, não à avaliação de órgãos sem vínculo. É permitido retirar o próprio perfil ou desativar o próprio acesso, inclusive do último administrador, conforme a decisão do responsável.

## Auditoria e concorrência

`sp_salvar_usuario` valida administrador ativo dentro da transação, verifica órgãos/e-mail e revisão esperada, salva cadastro/vínculos e insere o evento antes/depois na mesma transação. Um lock de aplicação serializa alterações administrativas para impedir retirada concorrente de permissão do responsável. Revisão obsoleta retorna conflito sem sobrescrever: cancelar a edição e abrir novamente para recarregar.

`auditoria_administrativa` registra alvo, responsável, nome/e-mail do responsável no momento do evento, data UTC e snapshots de nome/e-mail/situação/perfil/órgãos. Trigger bloqueia UPDATE/DELETE. A aplicação só expõe consulta paginada; datas são apresentadas no fuso do navegador. Não registra tokens. A conta SQL da aplicação não deve ter ALTER/TRUNCATE nem privilégios de proprietário; conceder consulta e execução das procedures necessárias, evitando alterações diretas de usuários, vínculos e histórico.

Alterar e-mail, situação, perfil ou órgãos incrementa `versao_sessao`. Cada requisição verifica a versão e o usuário ativo: sessões anteriores ficam inválidas mesmo após reativação. Sessões de desenvolvimento ainda são em memória e expiram em oito horas. Alterar somente o nome não revoga a sessão. A tela volta ao login após alterar as próprias permissões; alterar o e-mail do usuário de teste impede o login fixo existente. Não há bloqueio contra essa alteração.

## API

- GET `/api/admin/orgaos`: lista órgãos existentes (ID/sigla).
- GET `/api/admin/usuarios?q=...&estado=TODOS|S|N&orgao=ID&offset=0`: busca nome/e-mail, filtros, total e páginas de 50.
- GET `/api/admin/usuarios/ID`: cadastro e IDs dos órgãos vinculados.
- POST `/api/admin/usuarios` ou `/api/admin/usuarios/ID`: `{nome,email,sin_ativo,sin_admin,revisao,orgaos:[IDs]}`; revisão 0 para criação.
- GET `/api/admin/usuarios/ID/historico?offset=0`: eventos, responsável e antes/depois, páginas de 50.

Todos os endpoints exigem administrador ativo no backend. IDs de órgãos não dependem de identity; consultas usam sigla e funcionam com a coluna de descrição atual. Origem permitida, cookies e autorização por órgão das manifestações continuam existentes.

## Homologação

O ambiente de edição não tem Dart/Flutter nem SQL Server: análise, compilação e testes SQL ainda precisam ser executados no destino. `database/tests/administracao.sql` usa fixtures com rollback, somente em homologação; identidades podem avançar. Testa criação, normalização, vínculos, revisão, snapshots, revogação, auto-desativação, autorização, duplicidade, órgão inválido e imutabilidade.

No navegador: conferir lista, filtros combinados, total/paginação, nome longo e rolagem; criar/editar usuário, vincular/desvincular órgãos e verificar histórico; abrir a edição em duas abas e confirmar conflito na segunda. Conferir HTTP 403 nas rotas administrativas com usuário não administrador. Enquanto o login é fixo, essa última verificação pode ser feita retirando temporariamente o perfil do usuário de teste em base de homologação e restaurando-o por script do operador. Conferir também sessão inválida após alteração de permissão e após desativar/reativar, inclusive em outra aba. Preenchimento perdido por conflito deve ser reaplicado após recarregar.

Autenticação por e-mail, tokens de uso único, sessões persistentes, trilha de autenticação e indicadores de quantidade/último acesso pertencem à segunda etapa. Novos usuários cadastrados ainda não podem entrar pelo bypass fixo. Esta etapa não apresenta contadores de acesso incompletos como se fossem definitivos.

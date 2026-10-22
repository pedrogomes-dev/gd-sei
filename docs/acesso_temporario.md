# Acesso temporário e consulta de Tipos

Executar uma vez `database/004_consultas.sql` no banco `sei_gd`. Cria usuário pg@setic.ro.gov.br, órgãos, consultas, atribuições, visualizações e auditoria. Não atribui órgãos ou Tipos automaticamente. A base versionada já carregada é preservada.

Em backend/.env habilite:

```dotenv
APP_ENV=development
DEV_AUTH_ENABLED=true
COOKIE_SECURE=false
```

Na tela de login, selecione **Personificar usuário ativo** e clique em **Entrar como usuário selecionado**. A lista só inclui usuários ativos; o backend confere novamente o ID no momento do login. O token conhecido `123456` continua como bypass de desenvolvimento, sem envio de e-mail. O exemplo permanece desativado. O backend recusa habilitar fora de APP_ENV=development. Em produção, DEV_AUTH_ENABLED=false e COOKIE_SECURE=true/HTTPS. Veja [ambientes.md](ambientes.md) para o fluxo dev/main e a pendência de proteção no GitHub.

A sessão usa cookie HttpOnly independente do token temporário, dura oito horas e é revogada no logout. Nesta etapa fica em memória: reiniciar o backend exige novo login. A autenticação por e-mail já está implementada e homologada. A sessão usa o perfil e os órgãos reais do usuário escolhido, sem permissões adicionais; LOGIN_DEV audita o ID escolhido. O bypass permanece somente para desenvolvimento e nunca deve ser habilitado em ambiente público.

Execute o backend e o Flutter Web conforme README. Use localhost nos dois, sem misturar localhost com 127.0.0.1. Origem do frontend deve corresponder a ALLOWED_ORIGIN.

Cadastre manualmente órgão, vínculo usuario_orgao, consulta apontando à versão, consulta_orgao e consulta_orgao_tipo. Sem atribuições, a tela fica vazia; isso não é falha de login. Não inventar órgão ou atribuir todos os Tipos ao usuário por causa do bypass.

As chaves estrangeiras exigem a mesma versão em consulta e Tipo. Todos os acessos são autorizados no backend por usuario_orgao. As URLs de detalhe usam id_atribuicao (identifica consulta, órgão e Tipo), evitando ambiguidade quando um Tipo aparece em mais de uma consulta/órgão.

A confirmação de visualização é explícita após abrir o detalhe. O backend registra o primeiro usuário e data, por atribuição, sem sobrescrever. A finalização por órgão, salvamento de manifestação e pesquisa de Assuntos estão implementados; veja docs/manifestacoes.md.

Login e logout registram auditoria sem tokens. GET não altera visualização; POST exige origem autorizada. Instalação e teste de compilação/execução permanecem pendentes no ambiente de destino.

## Diagnosticar falhas

Execute `dart run bin/check_schema.dart` a partir de backend. Verifica as oito tabelas operacionais e o usuário de teste, apenas com SELECT. OBJECT_ID nulo também pode significar falta de permissão. Em APP_ENV=development, falhas de banco mostram etapa, SQLSTATE e código, sem mensagens brutas, parâmetros ou credenciais. Falhas de desconexão não escondem a falha original.

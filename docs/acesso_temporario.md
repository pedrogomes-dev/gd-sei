# Acesso temporário e consulta de Tipos

Executar uma vez `database/004_consultas.sql` no banco `sei_gd`. Cria usuário pg@setic.ro.gov.br, órgãos, consultas, atribuições, visualizações e auditoria. Não atribui órgãos ou Tipos automaticamente. A base versionada já carregada é preservada.

Em backend/.env habilite:

```dotenv
APP_ENV=development
DEV_AUTH_ENABLED=true
COOKIE_SECURE=false
```

Acesso pelo frontend: e-mail `pg@setic.ro.gov.br`, token `123456`. O token é um bypass explícito somente de desenvolvimento, sem envio de e-mail. A configuração padrão no exemplo é desativada. O backend recusa habilitar fora de APP_ENV=development. Em produção desativar o bypass e usar COOKIE_SECURE=true/HTTPS.

A sessão usa cookie HttpOnly independente do token temporário, dura oito horas e é revogada no logout. Nesta etapa fica em memória: reiniciar o backend exige novo login. Persistência de sessao/token_acesso e autenticação por e-mail ainda serão implementadas. Não habilitar esse acesso fixo em ambiente público.

Execute o backend e o Flutter Web conforme README. Use localhost nos dois, sem misturar localhost com 127.0.0.1. Origem do frontend deve corresponder a ALLOWED_ORIGIN.

Cadastre manualmente órgão, vínculo usuario_orgao, consulta apontando à versão, consulta_orgao e consulta_orgao_tipo. Sem atribuições, a tela fica vazia; isso não é falha de login. Não inventar órgão ou atribuir todos os Tipos ao usuário por causa do bypass.

As chaves estrangeiras exigem a mesma versão em consulta e Tipo. Todos os acessos são autorizados no backend por usuario_orgao. As URLs de detalhe usam id_atribuicao (identifica consulta, órgão e Tipo), evitando ambiguidade quando um Tipo aparece em mais de uma consulta/órgão.

A confirmação de visualização é explícita após abrir o detalhe. O backend registra o primeiro usuário e data, por atribuição, sem sobrescrever. A futura finalização por órgão exigirá todas as visualizações. Ainda não há salvar manifestação, pesquisa de Assuntos ou finalização.

Login e logout registram auditoria sem tokens. GET não altera visualização; POST exige origem autorizada. Instalação e teste de compilação/execução permanecem pendentes no ambiente de destino.

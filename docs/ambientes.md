# Ambientes e branches

Fluxo: branches de trabalho → `dev` → PR para `main`.
`dev` recebe desenvolvimento/testes; `main` é a linha estável. O CI executa
`backend` e `frontend` em pushes e PRs para ambas. Não há deploy automático.

Após promover ou integrar alterações pela `main`, sincronizar também a `dev`
com essa integração antes de continuar o desenvolvimento. Um merge na `main`
não atualiza automaticamente a `dev` nem a aplicação já em execução. Reiniciar
backend e frontend após trocar de branch, especialmente em mudanças de login.
A opção **Administração → Processamento das submissões** exige usuário administrador;
o seletor de testes respeita o perfil real do usuário escolhido.

| Configuração | Desenvolvimento | Produção |
| --- | --- | --- |
| APP_ENV | development | production |
| DEV_AUTH_ENABLED | true para testar usuários | false |
| COOKIE_SECURE | false somente no HTTP local | true com HTTPS |
| Login | e-mail/código ou personificação de ativo | e-mail/código |

A branch não é mecanismo de segurança: cada instância deve receber a configuração
correta. `main` executada localmente em ambiente de desenvolvimento também usa
as configurações locais. Não versionar `.env` nem credenciais. Usar uma base de
testes no desenvolvimento: personificar não simula nem desfaz as operações
realizadas pelo usuário. Esta alteração não cria/copia/modifica o banco.

Para ativar localmente, ajuste `backend/.env` e reinicie o backend:

```dotenv
APP_ENV=development
DEV_AUTH_ENABLED=true
COOKIE_SECURE=false
```

Na tela de login, escolha **Personificar usuário ativo** e clique em
**Entrar como usuário selecionado**. Não há escolha automática. A lista contém
somente ativos e o backend confere novamente o cadastro ao entrar. A sessão
preserva órgãos, perfil comum/admin, revogação e cookie/auditoria existentes.
O evento LOGIN_DEV usa o ID escolhido. O login por e-mail permanece disponível.
No VS Code o backend continua lendo o `.env` pelo cwd já configurado.

`GET /api/auth/config` retorna IDs, nomes e e-mails apenas com o bypass habilitado;
desativado, retorna somente `acesso_temporario: false`, sem consultar usuários.
`POST /api/auth/dev` recebe `id_usuario` e o token de desenvolvimento `123456`.
O token conhecido não é senha nem proteção para ambiente público; a barreira é
a configuração exclusiva de desenvolvimento. Não habilitar em produção.

## Proteção da main

Configuração aplicada e conferida no GitHub: Pull Request, zero aprovações obrigatórias,
checks `backend` e `frontend` passando, branch atualizada antes do merge e regras
também para administradores. Bloquear force push e exclusão. Sem merge automático.

Em 22/10/2026, a aplicação pela API e a leitura posterior confirmaram os checks
`backend` e `frontend`, `strict=true`, zero revisores, `enforce_admins=true`,
force push e exclusão desativados. Os nomes dos checks foram conferidos nas
execuções existentes do GitHub Actions.

Na consulta final o repositório estava público. Esta implementação não mudou
a visibilidade nem contratou plano. Se a visibilidade ou o plano mudarem,
conferir novamente a disponibilidade e a aplicação das regras de proteção.

## Verificações da implementação

`dart analyze` e `flutter analyze`: sem apontamentos. `dart test`: dez testes,
incluindo quatro novos de login de desenvolvimento. `flutter test`: dezesseis,
incluindo três novos de tela de login. Cobrem bloqueio fora de desenvolvimento,
lista de ativos, seleção obrigatória, perfil/órgão escolhido, auditoria e revogação.
Testes HTTP usam banco simulado; widgets usam API simulada. Não equivalem a
homologação manual com sessão/SQL Server reais. Nenhum banco foi modificado.
`flutter build web` passou, com o aviso preexistente de fonte CupertinoIcons.
Formatação verificada apenas nos arquivos alterados. O cliente HTTP web conserva
`withCredentials=true`; sua criação foi isolada por import condicional para os
testes de widgets executarem na VM, sem alterar os cookies do navegador.

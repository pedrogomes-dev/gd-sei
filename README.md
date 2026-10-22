# Sistema de Validação de Tipos e Assuntos do SEI

MVP funcional para apoio à Gestão Documental do SEI, com backend Dart, frontend Flutter Web e base SQL Server versionada. O sistema não altera diretamente o SEI oficial.

Estão implementados e homologados os fluxos principais de autenticação por e-mail, consulta por órgão, pesquisa de Assuntos, manifestação, resumo, submissão, autorização entre usuário comum/administrador e interface web. Permanecem pendentes a homologação da instalação completa em banco novo, o teste de concorrência da distribuição e a implantação efetiva no OpenShift.

## Organização

- `backend/lib`: config, routes, controllers, services, repositories e models.
- `frontend/lib`: screens, services e widgets.
- `database`: instalação, publicação, procedures e roteiros de validação.
- `docs`: regras funcionais, instalação, operação e produção.

## Executar

Para iniciar backend e frontend juntos pelo Run and Debug do VS Code, veja
[docs/vscode.md](docs/vscode.md).

Instale Dart >=3.4 e Flutter estável compatível. No backend:

```bash
cd backend
dart pub get
dart analyze
dart run bin/server.dart
```

O processo lê variáveis do ambiente e carrega o arquivo local `backend/.env` quando executado a partir de `backend`; o ambiente do sistema tem precedência. Copie `.env.example` para `.env` e configure os valores. Não versionar `.env`, senhas, certificados ou strings de conexão.

A conexão SQL Server utiliza ODBC; veja `docs/configuracao_banco.md` e execute `dart run bin/check_database.dart`. A autenticação normal utiliza código enviado por e-mail via SMTP. O acesso temporário permanece somente para desenvolvimento e deve ficar desativado em produção.

Em outro terminal:

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

`API_BASE_URL` é pública: nunca passar segredos com `--dart-define`. Em produção, frontend e API devem ser publicados por HTTPS na mesma origem, usando o proxy reverso do frontend.

## Banco

Crie um banco vazio no SQL Server 2016 SP1 ou posterior, compatibilidade >=130.
Siga a sequência completa em [docs/instalacao_banco.md](docs/instalacao_banco.md):

`001 → 009 → 002 → carga/publicação → 004 → 005 → 006 → 007 → 008`.

O complemento 009 provisiona a hierarquia e referências complementares usadas pelo código; não carrega dados. Use uma ferramenta que interprete `GO`. Carregue as referências autorizadas do SEI, incluindo `id_assunto_pai` explícito, e publique:

```sql
EXEC dbo.sp_publicar_versao_sei
 @usuario_carga=N'operador', @origem=N'Carga manual do SEI', @observacao=N'Carga inicial';
```

Primeira publicação = versão 0. Publicações seguintes preservam o histórico. As referências atuais foram conferidas e estão corretas; a instalação completa em banco novo continua pendente de homologação.

Referências aceitam INSERT controlado, mas UPDATE/DELETE são bloqueados conforme a política de imutabilidade. O usuário SQL da aplicação não deve executar publicação, alterar snapshots nem possuir privilégios administrativos. Consulte `docs/producao.md` para a configuração operacional de produção.

## Git

Processamento posterior à submissão pela SETIC:
[docs/processamento_submissoes.md](docs/processamento_submissoes.md).

Runner padrão, comandos de testes, CI mínimo e limites das verificações:
[docs/testes_ci.md](docs/testes_ci.md). O CI usa Dart 3.13.2 e Flutter 3.47.2.

Repositório: https://github.com/pedrogomes-dev/gd-sei — branch `main`.

```bash
git clone https://github.com/pedrogomes-dev/gd-sei.git
cd gd-sei
```

## Interface

A aplicação possui Início, Validação, Resumo e submissão, Catálogos e Administração. A interface principal e os fluxos de manifestação/submissão foram homologados. Consulte `docs/interface.md`, `docs/inicio.md` e `docs/manifestacoes.md`.

## Administração

Cadastro/edição de usuários, vínculos com órgãos, acesso ativo/inativo, perfil administrador, histórico administrativo e distribuição de Tipos estão implementados. A autenticação por e-mail também está implementada e homologada.

Administrador possui visão global de acompanhamento, mas a avaliação e submissão continuam condicionadas ao vínculo do usuário com o órgão correspondente, conforme validação no backend.

## Produção

Antes da disponibilização:

- homologar a instalação completa em banco novo;
- concluir o teste concorrente da distribuição com duas sessões e carga 006;
- implantar e validar backend/frontend no OpenShift;
- usar HTTPS;
- manter `DEV_AUTH_ENABLED=false`;
- usar `COOKIE_SECURE=true`;
- armazenar credenciais de banco e SMTP em Secrets;
- iniciar o backend com uma única réplica enquanto sessões e códigos permanecerem em memória.

Detalhes em [docs/producao.md](docs/producao.md).

## Validação

`database/003_validacao.sql` e `database/tests/` contêm roteiros de validação. Não considerar a existência dos scripts como homologação da instalação. Testes com escrita devem ser executados em banco descartável ou ambiente de homologação.

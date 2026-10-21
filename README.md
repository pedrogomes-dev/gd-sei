# Sistema de Validação de Tipos e Assuntos do SEI

MVP em desenvolvimento: backend Dart, frontend Flutter Web e base SQL versionada. Não altera o SEI oficial. Acesso temporário de desenvolvimento, consulta por órgão, pesquisa de Assuntos, rascunhos, resumo e submissão implementados. Autenticação por e-mail ainda pendente.

## Organização

- `backend/lib`: config, routes, controllers, services, repositories e models.
- `frontend/lib`: screens e services; componentes Flutter padrão.
- `database`: instalação, publicação e roteiro de validação.
- `docs`: regras e próximas etapas.

## Executar

Instale Dart >=3.4 e Flutter estável compatível. No backend:

```bash
cd backend
dart pub get
dart analyze
dart run bin/server.dart
```

O processo lê variáveis do ambiente e carrega o arquivo local `backend/.env` quando executado a partir de `backend`; o ambiente do sistema tem precedência. Copie `.env.example` para `.env` e configure os valores. Não versionar `.env`, senhas, certificados ou strings de conexão. A conexão SQL Server está preparada com ODBC; veja `docs/configuracao_banco.md` e execute `dart run bin/check_database.dart`. SMTP e autenticação por e-mail ainda não implementados. Para acesso temporário, execute `database/004_consultas.sql` e siga `docs/acesso_temporario.md`. Para manifestações, execute `database/005_manifestacoes.sql` e siga `docs/manifestacoes.md`.

Em outro terminal:

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

`API_BASE_URL` é pública: nunca passar segredos com `--dart-define`. O backend aceita a origem exata definida em `ALLOWED_ORIGIN`. Em produção usar HTTPS e servir frontend/API na mesma origem por proxy.

## Banco

Crie um banco vazio no SQL Server 2016 SP1 ou posterior, compatibilidade >=130.
Siga a sequência completa em [docs/instalacao_banco.md](docs/instalacao_banco.md):
`001 → 009 → 002 → carga/publicação → 004 → 005 → 006 → 007 → 008`.
O complemento 009 provisiona a hierarquia e as referências usadas pelo código;
não carrega dados. Use uma ferramenta que interprete `GO`. Os scripts antigos
de instalação não são migrações repetíveis. Carregue manualmente assuntos
(incluindo `id_assunto_pai` explícito), tipos e vínculos nessa ordem e publique:

```sql
EXEC dbo.sp_publicar_versao_sei
 @usuario_carga=N'operador', @origem=N'Carga manual do SEI', @observacao=N'Carga inicial';
```

Primeira publicação = versão 0. Publicações seguintes preservam o histórico. A publicação bloqueia cargas simultâneas e é atômica. `versao_base` é inserida antes das cópias para satisfazer as chaves estrangeiras, na mesma transação.

Referências aceitam INSERT manual, mas UPDATE/DELETE são bloqueados. Não usar TRUNCATE: o operador de carga não deve ter ALTER nem privilégios de proprietário. Sem alteração/exclusão, os snapshots futuros representam a referência acumulada; substituição ou correção integral da fonte requer procedimento administrativo específico, fora desta etapa.

O usuário da aplicação não deve ter acesso às `ref_*`, executar publicação ou alterar snapshots. Consultas futuras devem usar a versão da consulta, nunca apenas `sin_ultima`. Permissões específicas serão adicionadas com as tabelas operacionais.

## Git

Runner padrão, comandos de testes, CI mínimo e limites das verificações:
[docs/testes_ci.md](docs/testes_ci.md). O CI usa Dart 3.13.2 e Flutter 3.47.2.

Repositório: https://github.com/pedrogomes-dev/gd-sei — branch `main`.

```bash
git clone https://github.com/pedrogomes-dev/gd-sei.git
cd gd-sei
```

## Interface

Cabeçalho com identificação da sessão, menu Validação/Catálogo, tabelas de revisão e catálogo somente leitura por versão autorizada. Consulte `docs/interface.md` para comportamento e roteiro de homologação. Esta etapa não requer migração SQL.

## Administração

Cadastro de nome/e-mail, vínculos com órgãos, acesso ativo/inativo, perfil administrador e histórico antes/depois: executar uma vez `database/007_administracao.sql` após 005 e seguir `docs/administracao.md`. O usuário de teste existente é promovido a administrador inicial. Atualizar e reiniciar backend/frontend juntos após a migração. Autenticação por e-mail e indicadores de acesso permanecem na etapa seguinte.

## Validação

Veja `database/003_validacao.sql`. Compilação Dart/Flutter e execução SQL precisam ser feitas em ambiente com SDKs e SQL Server. Nenhuma dessas execuções foi realizada no ambiente de criação.



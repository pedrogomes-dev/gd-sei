# Runner, analisadores e CI — 21/10/2026

Branch criada de `origin/main` atualizada: `chore/testes-analise-ci`.
Ambiente local: Windows, Dart 3.13.2 e Flutter 3.47.2. O CI fixa essas versões
em dois jobs Ubuntu, com dependências, format check, análise, testes e build web.
Dispara em PRs para main, pushes na main e manualmente. Não há deploy nem segredos
ou conexão de banco necessários aos jobs.

## Runner do backend

`package:test` é uma dependência exclusivamente de desenvolvimento. O lockfile
foi atualizado. Execute `dart pub get` e `dart test` a partir de `backend`.
Os quatro programas anteriores registram agora um teste cada, mantendo os mesmos
cenários/assertivas e os fechamentos de cliente/servidor no `finally`.
Dois testes novos verificam a leitura da configuração em subprocessos isolados.
O runner executa seis testes, sem conexão SQL ou SMTP real.

As integrações SQL continuam executáveis separados e não são descobertas por
`dart test` (não possuem mais o sufixo `_test.dart`):

```powershell
cd backend
dart run test/assuntos_estruturais_sql.dart
dart run test/distribuicao_sql.dart
```

Não foram executadas nesta tarefa. Exigem SQL Server/ODBC e configuração própria;
a segunda usa tabelas temporárias. O conteúdo dos dois executáveis foi preservado,
sem mudanças na distribuição concorrente ou na hierarquia. Não houve acesso ao
banco nesta tarefa.

## Correções dos analisadores

- `settings.dart`: substitui `DotEnv.map` (reservado a testes) por `DotEnv.addAll`
  e leitura pública por `[]`. Todos os consumidores existentes usam `[]`.
  Preserva valores, parsing, aspas/interpolação, ausência do arquivo e precedência
  do ambiente, inclusive valores vazios. Não introduz parser ou camada nova.
- `inicio_screen.dart`, `tipos_screen.dart` e `user_filters.dart`: troca o
  argumento obsoleto `value` por `initialValue` no `DropdownButtonFormField`.
  A API instalada já mapeava `value` para `initialValue` e mantém a atualização
  do estado quando essa propriedade muda. Teste cobre atualização externa,
  órgão 0, retorno a todos e seleção pelo usuário.
- `resumo_tipo_card.dart`: remove somente a variável local `idAssunto` não usada.

`StatusTag` e seu arquivo `display_fields.dart` permanecem intactos. Não há
alterações funcionais, visuais, de instalação do banco ou de OpenShift.

## Formatação incremental

Por escolha do responsável, não foi reformatado o legado inteiro. A checagem
inicial completa encontrou 18 arquivos do backend e 23 do frontend fora do padrão.
Essa checagem global retornou 1 e não representa o escopo final aprovado.

`.github/scripts/check-format.sh` verifica somente arquivos Dart adicionados,
copiados, modificados ou renomeados na comparação com a base:

- PR: SHA da base do PR contra HEAD (checkout com histórico completo).
- Push: SHA anterior contra HEAD.
- Disparo manual sem base: último commit (`HEAD^`).

Arquivos removidos e `backend/vendor` não entram. A lista usa separadores NUL
para suportar espaços nos nomes. Um erro do Git ou do formatador falha o step.
Não há exceção permanente para `StatusTag`: como seu arquivo não foi alterado,
ele fica fora da comparação desta tarefa.

Na raiz do repositório, com Bash disponível:

```bash
FORMAT_BASE=origin/main bash .github/scripts/check-format.sh backend
FORMAT_BASE=origin/main bash .github/scripts/check-format.sh frontend
```

Execute após registrar as alterações, pois a comparação usa os commits até HEAD.
Os arquivos já envolvidos na limpeza foram formatados. A formatação das três
telas/componentes Flutter foi registrada em commit separado.

## Verificações locais

| Comando/verificação | Resultado |
| --- | --- |
| Backend `dart pub get` | Passou |
| Backend format check incremental | Passou: 9 arquivos, 0 alterações |
| Backend `dart analyze` | Passou: No issues found |
| Backend `dart test` | Passou: 6 testes |
| Frontend `flutter pub get` | Passou; informa 3 dependências com versões mais recentes incompatíveis com as restrições atuais, sem atualização fora de escopo |
| Frontend format check incremental | Passou: 5 arquivos, 0 alterações |
| Frontend `flutter analyze` | Passou: No issues found |
| Frontend `flutter test` | Passou: 13 testes |
| Frontend `flutter build web` | Passou; permanece o aviso preexistente de fonte CupertinoIcons |
| Script Bash `bash -n` | Passou |
| YAML do workflow | Parse local passou; dois jobs, comandos e diretórios conferidos |
| `git diff --check` | Passou |

Os testes HTTP usam loopback com banco/SMTP/sessão simulados. Os testes Flutter
são automatizados de widgets. Não equivalem a teste manual no navegador ou
integração com banco real; nenhum desses dois tipos foi realizado nesta tarefa.
GitHub Actions ainda não foi executado remotamente: o workflow está preparado
localmente. O aviso de fonte do build não é aviso de analisador e não foi corrigido
com nova dependência ou alteração visual.

## Divisão sugerida para revisão

1. Runner backend: dependência/lockfile, registro dos testes, renomes dos
   executáveis SQL e atualização dos comandos na documentação.
2. Analisadores: API pública do dotenv, três APIs Flutter e variável não usada,
   com testes de configuração e do filtro de órgão.
3. CI e documentação: workflow, format check incremental e resultados.

A terceira PR deve entrar após as duas primeiras, para que o CI encontre o
runner e os analisadores já corrigidos na main. Cada PR deve partir da main
atualizada naquele momento, sem misturar alterações funcionais.

O commit de formatação apenas dos arquivos envolvidos pode acompanhar a segunda
PR, separado para revisão mecânica. Não houve push, criação de PR ou merge nesta
tarefa; os commits locais permitem essa separação após revisão.

## Arquivos envolvidos

- Runner: `backend/pubspec.yaml`, `backend/pubspec.lock`,
  `backend/test/codigos_acesso_test.dart`, `autenticacao_email_test.dart`,
  `distribuicao_test.dart` e `assuntos_estruturais_test.dart`.
- Renomes sem mudança de conteúdo: `backend/test/distribuicao_sql_test.dart`
  para `distribuicao_sql.dart` e `backend/test/assuntos_estruturais_sql_test.dart`
  para `assuntos_estruturais_sql.dart`.
- Configuração: `backend/lib/config/settings.dart`,
  `backend/test/settings_test.dart` e `backend/test/fixtures/read_settings.dart`.
- Flutter: `frontend/lib/screens/inicio_screen.dart`, `tipos_screen.dart`,
  `frontend/lib/widgets/admin/user_filters.dart`,
  `frontend/lib/widgets/manifestacao/resumo_tipo_card.dart` e
  `frontend/test/user_filters_test.dart`.
- CI: `.github/workflows/ci.yml` e `.github/scripts/check-format.sh`.
- Documentação: `README.md`, `docs/testes_ci.md`, `docs/pendencias.md`,
  `docs/autenticacao_email.md`, `docs/assuntos_estruturais.md` e
  `docs/distribuicao_tipos.md`.

Referências das actions: [setup-dart](https://github.com/dart-lang/setup-dart),
[flutter-action](https://github.com/subosito/flutter-action) e
[checkout](https://github.com/actions/checkout).

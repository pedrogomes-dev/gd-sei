# Distribuição administrativa de Tipos de Processo

Administradores acessam **Administração → Distribuição de Tipos**. A janela
lista todos os Tipos da maior versão publicada, inclusive inativos.

## Comportamento

- Busca por nome ou ID e paginação local de 50 registros.
- Cards Todos, Vinculados, Não vinculados, Ativos e Inativos, reutilizando
  `IndicadorCard`. Os totais consideram toda a busca, antes dos filtros e da
  paginação. Situação e vínculo podem ser combinados; Todos limpa ambos.
- Cada Tipo informa a quantidade de órgãos vinculados, inclusive zero.
- O diálogo permite buscar e selecionar vários órgãos, incluir ou remover
  vínculos e salvar. A busca preserva seleções não visíveis. Desmarcar todos
  remove todos os vínculos daquele Tipo. Cancelar não grava.
- Durante o salvamento, seleção, saída e botões são bloqueados. Falhas mantêm
  o diálogo aberto com a mensagem recebida.

O vínculo editado é `dbo.tipo_procedimento_restricao`, a distribuição atual
usada na preparação de atribuições. Não altera `ref_*`, snapshots, atribuições,
manifestações ou submissões de rodadas existentes. Depois da edição, aplicar a
distribuição a uma rodada continua sendo uma operação separada com
`sp_completar_atribuicoes`: prévia, revisão e aplicação explícita. Retirar um
vínculo da referência não retira atribuições anteriores.

## API e segurança

- `GET /api/admin/distribuicao`: retorna `versao`, `tipos`, `orgaos` e `vinculos`.
- `POST /api/admin/distribuicao/tipos/{id}`: recebe `versao`, `orgaos_anteriores`
  e `orgaos` (arrays de IDs inteiros, sem duplicatas). Lista vazia é válida.

Ambas as rotas exigem sessão e administrador ativo no backend. A transação
revalida perfil, versão publicada, existência do Tipo e dos órgãos. Preserva
órgão 0 e versão 0. Compara os órgãos anteriores com o banco; conflito ou nova
publicação retorna 409. Cancele a edição e atualize a listagem para tentar
novamente. Não há sobrescrita automática.

A gravação usa a trava `carga_atribuicoes` da procedure 006, altera somente os
pares do Tipo selecionado e grava `DISTRIBUICAO_TIPO` em `auditoria`, com ator,
versão e conjuntos antes/depois, na mesma transação.

## Instalação e permissões

Não há nova tabela ou migração. A instalação precisa incluir 005
(`auditoria.detalhe` como `nvarchar(max)`) e a distribuição de referência;
009 provisiona esta última quando ausente. Veja `docs/instalacao_banco.md`.

Além das leituras existentes, a credencial SQL do backend precisa de INSERT e
DELETE em `tipo_procedimento_restricao`, INSERT em `auditoria` e uso da trava
de aplicação. O DBA deve conferir as permissões efetivas antes da implantação.
Não exige publicação, ALTER ou exclusão de avaliações.

## Verificações executadas e limites

- `dart run test/distribuicao_test.dart`: rotas HTTP com sessão/banco simulados;
  autorização, parâmetros, múltiplos órgãos, remoção e conflitos.
- `dart run test/distribuicao_sql_test.dart`: SQL Server real com tabelas
  temporárias privadas e trava de teste; inclusão/remoção, perfil, versão,
  edição obsoleta, rollback e auditoria. Não grava em tabelas persistentes.
- `flutter test --no-pub`: quatro testes de seleção múltipla, busca, cancelamento,
  remoção, conflito e diálogo em tela estreita com texto ampliado.
- Leitura real da distribuição e sintaxe SQL por PARSEONLY, sem gravação
  persistente. `flutter build web --no-pub` concluído.

Homologação visual, sessões reais de administrador/usuário comum, concorrência
entre duas sessões/carga 006 e permissões SQL de produção continuam pendentes.
Os testes simulados/temporários não substituem essas verificações. Permanecem
os avisos preexistentes dos analisadores.

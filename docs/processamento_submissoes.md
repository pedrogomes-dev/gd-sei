# Processamento administrativo das submissões

Administração → **Processamento das submissões** acompanha somente manifestações
`FINALIZADA`. Cada contexto é a combinação `id_consulta`/`id_orgao` (rodada/órgão).
Cada item é a `id_atribuicao` de `consulta_orgao_tipo`. O mesmo Tipo em órgãos ou
rodadas diferentes continua independente; não há consolidação de decisões.

## Modelo e instalação

Os modelos existentes de manifestação/finalização não possuem um estado para o
trabalho posterior da SETIC. A inspeção de metadados do banco também não encontrou
tabelas com nome de processamento/submissão. A nova tabela operacional
`dbo.processamento_submissao` contém apenas:

- `id_atribuicao`: chave primária e FK para `consulta_orgao_tipo`;
- `id_usuario_atualizacao`: FK para `usuario`;
- `data_atualizacao`: UTC, default `SYSUTCDATETIME()`.

Ausência de linha significa **PENDENTE**; presença significa **ATUALIZADO**.
Não é necessário armazenar novamente um estado fixo, um ID artificial, nome,
órgão ou versão: a atribuição identifica esses relacionamentos inequivocamente.
O PK impede duplicação. A conclusão da submissão é calculada quando todos os seus
itens possuem registro; não muda `consulta_orgao.status` nem a manifestação.

Aplicar manualmente **`database/010_processamento_submissoes.sql`**, no banco
GD-SEI correto após 008 e antes de disponibilizar os novos endpoints. O script
é incremental, cria a tabela se ausente e não altera scripts históricos,
referências, submissões ou dados do SEI. Verificar permissões de SELECT/INSERT
da credencial da aplicação na tabela nova. Não reaplicar instalações históricas.
Esta tarefa **não aplicou a migração** no banco da aplicação.

## API

- `GET /api/admin/processamento`: itens das submissões finalizadas, com rodada,
  órgão, ID/nome do Tipo, decisão submetida, situação, responsável e data UTC.
- `POST /api/admin/processamento/{id_atribuicao}/atualizar`: marca um item como
  atualizado. Não recebe decisão, órgão, usuário responsável ou data do cliente.

As duas rotas exigem administrador ativo no backend. A gravação revalida esse
perfil dentro da transação, assim como existência da atribuição e status
`FINALIZADA`. SQL parametrizado e joins com versão. Erros: 403 para não admin,
400 para ID inválido, 404 para item inexistente e 409 para manifestação não
submetida. Repetir uma marcação retorna sucesso e conserva o primeiro responsável
e a primeira data; a trava de chave e a PK serializam inclusões do mesmo item.
Não há endpoint para reabertura, retorno a pendente ou edição da marcação.

## Interface

Usa AppShell, SectionCard, IndicadorCard e StatusTag existentes. O menu só aparece
para admin; isso não substitui a autorização da API. A tabela apresenta ID, nome,
decisão e situação, agrupada por submissão com órgão/rodada visíveis. Em telas
estreitas a tabela tem rolagem horizontal. **Consultar submissão** reutiliza o
resumo já existente, sem novo fluxo de decisão.

Busca por nome/ID, filtros Todos/Pendentes/Atualizados e paginação de 20 itens
são locais sobre a lista de finalizadas, mantendo o carregamento simples. Uma
submissão pode continuar na página seguinte com seu cabeçalho repetido. A tela
informa quantos itens da submissão aparecem na página. Contadores dos cards seguem
a pesquisa antes do filtro de estado. Progresso/conclusão de cada submissão
sempre consideram todos os seus itens, inclusive os ocultos pela pesquisa/filtro
ou por outra página.

Marcar como atualizado é apenas uma declaração administrativa de trabalho
externo concluído; o GD-SEI não chama nem altera o SEI. Não existe processamento
automático, resolução de divergências, notificações ou decisão final da SETIC.
Se houver dados legados sem decisão explícita, a tela mostra **Não informada**,
sem inventar manutenção/descontinuação nem modificar o registro.

## Verificações

- `dart analyze` e `dart test`: backend, incluindo rotas HTTP com sessão/banco
  simulados para autorização, finalizadas, dois órgãos com mesmo Tipo, marcação,
  repetição, inexistente, rascunho e IDs inválidos.
- `dart run test/processamento_sql.dart`: integração opcional real com SQL Server,
  **somente tabelas temporárias privadas**. Passou para autorização ativa/admin,
  mesma versão, finalizadas, repetição, preservação de responsável/data e rollback.
  Não acessa tabelas persistentes nem aplica 010. Não substitui homologação da DDL.
- `flutter analyze`, `flutter test`, `flutter build web`: interface, incluindo
  filtros/pesquisa, atualização visual, conclusão por órgão, paginação e largura
  reduzida. Cliente web conserva cookies; import condicional permite testes na VM.

Resultado local: analisadores sem apontamentos, dez testes Dart e dezessete
testes Flutter passaram; build web passou com aviso preexistente de fonte
CupertinoIcons. Format check limitado aos arquivos desta alteração.

Pendente: aplicar/homologar 010 em banco de testes e testar a tela no navegador
com sessões reais. Os testes de widgets e as tabelas temporárias não equivalem
a essa homologação. Não houve alteração de dados persistentes do banco nesta tarefa.

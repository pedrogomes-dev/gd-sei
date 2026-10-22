# Avaliação administrativa das submissões

Administração → **Processamento das submissões** considera apenas manifestações
`FINALIZADA`. O agrupamento é `id_consulta`/`id_orgao`; cada Tipo é identificado
por sua `id_atribuicao`. O mesmo Tipo em órgãos ou rodadas diferentes permanece
independente. A manifestação original continua finalizada.

## Regra de avaliação

A SETIC aceita ou recusa individualmente a decisão submetida do Tipo e cada
decisão sobre seus vínculos com Assuntos. São apresentados ação e justificativa
submetidas, responsável e data/hora de cada parecer.

- O Tipo fica concluído quando sua decisão e todos os seus Assuntos submetidos
  tiverem parecer. Sem Assuntos, basta o parecer sobre o Tipo.
- A submissão fica concluída quando todos os seus Tipos estiverem concluídos.
- Qualquer recusa torna o resultado do Tipo e da submissão **parcialmente aceito**,
  inclusive quando todos os pareceres forem recusas. Isso não impede a conclusão.
- Sem recusas, o aceite permanece pendente até a avaliação completa; então fica
  aceito. Conclusão e resultado do aceite são apresentados separadamente.

Assuntos são as decisões de `manifestacao_vinculo` para um Tipo submetido como
`MANTER`. O fluxo existente de descontinuação não submete decisões sobre Assuntos;
eventuais vínculos antigos daquele Tipo não integram esta avaliação. Ter filhos
ou ser estrutural não altera a análise de decisões já submetidas.

Não existe edição de parecer, reabertura, consolidação entre órgãos, integração
com o SEI ou confirmação adicional de atualização externa nesta versão.

## Modelo e instalação

Aplicar manualmente **`database/011_avaliacao_setic.sql`** no banco GD-SEI correto,
após 008 e antes de disponibilizar esta versão. O incremental cria:

- `avaliacao_setic_tipo`: PK/FK `id_atribuicao` para `manifestacao_tipo`;
- `avaliacao_setic_assunto`: PK/FK composta `id_atribuicao`/`id_assunto` para
  `manifestacao_vinculo`.

Ambas armazenam somente parecer (`ACEITO`/`RECUSADO`), FK do administrador e data
UTC com default `SYSUTCDATETIME()`. Ausência de parecer representa pendência.
Resultado e conclusão são derivados, sem duplicar dados ou estados agregados.
As chaves impedem duplicação. Não há mudanças nas referências ou no SEI.

O script histórico 010 foi preservado. Sua tabela `processamento_submissao`, se
existente, deixa de alimentar a tela; marcações antigas de atualização externa
**não são convertidas em aceite**, nem removidas. A nova funcionalidade não depende
de aplicar 010. Conferir SELECT/INSERT nas tabelas novas para a credencial da API.
Esta tarefa não aplicou a migração nem alterou dados persistentes.

## API

- `GET /api/admin/processamento`: Tipos finalizados e suas decisões sobre Assuntos,
  com pareceres, contagens e conclusão/resultado por Tipo. Joins respeitam versão.
- `POST /api/admin/processamento/{id_atribuicao}/avaliar`: JSON `parecer` obrigatório
  (`ACEITO` ou `RECUSADO`); `id_assunto` opcional identifica a decisão de vínculo.
  Sem `id_assunto`, avalia a decisão do próprio Tipo.

O backend exige administrador ativo. A transação de gravação revalida perfil,
atribuição, finalização e existência da decisão submetida na versão correta.
Usuário e horário vêm do servidor. Queries são parametrizadas. Repetir o mesmo
parecer retorna sucesso sem trocar responsável/data; tentar alterar um parecer
retorna 409. Locks e PK protegem a inclusão. A rota antiga `/atualizar` foi removida.

Erros: 400 para parâmetros inválidos; 403 para perfil sem autorização; 404 para
atribuição inexistente ou Assunto fora daquele contexto; 409 para manifestação
não finalizada, decisão do Tipo ausente ou tentativa de trocar parecer.

## Interface

Reutiliza AppShell, SectionCard, IndicadorCard e StatusTag, sem alterar este último.
Cada Tipo expande suas decisões e ações simples **Aceitar**/**Recusar**. Após o
registro, mostra parecer, responsável e data. Usa widgets nativos e setState.

Busca por nome/ID e filtros Todos/Pendentes de avaliação/Concluídos são locais.
A paginação mantém 20 Tipos por página, com contexto de submissão repetido quando
necessário. Progresso e aceite de uma submissão consideram todos os seus itens,
inclusive os ocultos pela busca, filtro ou paginação. Cards seguem a pesquisa
antes do filtro de estado. A largura reduzida usa quebra de linhas.

## Verificações executadas

- Backend: `dart analyze`, sem apontamentos; `dart test`, 13 testes passaram.
  Rotas HTTP com banco/sessão simulados cobrem autorização, finalizadas, contexto
  por órgão, aceite individual, recusa parcial, todos recusados, conclusão,
  repetição, conflito e parâmetros inválidos.
- `dart run test/processamento_sql.dart`: passou em SQL Server, somente tabelas
  temporárias privadas. Executa as queries reais para verificar autorização,
  versão, finalização, escopo dos Assuntos, pareceres, repetição, preservação de
  responsável/data e rollback. Não aplica 011 nem homologa suas FKs persistentes.
- Frontend: `flutter analyze`, sem apontamentos; `flutter test`, 17 testes passaram.
  Widgets cobrem filtros/busca, aceite individual, propagação da recusa, conclusão
  por submissão, paginação e largura reduzida. API simulada nos testes de widgets.
- `flutter build web`: passou, com aviso preexistente de fonte CupertinoIcons.

Pendente: aplicar/homologar 011 em banco de testes e conferir a tela com sessões
reais no navegador. Testes de widgets e tabelas temporárias não substituem essa
homologação. Formatação limitada aos arquivos alterados nesta funcionalidade.

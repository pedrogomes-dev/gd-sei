# Catálogo e atribuições
O catálogo é comum a todos os usuários autenticados. Sem órgão/rodada, a pesquisa começa na maior versão publicada de versao_base. A resposta informa a versão e a paginação conserva essa versão; uma nova pesquisa usa a publicação atual. Ativos e inativos permanecem visíveis, com etiquetas verde e vermelha. A pesquisa de inclusão na revisão continua na versão da atribuição, limitada a Assuntos ativos.
A interface distingue Tipos de Processo de futuros Tipos de Documento. Rotas e nomes técnicos existentes foram preservados.
## Completar rodada
Administradores podem editar a distribuição de referência em **Administração → Distribuição de Tipos**. Consulte [distribuicao_tipos.md](distribuicao_tipos.md). Essa edição não aplica mudanças automaticamente nas rodadas; a carga abaixo permanece uma operação separada.

database/006_completar_atribuicoes.sql instala a procedure e lista as rodadas. Não executa a carga automaticamente. A tabela tipo_procedimento_restricao deve existir, como informado pelo responsável.
Escolha o id_consulta correto e execute primeiro com @aplicar=0. Revise os grupos finalizados e o histórico em outras rodadas. Depois execute com @aplicar=1 se adequado.
A carga apenas acrescenta pares ausentes em grupos não finalizados. Não reabre grupos, exclui atribuições, copia manifestações nem altera rodadas anteriores. Atualiza a revisão do grupo para impedir submissão de resumo obsoleto. Uma nova execução não duplica pares existentes.
Avaliações finalizadas em outras rodadas são indicadas na prévia para decisão humana; não são automaticamente copiadas ou consideradas válidas. A aplicação não tem acesso direto ao banco do usuário.
## Validação
O catálogo e a interface principal foram homologados. A aplicação da distribuição pela procedure 006 continua sujeita ao teste concorrente específico documentado em `docs/distribuicao_tipos.md`. A instalação completa em banco novo permanece pendente.

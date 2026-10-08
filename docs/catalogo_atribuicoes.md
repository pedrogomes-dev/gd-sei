# Catálogo e atribuições
O catálogo é comum a todos os usuários autenticados. Sem órgão/rodada, a pesquisa começa na maior versão publicada de versao_base. A resposta informa a versão e a paginação conserva essa versão; uma nova pesquisa usa a publicação atual. Ativos e inativos permanecem visíveis, com etiquetas verde e vermelha. A pesquisa de inclusão na revisão continua na versão da atribuição, limitada a Assuntos ativos.
A interface distingue Tipos de Processo de futuros Tipos de Documento. Rotas e nomes técnicos existentes foram preservados.
## Completar rodada
database/006_completar_atribuicoes.sql instala a procedure e lista as rodadas. Não executa a carga automaticamente. A tabela tipo_procedimento_restricao deve existir, como informado pelo responsável.
Escolha o id_consulta correto e execute primeiro com @aplicar=0. Revise os grupos finalizados e o histórico em outras rodadas. Depois execute com @aplicar=1 se adequado.
A carga apenas acrescenta pares ausentes em grupos não finalizados. Não reabre grupos, exclui atribuições, copia manifestações nem altera rodadas anteriores. Atualiza a revisão do grupo para impedir submissão de resumo obsoleto. Uma nova execução não duplica pares existentes.
Avaliações finalizadas em outras rodadas são indicadas na prévia para decisão humana; não são automaticamente copiadas ou consideradas válidas. A aplicação não tem acesso direto ao banco do usuário.
## Validação
Conferir catálogo com usuário sem atribuições, busca por ID/texto, ativos/inativos, paginação e versão. Conferir nomenclatura e rodadas antigas/finalizadas. Na homologação SQL, executar prévia, aplicar em rodada de teste, repetir e confirmar ausência de duplicação; verificar bloqueio de grupos finalizados e revisão obsoleta.
Ambiente de edição sem Dart/Flutter e SQL Server: compilação e integração pendentes. Reiniciar backend/frontend após atualização.

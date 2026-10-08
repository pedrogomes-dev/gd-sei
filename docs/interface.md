# Interface de revisão

A interface autenticada utiliza cabeçalho com o e-mail real da sessão e órgãos vinculados, menu lateral agrupado em Validação/Catálogo e caminho de navegação. Em janelas estreitas o menu fica em uma gaveta. O cadastro atual não possui nome do usuário; a interface não presume um nome a partir do e-mail.

- Meus Tipos: seleção de órgão quando houver mais de um, resumo de progresso e tabela com busca/filtros. Revisão completa exige visualização e zero vínculos pendentes. O progresso usa todos os Tipos do órgão/consulta, independentemente do filtro textual.
- Resumo e submissão: consultas agrupadas por órgão. Finalizadas oferecem Consultar resumo.
- Revisão: propriedades recolhidas, seções separadas para vínculos, inclusões e observações; salvamento em barra inferior fixa. A navegação pelo menu empilha telas e conserva o preenchimento não salvo ao retornar; sair da conta ou voltar continua solicitando confirmação de descarte.
- Resumo: tabela Assunto/Decisão/Justificativa; textos longos podem ser consultados integralmente (justificativa pelo clique, descrição pelo Tipo). Data UTC recebida da API é apresentada no fuso do navegador, sem frações de segundo.
- Catálogo: somente leitura, com escolha explícita de órgão/consulta, busca por ID/texto, paginação e propriedades. Inclui ativos e inativos da versão autorizada. A pesquisa para propor inclusão continua restrita a Assuntos ativos ainda não vinculados.

Endpoints adicionais: GET /api/auth/me e GET /api/catalogo/{assuntos|tipos}?atribuicao=ID&q=TEXTO&offset=0. O backend valida a atribuição contra o usuário da sessão e obtém a versão no banco. Nomes SQL são definidos em lista fixa; valores são parâmetros.

Nenhuma migração SQL necessária. Mantidos acesso temporário, publicação transacional, referências, regras de manifestação, auditoria, revisão concorrente e bloqueio após finalização.

## Homologação

1. Executar dart analyze no backend e flutter analyze no frontend; reiniciar ambos.
2. Conferir e-mail/órgãos no cabeçalho, menu em janela larga/estreita e retorno de telas.
3. Conferir filtros, seleção de órgão e progresso com mais de uma consulta.
4. Abrir catálogo de Assuntos/Tipos; pesquisar ID e texto, navegar páginas e abrir propriedades. Tentar atribuição de outro órgão não autorizado deve falhar.
5. Editar um rascunho, navegar pelo menu e voltar: preenchimento deve permanecer. Voltar da revisão/sair da conta deve confirmar descarte.
6. Salvar, revisar resumo, submeter em consulta de teste e conferir bloqueio de edição em outra aba. Manter teste de revisão concorrente existente.
7. Conferir data de finalização no fuso do navegador e textos longos.

Limite da validação nesta alteração: ambiente de edição sem Dart/Flutter ou SQL Server; não houve execução de analyze, build ou integração. Fazer essas verificações antes do merge.

## Ajustes após homologação visual

Login utiliza o tema anterior isolado, com separação entre campos. Estados e ações nos cartões de órgão são alinhados à direita. Totais do resumo recebem ícones azul/vermelho/verde. Cada tabela de Assuntos possui rolagem própria vertical e horizontal; o nome do Tipo e o estado de revisão ficam fora dessa área. A ação Informações abre as propriedades do Assunto obtidas da versão autorizada no resumo, incluindo prazos e código de destinação, sem inferir unidades ou significados de códigos.

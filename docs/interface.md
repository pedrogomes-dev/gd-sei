# Interface de revisão

A interface autenticada utiliza cabeçalho com nome/e-mail da sessão e órgãos vinculados, menu lateral agrupado em Validação/Catálogo/Administração e caminho de navegação. Em janelas estreitas o menu fica em uma gaveta.

- Meus Tipos: seleção de órgão quando houver mais de um, resumo de progresso e tabela com busca/filtros. Revisão completa exige visualização e zero vínculos pendentes. O progresso usa todos os Tipos do órgão/consulta, independentemente do filtro textual.
- Resumo e submissão: consultas agrupadas por órgão. Finalizadas oferecem Consultar resumo.
- Revisão: propriedades recolhidas, seções separadas para vínculos, inclusões e observações; salvamento em barra inferior fixa. A navegação pelo menu empilha telas e conserva o preenchimento não salvo ao retornar; sair da conta ou voltar continua solicitando confirmação de descarte.
- Resumo: tabela Assunto/Decisão/Justificativa; textos longos podem ser consultados integralmente (justificativa pelo clique, descrição pelo Tipo). Data UTC recebida da API é apresentada no fuso do navegador, sem frações de segundo.
- Catálogo: somente leitura, com escolha explícita de órgão/consulta, busca por ID/texto, paginação e propriedades. Inclui ativos e inativos da versão autorizada. A pesquisa para propor inclusão continua restrita a Assuntos ativos ainda não vinculados.

Endpoints adicionais: GET /api/auth/me e GET /api/catalogo/{assuntos|tipos}?atribuicao=ID&q=TEXTO&offset=0. O backend valida a atribuição contra o usuário da sessão e obtém a versão no banco. Nomes SQL são definidos em lista fixa; valores são parâmetros.

Nenhuma migração SQL necessária. Mantidos acesso temporário, publicação transacional, referências, regras de manifestação, auditoria, revisão concorrente e bloqueio após finalização.

## Homologação

A homologação funcional e visual principal da interface foi concluída, incluindo autenticação, navegação, manifestação/submissão e autorização por órgão. Testes automatizados e analisadores continuam sendo tratados separadamente das verificações manuais.

## Ajustes após homologação visual

Login utiliza o tema anterior isolado, com separação entre campos. Estados e ações nos cartões de órgão são alinhados à direita. Totais do resumo recebem ícones azul/vermelho/verde. Cada tabela de Assuntos possui rolagem própria vertical e horizontal; o nome do Tipo e o estado de revisão ficam fora dessa área. A ação Informações abre as propriedades do Assunto obtidas da versão autorizada no resumo, incluindo prazos e código de destinação, sem inferir unidades ou significados de códigos.

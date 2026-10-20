# Assuntos apenas estruturais

`sin_estrutural = 'S'` impede novas propostas de vínculo com Tipos de Processo.
A existência de filhos não impede vínculos: a regra usa exclusivamente o atributo,
sem inferências pelo código, nível ou `id_assunto_pai`.

O campo já existe em `ref_assunto` e `assunto` (001), é copiado pela publicação
(002) e retornado pelas consultas de Assuntos. Não há migração SQL necessária.
Não alterar referências imutáveis, snapshots nem dados do SEI para aplicar a regra.

O backend verifica inclusões antes de chamar a procedure de salvamento, usando
a versão da atribuição autorizada e parâmetros SQL. Propostas `ADICIONAR` já
persistidas na mesma atribuição/versão continuam podendo ser salvas para preservar
o histórico e permitir saneamento posterior. Decisões MANTER/REMOVER sobre vínculos
originais não são bloqueadas. Não há exclusão automática de vínculos ou propostas.
A procedure SQL existente não ganha uma restrição nova; o bloqueio de novas
propostas é aplicado pela API. Operações SQL administrativas exigem revisão própria.

A busca mantém itens estruturais visíveis, mas desabilita Propor inclusão.
Seu ícone de ramificações possui tooltip por hover/toque; o título das propriedades
continua expansível. No catálogo de Assuntos, o ícone substitui a seta apenas
para itens estruturais; clicar mostra a restrição e também expande/recolhe os
vínculos existentes. A hierarquia continua baseada em `id_assunto_pai`.

Diagnóstico somente leitura:

```powershell
cd backend
dart run bin/check_assuntos_estruturais.dart
```

Na consulta executada em 20/10/2026, as duas colunas estavam disponíveis,
não havia vínculos estruturais em `rel_tipo_procedimento_assunto` e havia duas
propostas preexistentes, ambas na versão 0: atribuição 2/Assunto 332 e
atribuição 27/Assunto 319. Nenhum registro foi modificado. Esses resultados
são uma fotografia da consulta, não uma garantia sobre alterações posteriores.

Testes específicos: `dart run test/assuntos_estruturais_test.dart` (backend com
banco simulado), `dart run test/assuntos_estruturais_sql_test.dart` (consulta
real de elegibilidade, somente leitura, autorização simulada) e
`flutter test --no-pub` (inclui seleção/tooltip/expansão).
O teste SQL passou: rejeitou uma nova inclusão estrutural, aceitou um pai
classificável `N` com filhos e aceitou as duas propostas preexistentes.
Homologar a API com sessão real, pesquisa/paginação, catálogo hierárquico,
vínculos legados, contadores e submissão. Não executar testes com escrita no banco
de uso para verificar a regra.

# Validação e submissão

Execute `database/005_manifestacoes.sql` uma vez em sei_gd após 004. Preserva referências, versões, usuários e atribuições existentes. Cria manifestacao_tipo/manifestacao_vinculo, metadados de finalização no órgão e procedures de salvamento/finalização. Auditoria passa a guardar JSON completo de antes/depois, sem sobrescrever eventos.

Após atualizar o código, execute dart pub get, dart analyze, dart run bin/check_parameters.dart e reinicie o backend; no frontend execute flutter analyze e reinicie o Flutter Web. O teste de parâmetros agora inclui texto acima de 4000 caracteres para o JSON de manifestações. ODBC local usa SQL_WLONGVARCHAR para esses textos.

## Uso

1. Abrir o Tipo e consultar suas propriedades/Assuntos.
2. Marcar explicitamente MANTER ou REMOVER nos vínculos existentes; deixar pendente é permitido no rascunho.
3. Pesquisar todos os Assuntos ativos da versão da consulta (50 por página). Vínculos existentes são excluídos da pesquisa de inclusão.
4. Propor ADICIONAR e justificar; justificar REMOVER. MANTER não exige justificativa.
5. Preencher observação geral e salvar rascunho. Confirmar a visualização do Tipo.
6. Abrir Resumo e submissão na lista, por consulta/órgão, revisar os dados salvos e finalizar.

A submissão é compartilhada pelo órgão e exige todos os Tipos visualizados e todos os vínculos existentes com decisão explícita salva. Após finalizar, telas ficam somente leitura e a procedure recusa salvamento. Sem reabertura.

## Integridade

A versão é obtida da atribuição autorizada, nunca enviada como parâmetro confiável pelo navegador. Foreign keys compostas impedem misturar versões. Inclusões só aceitam Assuntos ativos ainda não vinculados. Manter/remover só se aplicam a vínculos originais, inclusive inativos que já existiam.

Salvamentos e finalização bloqueiam a mesma linha consulta_orgao na transação. Revisão do Tipo impede sobrescrita de outra edição; revisão do órgão impede finalizar um resumo obsoleto. Conflito exige recarregar e reaplicar alterações. Não há merge automático. Alterações não salvas ficam indicadas e sair da tela solicita descarte.

Limites de interface/API: observação 5000 caracteres, justificativa 2000, pesquisa 250, corpo HTTP 256 KiB. Esses são limites técnicos da aplicação, não regras do SEI. A justificativa é validada na API e no banco. Somente as tabelas de trabalho recebem decisões; dados oficiais não são alterados.

## Validação

O fluxo funcional de manifestação e submissão foi homologado, incluindo decisões do Tipo, vínculos, justificativas, resumo, finalização e bloqueio posterior. A autenticação por e-mail também foi homologada.

`database/tests/manifestacoes.sql` permanece como roteiro técnico para regressão em ambiente descartável. Não executar testes com escrita na base oficial.

Persistência compartilhada de sessões não faz parte do MVP atual; o backend deve operar inicialmente com uma única réplica.

## Identificação visual e pesquisa

As decisões usam etiquetas com texto e ícone: manter azul, remover vermelho e incluir verde. Pendências são amarelas; visualização usa o ícone de olho e finalização usa cadeado. A lista permite buscar Tipos por nome/ID e filtrar pendentes, visualizados ou finalizados. O progresso por órgão considera todos os Tipos atribuídos, mesmo ao filtrar a lista; os vínculos sem decisão consideram somente decisões salvas.

A pesquisa de Assuntos também compara o ID exato quando o texto é um inteiro válido, além da busca textual nos campos existentes. Os resultados continuam restritos a Assuntos ativos da versão da consulta, excluindo vínculos já existentes no Tipo. O ID aparece nos vínculos, resultados e resumo. As propriedades recebem rótulos legíveis; códigos do SEI não recebem significados presumidos.

Para atualizar, execute `git pull` e reinicie backend e frontend. Esta alteração não requer novo script SQL. O acesso temporário permanece habilitado conforme a configuração de desenvolvimento. Verifique localmente com `dart analyze` no backend e `flutter analyze` no frontend; valide a busca por ID e os filtros no navegador.

## Organização após refatoração

O Router encaminha a revisão, busca, salvamento, resumo e finalização para `ManifestacaoController`. O controller usa consultas SQL multilinha e valida revisão, observação e cada vínculo em blocos separados. O antigo `ManifestacaoRepository` foi removido. O catálogo fica em `CatalogoController`, preservando a versão, pesquisa, filtros e total existentes. A conexão e a autorização das atribuições continuam nas classes existentes; não há service intermediário para manifestações.

As telas `TipoScreen` e `ResumoScreen` coordenam o estado e as operações. Widgets em `frontend/lib/widgets/manifestacao` cuidam dos vínculos, justificativas, busca, informações do Assunto e resumo de cada Tipo. Os controllers de texto permanecem na tela de revisão, para conservar o preenchimento ao navegar. Mantidos o aviso de descarte, rascunho compartilhado, etiquetas, cores e bloqueio após finalização.

Esta refatoração não modifica as procedures ou tabelas SQL e não exige reaplicar 005/007. As mesmas rotas e campos JSON são usados; métodos internos da API receberam nomes mais claros. Análise estática e testes automatizados permanecem controles independentes da homologação funcional já concluída.


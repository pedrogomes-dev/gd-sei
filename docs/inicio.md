# Início: acompanhamento da rodada

A tela Início abre após o login. O administrador acompanha todos os órgãos; os demais usuários acompanham somente os órgãos aos quais estão vinculados. O filtro de rodada exibe o nome da consulta e a versão da base utilizada.

## Indicadores

As contagens representam atribuições de Tipos de Processo a órgãos, dentro da rodada selecionada. O mesmo Tipo de Processo atribuído a dois órgãos conta duas vezes.

| Indicador | Regra |
| --- | --- |
| Pendentes de análise | Atribuições ainda não visualizadas ou com vínculo original sem decisão MANTER/REMOVER salva. |
| Analisados | Atribuições visualizadas e com decisão salva para todos os vínculos originais. Sem vínculos originais, a visualização é suficiente, conforme a regra existente de submissão. |
| Visualizados | Atribuições com registro em visualizacao_tipo. |
| Submetidos | Atribuições de órgãos com status FINALIZADA na rodada. |

Os indicadores se sobrepõem: uma atribuição submetida também pode ser analisada e visualizada. Não devem ser somados. Revisar o mesmo Tipo de Processo não multiplica sua contagem.

Cada cartão informa também quantos órgãos possuem ao menos uma atribuição naquela condição, por exemplo “235 (10 órgãos) Pendentes de análise”. Ao clicar, a tabela lista esses órgãos e limpa a busca por sigla. Um órgão pode aparecer em mais de um indicador se suas atribuições estiverem em condições diferentes. “Analisados” inclui órgãos com alguma análise concluída; “Submetidos” inclui somente órgãos que finalizaram a rodada.

Início é o primeiro item do caminho de navegação de todas as telas internas, por exemplo “Início > Validação > Tipos de Processo atribuídos”. Na Home, aparece somente “Início”. O menu lateral começa pelo grupo Validação, sem um atalho separado para a Home. O logo também abre a Home. Os links do caminho têm espaçamento horizontal interno zero, alinhando seu primeiro texto com o título. O rótulo “Rodada de avaliação” fica acima do seletor para permanecer visível.

## Órgãos

A tabela apresenta sigla, atribuições, pendências, análises concluídas, percentual de análise, situação e data da submissão em horário local. A busca por sigla e os filtros de submissão atualizam a quantidade de órgãos encontrados. Os indicadores continuam representando a rodada inteira dentro do acesso do usuário.

Órgãos em rascunho e sem pendências de análise aparecem como “Pronto para submeter”. Continuam pendentes de submissão até a finalização. Órgãos sem atribuições aparecem em “Todos”, com “Sem atribuições”, e não entram no quantitativo de órgãos pendentes de submissão.

O atalho abre o resumo do órgão. Administradores sem vínculo com aquele órgão podem consultar as decisões e informações dos assuntos, mas não revisar ou submeter. As restrições das rotas de edição e dos procedimentos de gravação permanecem vigentes. Ao voltar do resumo, a Home atualiza os indicadores.

## Implementação e validação

Não há migração nem nova tabela. `InicioController` consulta os dados existentes e a tela utiliza `StatefulWidget`, `setState`, `IndicadorCard` e `TabelaOrgaos`.

A navegação, os indicadores, a visualização por perfil e as restrições entre administrador, usuário comum e órgãos foram homologados. Análise estática, testes automatizados e implantação são controles independentes e não devem ser confundidos com essa homologação funcional.



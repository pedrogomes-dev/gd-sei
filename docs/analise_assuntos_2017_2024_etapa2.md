# Etapa 2 — Mapa de correspondência semântica (DE 2017 → PARA 2024)

> Status: análise exploratória, sem aprovação de migração.
> Data: 27/10/2026.

## Escopo e premissas

Cruzamento dos 379 códigos exclusivos da tabela de assuntos de 2017 com os 362 códigos exclusivos da tabela de 2024. A apresentação segue sempre **DE (2017) → PARA (2024)**. A existência de código igual nas duas versões não comprova equivalência de significado.

## Síntese do cruzamento inicial

| Indicador | Quantidade |
|---|---:|
| Códigos exclusivos DE (2017) | 379 |
| Códigos exclusivos PARA (2024) | 362 |
| Pares com descrição normalizada idêntica | 36 |
| Pares candidatos adicionais por similaridade textual | 7 |
| Itens de 2017 sem candidato selecionado entre os códigos exclusivos | 344 |
| Itens de 2024 sem candidato selecionado entre os códigos exclusivos | 321 |

Os totais de pares não correspondem aos totais de itens: uma descrição pode aparecer em mais de um código. Nenhuma relação de desdobramento (1:N) ou consolidação (N:1) deve ser considerada homologada somente pela coincidência textual.

## Critérios DE → PARA

| Relação | Interpretação | Condição para homologar |
|---|---|---|
| 1:1 | Um assunto de 2017 corresponde a um assunto de 2024 | Equivalência de escopo e posição na árvore, incluindo notas e propriedades arquivísticas |
| 1:N | Um assunto antigo distribui-se por vários destinos | Evidência explícita de desdobramento de escopo |
| N:1 | Vários assuntos antigos concentram-se em um destino | Evidência explícita de consolidação |
| Sem correspondência | Nenhum destino comprovado | Conferir também os 322 códigos comuns e a hierarquia completa |

## Método

1. Normalizar os espaços indevidos nos códigos de 2017 exclusivamente para comparação.
2. Comparar descrições normalizadas e observações, utilizando a hierarquia como contexto.
3. Registrar descrições iguais como **equivalência textual**, não como equivalência arquivística.
4. Identificar sugestões por similaridade como **hipóteses de correspondência**.
5. Preservar ordem DE → PARA e rastreabilidade do código original.
6. Não interpretar ausência de candidato como exclusão definitiva.

## Limitações e decisões pendentes

- O recorte de códigos exclusivos **não cobre mudanças de significado em códigos reaproveitados** nas duas versões.
- As relações 1:N e N:1 precisam de análise de conteúdo; títulos repetidos não as demonstram.
- O vínculo aos processos em produção e os prazos de temporalidade devem ser analisados separadamente.
- Não atualizar a classificação dos processos do SEI automaticamente com base neste diagnóstico.

## Próximas etapas

1. Validar tecnicamente os 36 pares de descrição idêntica e os 7 candidatos por similaridade.
2. Cruzar os candidatos com a árvore completa, incluindo os 322 códigos compartilhados, para detectar deslocamentos e consolidações verdadeiras.
3. Classificar o mapa final DE → PARA por 1:1, 1:N, N:1 e sem correspondência, com justificativa e status de validação.
4. Confrontar o mapa homologado com os assuntos efetivamente vinculados a processos no SEI de Rondônia, para medir impacto real.

**Artefato analítico detalhado:** `etapa2_mapa_de_para_2017_2024.md` (gerado a partir dos dois CSVs enviados na análise, com listagens completas; ainda não incorporado a este repositório).
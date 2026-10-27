# Etapa 3 — DE (2017) → PARA (2024): cruzamento integral

> **Situação:** diagnóstico técnico preliminar, sem homologação. Data: 27/10/2026.
>
> **Ordem obrigatória:** primeiro DE (2017), depois PARA (2024).

## Escopo

As duas tabelas foram comparadas integralmente: **701 assuntos DE (2017)** × **684 assuntos PARA (2024)**. Incluem-se os **322 códigos presentes nas duas versões**, não apenas os códigos exclusivos. Códigos com espaços indevidos foram normalizados somente durante a comparação, sem alterar as fontes.

## Indicadores

| Indicador | Resultado |
|---|---:|
| Registros DE (2017) | 701 |
| Registros PARA (2024) | 684 |
| Códigos compartilhados | 322 |
| Códigos compartilhados com descrição normalizada diferente | 167 |
| Linhas no mapa integral (inclusive múltiplas hipóteses) | 822 |
| Linhas com equivalência textual de título | 323 |
| Linhas sugeridas por similaridade | 31 |
| Assuntos DE sem correspondência suficientemente demonstrada | 468 |

Os números de linhas não representam quantidade de migrações aprovadas. Coincidência textual não assegura equivalência de abrangência ou de temporalidade.

## Classificações provisórias

| Tipo | Linhas |
|---|---:|
| 1:1 candidata | 178 |
| 1:N hipotética | 48 |
| N:1 hipotética | 9 |
| N:M ambígua (exige revisão) | 119 |
| Sem correspondência comprovada | 468 |

A classificação N:M é uma indicação de ambiguidade da análise textual, **não** um tipo de migração homologado. As indicações de 1:N e N:1 tampouco provam desdobramento ou consolidação: títulos genéricos podem aparecer repetidos em contextos hierárquicos diferentes.

## Método

1. Comparar descrições sem diferenças de caixa, acentos e pontuação.
2. Considerar observações e hierarquia, com cautela sobre notas de temporalidade e sobre pais inferidos por prefixo.
3. Buscar candidatos em **todos** os 684 destinos de 2024, inclusive códigos compartilhados.
4. Destacar candidatos com títulos idênticos e hipóteses com similaridade alta.
5. Preservar correspondências não comprovadas como pendências, sem declará-las removidas.
6. Não homologar migração com base em igualdade de código ou em pontuação algorítmica.
7. Conferir separadamente prazos, destinação, vigência e natureza estrutural.

## Riscos prioritários

- **Reutilização de código:** 167 códigos compartilhados possuem título diferente, apesar do mesmo identificador textual.
- **Mudança de escopo:** descrição coincidente não significa equivalência entre hierarquias.
- **Falsos desdobramentos:** nomes como "MATERIAL PERMANENTE" aparecem em vários destinos.
- **Impacto real desconhecido:** os dois CSVs não trazem distribuição de processos por assunto no SEI de Rondônia.

## Artefatos detalhados da análise

- `etapa3_mapa_integral_de_para_2017_2024.md`: mapa integral de 822 linhas e ressalvas metodológicas.
- `de_para_2017_2024_completo.csv`: mapa auditável com DE, PARA, pais, status, justificativa e divergências.
- `de_para_2017_2024_candidatos.csv`: candidatos com descrições e observações de ambas as versões.

**Observação:** estes três artefatos detalhados foram gerados na análise, mas ainda não foram publicados integralmente nesta árvore do GitHub. Não considerá-los incorporados por esta síntese.

## Próximo passo

Obter extração do SEI de Rondônia com `id_assunto`, código, quantidade de processos e, quando possível, tipo de processo e órgão. Priorizar análise manual dos assuntos efetivamente usados; examinar especialmente os códigos reaproveitados e os destinos ambíguos. Somente depois homologar DE → PARA e definir política de migração e preservação histórica.

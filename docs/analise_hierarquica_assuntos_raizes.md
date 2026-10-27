# Análise hierárquica de assuntos — mapeamento das raízes DE 2017 → PARA 2024

> Status: **análise preliminar de raízes — não homologada**. Data: 27/10/2026. Fonte: `tabela_2017.csv` e `tabela_2024.csv`.

## Correção metodológica

O cruzamento semântico anterior comparava assuntos de forma predominantemente isolada. Essa abordagem desconsidera deslocamentos de ramos completos e produz associações inconsistentes, principalmente em descrições genéricas. Por isso, o mapa integral anteriormente gerado **não deve ser utilizado para executar migração**.

Novo procedimento: identificar raízes (código de três algarismos), comparar escopo e observações, avaliar a semelhança do conjunto de descendentes e, **após a validação do par de raízes**, mapear grupos e filhos dentro dos respectivos ramos.

Os arquivos têm 79 raízes em 2017 e 89 em 2024. Uma raiz de origem pode ser distribuída para várias raízes de destino; a igualdade de código não prova equivalência.

## Exemplos de correspondência de raízes com suporte conceitual

| DE — 2017 | PARA — 2024 | Observação |
|---|---|---|
| 022 — APERFEIÇOAMENTO E TREINAMENTO | 024 — CAPACITAÇÃO DO SERVIDOR | Conceitos próximos; verificar diferenças de abrangência |
| 024 — DIREITOS, OBRIGAÇÕES E VANTAGENS | 023 — CONCESSÃO DE DIREITOS E VANTAGENS | Correspondência forte sustentada pelos grupos de gratificações, adicionais e descontos |
| 025 — APURAÇÃO DE RESPONSABILIDADE E AÇÃO DISCIPLINAR | 027 — APURAÇÃO DE RESPONSABILIDADE DISCIPLINAR | Títulos e domínio conceitual próximos |
| 034 — MOVIMENTAÇÃO DE MATERIAL | 032 — MOVIMENTAÇÃO DE MATERIAL | Título coincidente; verificar subdivisões |
| 035 — ALIENAÇÃO. BAIXA | 033 — ALIENAÇÃO E BAIXA | Títulos conceitualmente equivalentes; verificar escopo |
| 055 — OPERAÇÕES BANCÁRIAS | 053 — OPERAÇÃO BANCÁRIA | Títulos conceitualmente equivalentes; verificar escopo |
| 061 — PRODUÇÃO EDITORIAL | 065 — PRODUÇÃO EDITORIAL | Título coincidente; verificar descendentes |
| 063 — DOCUMENTAÇÃO ARQUIVÍSTICA | 061 — GESTÃO DE DOCUMENTOS DE ARQUIVO | Convergência temática; verificar reorganização de atividades |

**Nenhum par acima está homologado.** Nem toda semelhança implica destinação única; alguns elementos podem ter sido distribuídos por outros ramos.

## Detalhamento: 024 DE → 023 PARA

| DE (2017) | PARA (2024) | Evidência |
|---|---|---|
| 024 — DIREITOS, OBRIGAÇÕES E VANTAGENS | 023 — CONCESSÃO DE DIREITOS E VANTAGENS | Correspondência conceitual da raiz |
| 024.12 — GRATIFICAÇÕES | 023.15 — GRATIFICAÇÕES | Mesmo grupo |
| 024.122 — JETONS | 023.152 — JETONS | Mesma descrição, mesmo contexto |
| 024.123 — CARGOS EM COMISSÃO | 023.153 — CARGOS EM COMISSÃO | Mesma descrição, mesmo contexto |
| 024.13 — ADICIONAIS | 023.16 — ADICIONAIS | Mesmo grupo |
| 024.132 — NOTURNO | 023.162 — NOTURNO | Mesma descrição, mesmo contexto |
| 024.133 — PERICULOSIDADE | 023.163 — PERICULOSIDADE | Mesma descrição, mesmo contexto |
| 024.134 — INSALUBRIDADE | 023.164 — INSALUBRIDADE | Mesma descrição, mesmo contexto |
| 024.14 — DESCONTOS | 023.17 — DESCONTOS | Mesmo grupo |
| 024.143 — IMPOSTO DE RENDA RETIDO NA FONTE (IRRF) | 023.173 — IMPOSTO DE RENDA RETIDO NA FONTE (IRRF) | Mesma descrição, mesmo contexto |

O ramo de origem possui 46 registros; o destino possui 50. Isso **não implica** uma correspondência automática entre todos os registros. Investigar itens incluídos, desmembrados e transferidos para outros ramos.

## Limitação dos indicadores automáticos

A triagem automatizada usa descrições das raízes e seus descendentes; sua pontuação é apenas um **índice de seleção para revisão**, não probabilidade de acerto. Podem existir candidatos inadequados em primeiro lugar, especialmente em ramos muito pequenos ou heterogêneos.

## Próximas atividades

1. Validar manualmente o DE → PARA das 79 raízes, incluindo possibilidades 1:N, N:1 e sem correspondência, com justificativa.
2. Para cada raiz homologada, mapear grupos, subgrupos e assuntos filhos, mantendo a correspondência restrita ao contexto ancestral.
3. Identificar exceções de assuntos deslocados para fora do ramo.
4. Conferir observações, temporalidade, destinação, vigência e natureza estrutural.
5. Cruzar o mapa homologado com a frequência de uso dos assuntos no SEI de Rondônia para medir o impacto efetivo.

**Artefatos locais gerados nesta análise:** `analise_hierarquica_raizes_2017_2024.md` (triagem de todas as raízes) e `raizes_de_para_candidatos.csv` (três candidatos por raiz). Esses arquivos detalhados ainda não estão incorporados ao repositório.

# Análise comparativa da Tabela de Assuntos — 2017 × 2024

> **Status:** análise técnica preliminar — Etapa 1  
> **Objetivo:** avaliar o impacto potencial da substituição da tabela de assuntos de 2017 pela tabela de 2024 no GD-SEI/SEI.  
> **Fontes analisadas:** `tabela_2017.csv` e `tabela_2024.csv`.

## 1. Conclusão preliminar

A tabela de 2024 **não deve ser tratada como uma simples atualização incremental** da tabela de 2017. Há uma reorganização relevante da classificação, com criação e retirada de códigos, realocação de assuntos e, principalmente, **reutilização de códigos antigos com significado diferente**.

Isso significa que uma migração baseada apenas em igualdade de `codigo_estruturado` pode associar processos a assuntos semanticamente incorretos. A migração deverá considerar, no mínimo, código, descrição, posição hierárquica e propriedades arquivísticas.

## 2. Visão quantitativa

| Indicador | 2017 | 2024 |
|---|---:|---:|
| Total de registros | 701 | 684 |
| Ativos (`sin_ativo = S`) | 514 | 519 |
| Inativos (`sin_ativo = N`) | 187 | 165 |
| Estruturais (`sin_estrutural = S`) | 285 | 179 |

Após normalizar espaços indevidos nos códigos da tabela de 2017:

| Relação entre as versões | Quantidade | Interpretação inicial |
|---|---:|---|
| Código existente nas duas tabelas | 322 | Requer comparação semântica e de propriedades |
| Código somente em 2017 | 379 | Possível remoção ou realocação |
| Código somente em 2024 | 362 | Possível inclusão ou realocação |

## 3. Classificação preliminar das mudanças

Para esta etapa foi usada a seguinte regra:

- **Mantido:** mesmo código e mesma descrição normalizada.
- **Atualizado:** mesmo código, descrição alterada, mas ainda com similaridade textual suficiente para indicar provável continuidade do assunto.
- **Código reutilizado:** mesmo código, mas descrição substancialmente diferente; deve ser tratado como risco de incompatibilidade semântica.
- **Realocado:** descrição idêntica encontrada em código diferente entre 2017 e 2024.
- **Incluído / removido:** código presente em apenas uma versão, depois de descontadas as realocações idênticas detectadas.

| Situação | Quantidade |
|---|---:|
| Mantidos quanto a código + descrição | 154 |
| Atualizados no mesmo código | 22 |
| Códigos provavelmente reutilizados com outro significado | 146 |
| Assuntos identificados como realocados para outro código | 20 |
| Inclusões candidatas em 2024 | 342 |
| Remoções candidatas de 2017 | 359 |

> **Importante:** “incluído” e “removido” ainda são categorias candidatas. Uma etapa posterior de correspondência semântica poderá identificar outras realocações ou desdobramentos que não possuem descrição literalmente idêntica.

## 4. O principal risco: reutilização de código

Foram encontrados **146 códigos presentes nas duas versões cuja descrição mudou substancialmente**. Este é o ponto de maior risco para uma migração automática.

Exemplos:

| Código | Descrição 2017 | Descrição 2024 |
|---|---|---|
| `033.1` | MATERIAL PERMANENTE (Equipamentos, Mobiliário, Aparelhos, Ferramentas, Máquinas, Instrumentos Técnicos e Obras de Arte) | VENDA |
| `900` | ASSUNTOS DIVERSOS | ADMINISTRAÇÃO DE ATIVIDADES ACESSÓRIAS |
| `042.13` | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | BENS SEMOVENTES |
| `052.21` | RECEITA (inclusive Créditos do Tesouro Nacional - cota, repasse e sub-repasse; Taxas Cobradas por Serviços; Multas; Emolumentos; e outras rendas arrecadadas) | RECEITA |
| `042.32` | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | VEÍCULOS |
| `041.13` | DOAÇÃO | BENS SEMOVENTES |
| `041.23` | DOAÇÃO | BENS SEMOVENTES |
| `004` | ACORDOS. AJUSTES. CONTRATOS. CONVÊNIOS (Inclusive formalização, execução, acompanhamento, fiscalização, prestação de contas, tomada de contas e tomada de contas especial de convênios, contratos de repasse, termos de parceria e termos de cooperação) | ASSESSORAMENTO JURÍDICO |
| `031` | ESPECIFICAÇÃO. PADRONIZAÇÃO. CODIFICAÇÃO. PREVISÃO. CATÁLOGO. IDENTIFICAÇÃO. CLASSIFICAÇÃO (inclusive Amostras) | AQUISIÇÃO E INCORPORAÇÃO |
| `052.22` | DESPESA (inclusive Despesas Correntes e de Capital, bem como Adiantamentos, Subvenções, Suprimento de Fundos e Restos a Pagar) | DESPESA |
| `062.4` | REFERÊNCIA E CIRCULAÇÃO (inclusive Consultas, Pesquisas Bibliográficas, Bibliografias, Empréstimos e Intercâmbio entre Bibliotecas) | DESINCORPORAÇÃO |
| `024.4` | AFASTAMENTOS (Para Depor; Para Exercer Mandato Eletivo; Para Servir ao Tribunal Regional Eleitoral - TRE; Para Servir como Jurado; Suspensão de Contrato de Trabalho - CLT) | PARTICIPAÇÃO EM ESTÁGIOS PROMOVIDOS POR OUTROS ÓRGÃOS E ENTIDADES |
| `041.11` | COMPRA | BENS IMÓVEIS |
| `062.3` | CATALOGAÇÃO. CLASSIFICAÇÃO. INDEXAÇÃO | INVENTÁRIO |
| `019.12` | MAPEAMENTO E MODELAGEM DE PROCESSOS DE TRABALHO. ATRIBUIÇÕES E COMPETÊNCIAS | DIVULGAÇÃO INTERNA |
| `042.12` | ALUGUEL | VEÍCULOS |
| `041.1` | AQUISIÇÃO | COMPRA |
| `030` | MATERIAL (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | GESTÃO DE MATERIAIS |
| `023.11` | ADMISSÃO. APROVEITAMENTO. CONTRATAÇÃO. NOMEAÇÃO. READMISSÃO. READAPTAÇÃO. RECONDUÇÃO. REINTEGRAÇÃO. REVERSÃO | FOLHAS DE PAGAMENTO |
| `023.15` | REQUISIÇÃO. CESSÃO (Internas e/ou Externas de Servidores para a realização de serviços temporários) | GRATIFICAÇÕES |

Um exemplo claro é o código `004`: em 2017 corresponde a **ACORDOS. AJUSTES. CONTRATOS. CONVÊNIOS**, enquanto em 2024 corresponde a **ASSESSORAMENTO JURÍDICO**. Portanto, preservar o código sem revisar o significado produziria classificação incorreta.

## 5. Assuntos mantidos

Foram identificados **154 códigos com a mesma descrição** nas duas versões. Entretanto, nenhum dos 322 códigos comuns permaneceu idêntico em todos os campos analisados; portanto, “mantido” não significa “registro inalterado”.

As propriedades que mudaram entre códigos comuns foram:

| Campo | Códigos com alteração |
|---|---:|
| `descricao` | 168 |
| `observacao` | 173 |
| `sin_ativo` | 165 |
| `prazo_intermediario` | 153 |
| `prazo_corrente` | 160 |
| `sta_destinacao` | 130 |
| `sin_estrutural` | 45 |

Destaca-se que **165 códigos comuns passaram de ativo para inativo** (`S → N`). Não foi identificado movimento inverso (`N → S`) entre códigos comuns.

Na estrutura hierárquica, 33 códigos passaram de não estruturais para estruturais e 12 fizeram o movimento inverso.

## 6. Assuntos atualizados no mesmo código

Foram classificados preliminarmente **22 códigos** como atualizações textuais ou revisões ainda compatíveis com o assunto anterior.

| Código | Similaridade | Descrição 2017 | Descrição 2024 |
|---|---:|---|---|
| `081.1` | 100% | RECRUTAMENTO.SELEÇÃO: INSCRIÇÃO PARA CONCURSO, CRONOGRAMA DE REALIZAÇÃO DE PROVAS, CONTROLE DE APLICAÇÃO DAS PROVAS | RECRUTAMENTO. SELEÇÃO: INSCRIÇÃO PARA CONCURSO, CRONOGRAMA DE REALIZAÇÃO DE PROVAS, CONTROLE DE APLICAÇÃO DAS PROVAS |
| `085.2.a` | 100% | ADOTANTE, PARA ACOMPANHAR CÔNJUGE / COMPANHEIRO, CANDIDATO A CARGO ELETIVO, ESPECIAL, GESTANTE, PATERNIDADE, PARA TRATAR DE INTERESSE PARTICULAR, PARA TRATAMENTO DE SAÚDE DE PESSOA DA FAMÍLIA, PARA TRATAMENTO DE SAÚDE PRÓPRIA | ADOTANTE, PARA ACOMPANHAR CÔNJUGE/COMPANHEIRO, CANDIDATO A CARGO ELETIVO, ESPECIAL, GESTANTE, PATERNIDADE, PARA TRATAR DE INTERESSE PARTICULAR, PARA TRATAMENTO DE SAÚDE DE PESSOA DA FAMÍLIA, PARA TRATAMENTO DE SAÚDE PRÓPRIA |
| `086.211.a` | 99% | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA |
| `086.212.a` | 99% | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR VITALÍCIA | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR VITALÍCIA |
| `080.3.a` | 99% | FOLHAS DE ALTERAÇÕES, CADERNETA REGISTRO CADASTRO, CADERNETA SANITÁRIA, DECLARAÇÃO / CADASTRO DE DEPENDENTES, FICHA INDIVIDUAL, DECLARAÇÃO / ALTERAÇÃO DE BENEFICIÁRIOS, TERMO DE OPÇÃO OU DE RETIFICAÇÃO DA LICENÇA ESPECIAL, TERMO DE RENÚNCIA DE PENSÃO | FOLHAS DE ALTERAÇÕES, CADERNETA REGISTRO CADASTRO, CADERNETA SANITÁRIA, DECLARAÇÃO/CADASTRO DE DEPENDENTES, FICHA INDIVIDUAL, DECLARAÇÃO/ALTERAÇÃO DE BENEFICIÁRIOS, TERMO DE OPÇÃO OU DE RETIFICAÇÃO DA LICENÇA ESPECIAL, TERMO DE RENÚNCIA DE PENSÃO |
| `081.4.a` | 99% | INGRESSO NOS CORPOS E/OU QUADROS DE CARREIRA DE OFICIAIS, NOS POSTOS INICIAIS OU NOS CORPOS / QUADROS DE OFICIAIS DA RESERVA | INGRESSO NOS CORPOS E/OU QUADROS DE CARREIRA DE OFICIAIS, NOS POSTOS INICIAIS OU NOS CORPOS/QUADROS DE OFICIAIS DA RESERVA |
| `086.213.a` | 99% | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR ESPECIAL | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR ESPECIAL |
| `081.5` | 99% | EXERCÍCIOS DE MOBILIZAÇÃO /APRESENTAÇÃO | EXERCÍCIOS DE MOBILIZAÇÃO / APRESENTAÇÃO |
| `085.629.a` | 98% | ADICIONAL NATALINO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: INVALIDEZ, NATALIDADE E FUNERAL, SALÁRIO-FAMÍLIA, ADICIONAL POR DESIGNAÇÃO PARA O SERVIÇO ATIVO, PRO-LABORE PARA TAREFA POR TEMPO CERTO, AJUDA DE TRANSPORTE POR BAIXA / ALTA EM ORGANIZAÇÃO, HOSPI | ADICIONAL NATALINO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: INVALIDEZ, NATALIDADE E FUNERAL, SALÁRIO-FAMÍLIA, ADICIONAL DESIGNAÇÃO PARA O SERVIÇO ATIVO, PRO-LABORE PARA TAREFA POR TEMPO CERTO, AJUDA DE TRANSPORTE POR BAIXA/ALTA EM ORGANIZAÇÃO, HOSPITALAR |
| `082.3.a` | 96% | FICHAS / FOLHAS DE AVALIAÇÃO | FICHAS/FOLHAS DE AVALIAÇÃO |
| `029.4` | 92% | DELEGAÇÕES DE COMPETÊNCIA. PROCURAÇÃO | DELEGAÇÃO DE COMPETÊNCIA E PROCURAÇÃO |
| `019` | 92% | OUTROS ASSUNTOS REFERENTES À ORGANIZAÇÃO E FUNCIONAMENTO | OUTRAS AÇÕES REFERENTES À ORGANIZAÇÃO E FUNCIONAMENTO |
| `069` | 81% | OUTROS ASSUNTOS REFERENTES À DOCUMENTAÇÃO E INFORMAÇÃO | OUTRAS AÇÕES REFERENTES À GESTÃO DA DOCUMENTAÇÃO E DA INFORMAÇÃO |
| `088` | 80% | (VAGA) | VAGA |
| `060` | 79% | DOCUMENTAÇÃO E INFORMAÇÃO | GESTÃO DA DOCUMENTAÇÃO E DA INFORMAÇÃO |
| `059` | 77% | OUTROS ASSUNTOS REFERENTES A ORÇAMENTO E FINANÇAS | OUTRAS AÇÕES REFERENTES À GESTÃO ORÇAMENTÁRIA E FINANCEIRA |
| `052.1` | 76% | PROGRAMAÇÃO FINANCEIRA DE DESEMBOLSO | PROGRAMAÇÃO FINANCEIRA |
| `029` | 73% | OUTROS ASSUNTOS REFERENTES A PESSOAL | OUTRAS AÇÕES REFERENTES À GESTÃO DE PESSOAS |
| `039` | 73% | OUTROS ASSUNTOS REFERENTES A MATERIAL | OUTRAS AÇÕES REFERENTES À GESTÃO DE MATERIAIS |
| `080` | 68% | PESSOAL MILITAR | PESSOAL MILITAR - ver anexo 1 |
| `049` | 62% | OUTROS ASSUNTOS REFERENTES A PATRIMÔNIO | OUTRAS AÇÕES REFERENTES À GESTÃO DE BENS PATRIMONIAIS E DE SERVIÇOS |
| `085.619.a` | 61% | ADICIONAL DE FÉRIAS, ADICIONAL NATALINO, AJUDA DE CUSTO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: FARDAMENTO, ALIMENTAÇÃO, NATALIDADE, INVALIDEZ, FUNERAL E TRANSPORTE, COMPENSAÇÃO PECUNIÁRIA, DIÁRIAS, SALÁRIO-FAMÍLIA, TRANSPORTE DE PESSOAL E BAGAGENS POR M | ADICIONAL DE FÉRIAS E NATALINO; AJUDA DE CUSTO; ASSISTÊNCIA PRÉ-ESCOLAR; AUXÍLIOS FARDAMENTO, ALIMENTAÇÃO, NATALIDADE, INVALIDEZ, FUNERAL E TRANSPORTE; COMPENSAÇÃO; DIÁRIAS; SALÁRIO-FAMÍLIA; TRANSPORTE; ADIANTAMENTO DE FÉRIAS; RETRIBUIÇÃO NO EXTERIOR |

## 7. Realocações confirmadas por descrição idêntica

Foram encontrados **20 assuntos com descrição idêntica, mas código diferente**. Esses casos demonstram que a tabela de 2024 reorganizou parte da árvore classificatória.

| Código 2017 | Código 2024 | Assunto |
|---|---|---|
| `012.11` | `019.111` | CREDENCIAMENTO DE JORNALISTAS |
| `024.122` | `023.152` | JETONS |
| `024.123` | `023.153` | CARGOS EM COMISSÃO |
| `024.132` | `023.162` | NOTURNO |
| `024.133` | `023.163` | PERICULOSIDADE |
| `024.134` | `023.164` | INSALUBRIDADE |
| `024.14` | `023.17` | DESCONTOS |
| `024.143` | `023.173` | IMPOSTO DE RENDA RETIDO NA FONTE (IRRF) |
| `024.151` | `023.181` | PROGRAMA DE FORMAÇÃO DO PATRIMÔNIO DO SERVIDOR PÚBLICO (PASEP). PROGRAMA DE INTEGRAÇÃO SOCIAL (PIS) |
| `024.153` | `023.183` | CONTRIBUIÇÃO SINDICAL DO EMPREGADOR |
| `024.156` | `023.185` | IMPOSTO DE RENDA |
| `026.13` | `026.5` | APOSENTADORIA |
| `026.131` | `026.02` | CONTAGEM E AVERBAÇÃO DE TEMPO DE SERVIÇO |
| `026.132.b` | `026.62` | PENSÃO VITALÍCIA |
| `041.012` | `045.12` | GÁS |
| `041.41` | `045.32` | REFORMA. RECUPERAÇÃO. RESTAURAÇÃO |
| `041.42` | `045.31` | CONSTRUÇÃO |
| `042.913` | `044.5` | ESTACIONAMENTO. GARAGEM |
| `049.21` | `043.61` | PARA OUTROS IMÓVEIS |
| `049.22` | `043.62` | DENTRO DO MESMO IMÓVEL |

## 8. Inclusões candidatas em 2024

Após excluir as realocações exatas já identificadas, permanecem **342 códigos candidatos a inclusão**.

| Código 2024 | Descrição | Ativo | Estrutural |
|---|---|:---:|:---:|
| `002.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `002.1` | ACESSO À INFORMAÇÃO | S | S |
| `002.11` | PEDIDO DE ACESSO À INFORMAÇÃO E RECURSO | S | N |
| `002.12` | ACOMPANHAMENTO DO ATENDIMENTO AO CIDADÃO | S | N |
| `002.2` | CONTROLE DE SATISFAÇÃO DO USUÁRIO | S | N |
| `002.3` | ACOMPANHAMENTO DE MANIFESTAÇÃO DO USUÁRIO | S | S |
| `002.31` | TRATAMENTO DE MANIFESTAÇÃO | S | N |
| `002.32` | TRATAMENTO DE DENÚNCIA | S | N |
| `002.33` | DESENVOLVIMENTO DE AÇÕES DE OUVIDORIA ATIVA | S | N |
| `003.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `003.1` | CONTROLE INTERNO. AUDITORIA INTERNA | S | N |
| `003.2` | AÇÃO PREVENTIVA | S | N |
| `003.3` | CORREIÇÃO | S | N |
| `004.1` | ORIENTAÇÃO TÉCNICA E NORMATIVA | S | S |
| `004.11` | UNIFORMIZAÇÃO DO ENTENDIMENTO JURÍDICO | S | N |
| `004.12` | ANÁLISE DOS INSTRUMENTOS ADMINISTRATIVOS | S | N |
| `004.2` | ATUAÇÃO EM CONTENCIOSO | S | S |
| `004.21` | REPRESENTAÇÃO EXTRAJUDICIAL | S | N |
| `004.22` | REPRESENTAÇÃO JUDICIAL | S | N |
| `005` | PARTICIPAÇÃO EM ÓRGÃOS COLEGIADOS | S | S |
| `005.1` | CRIAÇÃO E ORGANIZAÇÃO | S | N |
| `005.2` | OPERACIONALIZAÇÃO DE REUNIÕES | S | N |
| `010.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `013` | COORDENAÇÃO E GESTÃO DE REUNIÕES | S | S |
| `013.1` | OPERACIONALIZAÇÃO | S | N |
| `013.2` | REGISTRO DE DELIBERAÇÕES | S | N |
| `014` | GERENCIAMENTO DE PROCESSO ELETIVO | S | S |
| `014.1` | NOMEAÇÃO E ATUAÇÃO DA COMISSÃO ELEITORAL | S | N |
| `014.2` | INSCRIÇÃO | S | N |
| `014.3` | VOTAÇÃO | S | N |
| `014.4` | DIVULGAÇÃO DOS RESULTADOS E INTERPOSIÇÃO DE RECURSOS | S | N |
| `015` | GESTÃO INSTITUCIONAL | S | S |
| `015.1` | PLANEJAMENTO INSTITUCIONAL | S | N |
| `015.2` | ACOMPANHAMENTO DAS ATIVIDADES | S | N |
| `015.3` | AVALIAÇÃO DA GESTÃO INSTITUCIONAL | S | S |
| `015.31` | ELABORAÇÃO DOS INSTRUMENTOS DE AVALIAÇÃO | S | N |
| `015.32` | EXECUÇÃO E ACOMPANHAMENTO | S | N |
| `015.33` | CERTIFICAÇÃO DA CONFORMIDADE | S | N |
| `015.4` | GOVERNANÇA | S | S |
| `015.41` | GERENCIAMENTO DE RISCO | S | N |
| `015.42` | INTEGRIDADE E CONTROLE INTERNO | S | N |
| `015.5` | ACOMPANHAMENTO DA ACREDITAÇÃO | S | N |
| `016` | GESTÃO DE PROCESSOS | S | S |
| `016.1` | PLANEJAMENTO DO MAPEAMENTO DE PROCESSOS | S | N |
| `016.2` | EXECUÇÃO E ACOMPANHAMENTO | S | N |
| `016.3` | RESULTADO | S | N |
| `016.4` | MODELAGEM DE PROCESSOS | S | N |
| `016.5` | GERENCIAMENTO DE DESEMPENHO | S | N |
| `017` | GESTÃO AMBIENTAL | S | S |
| `017.1` | PROTEÇÃO AMBIENTAL INTERNA | S | N |
| `017.2` | PROTEÇÃO AMBIENTAL EXTERNA | S | N |
| `018` | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS | S | S |
| `018.1` | CONTRATAÇÃO DE PESSOA JURÍDICA | S | N |
| `018.2` | CONTRATAÇÃO DE PESSOA FÍSICA | S | N |
| `019.112` | RELAÇÃO COM A IMPRENSA | S | N |
| `019.113` | ELABORAÇÃO DE PROPAGANDAS, CAMPANHAS DE MARKETING E PUBLICITÁRIAS | S | N |
| `019.114` | ELABORAÇÃO E ATUALIZAÇÃO DESITEINSTITUCIONAL | S | N |
| `019.14` | EXECUÇÃO E AVALIAÇÃO DE ESTRATÉGIAS | S | N |
| `020.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `020.02` | IMPLEMENTAÇÃO DAS POLÍTICAS DE PESSOAL | S | S |
| `020.021` | PLANEJAMENTO DA FORÇA DE TRABALHO. PREVISÃO DE PESSOAL | S | N |
| `020.022` | CRIAÇÃO, EXTINÇÃO, CLASSIFICAÇÃO, TRANSFORMAÇÃO E TRANSPOSIÇÃO DE CARGOS E DE CARREIRAS | S | N |
| `020.03` | RELACIONAMENTO COM ENTIDADES REPRESENTATIVAS DE CLASSES | S | S |
| `020.031` | RELAÇÃO COM SINDICATOS | S | N |
| `020.032` | MOVIMENTOS REIVINDICATÓRIOS. GREVES. PARALISAÇÕES | S | N |
| `020.033` | RELAÇÃO COM CONSELHOS PROFISSIONAIS | S | N |
| `020.1` | ASSENTAMENTO FUNCIONAL | S | S |
| `020.11` | SERVIDORES E EMPREGADOS PÚBLICOS | S | N |
| `020.12` | SERVIDORES TEMPORÁRIOS | S | N |
| `020.13` | RESIDENTES E ESTAGIÁRIOS | S | N |
| `020.14` | OCUPANTES DE CARGO COMISSIONADO E DE FUNÇÃO DE CONFIANÇA | S | N |
| `021.2` | INSCRIÇÃO | S | N |
| `021.3` | CONTROLE DE APLICAÇÃO DE PROVAS | S | N |
| `021.4` | CORREÇÃO DE PROVAS. AVALIAÇÃO | S | N |
| `021.5` | DIVULGAÇÃO DOS RESULTADOS E INTERPOSIÇÃO DE RECURSOS | S | N |
| `022.3` | REMOÇÃO | S | N |
| `022.4` | REDISTRIBUIÇÃO | S | N |
| `022.5` | SUBSTITUIÇÃO | S | N |
| `022.6` | AVALIAÇÃO DE DESEMPENHO | S | S |
| `022.61` | CUMPRIMENTO DE ESTÁGIO PROBATÓRIO. HOMOLOGAÇÃO DA ESTABILIDADE. | S | N |
| `022.62` | CUMPRIMENTO DE PERÍODO DE EXPERIÊNCIA | S | N |
| `022.63` | PROMOÇÃO E PROGRESSÃO FUNCIONAL | S | N |
| `022.7` | VACÂNCIA | S | N |
| `023.151` | FUNÇÃO | S | N |
| `023.154` | NATALINA. DÉCIMO TERCEIRO SALÁRIO | S | N |
| `023.155` | DESEMPENHO | S | N |
| `023.156` | ENCARGO DE CURSO E CONCURSO | S | N |
| `023.157` | TITULAÇÃO | S | N |
| `023.16` | ADICIONAIS | S | S |
| `023.161` | TEMPO DE SERVIÇO | S | N |
| `023.165` | ATIVIDADE PENOSA | S | N |
| `023.166` | SERVIÇO EXTRAORDINÁRIO. HORAS EXTRAS | S | N |
| `023.167` | UM TERÇO DE FÉRIAS. ABONO PECUNIÁRIO | S | N |
| `023.171` | CONTRIBUIÇÃO SINDICAL, ASSISTENCIAL E CONFEDERATIVA | S | N |
| `023.172` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | S | N |
| `023.174` | PENSÃO ALIMENTÍCIA | S | N |
| `023.175` | CONSIGNAÇÕES FACULTATIVAS | S | N |
| `023.18` | OBRIGAÇÕES TRABALHISTAS E ESTATUTÁRIAS, ENCARGOS PATRONAIS E RECOLHIMENTOS | S | S |
| `023.182` | FUNDO DE GARANTIA DO TEMPO DE SERVIÇO (FGTS) | S | N |
| `023.184` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | S | N |
| `023.186` | LEI DOS DOIS TERÇOS. RELAÇÃO ANUAL DE INFORMAÇÕES SOCIAIS (RAIS) | S | N |
| `023.19` | OUTRAS AÇÕES REFERENTES AO PAGAMENTO DE VENCIMENTOS. REMUNERAÇÕES. SALÁRIOS. PROVENTOS | S | S |
| `023.191` | RETIFICAÇÃO DE PAGAMENTO | S | N |
| `023.2` | FÉRIAS | S | N |
| `023.3` | LICENÇAS | S | N |
| `023.4` | AFASTAMENTOS | S | N |
| `023.5` | CONCESSÕES | S | N |
| `023.6` | AUXÍLIOS | S | N |
| `023.7` | REEMBOLSO DE DESPESAS. INDENIZAÇÃO | S | S |
| `023.71` | MUDANÇA DE DOMICÍLIO | S | N |
| `023.72` | LOCOMOÇÃO | S | N |
| `023.73` | RESSARCIMENTO DE PLANO DE SAÚDE | S | N |
| `023.9` | OUTRAS AÇÕES REFERENTES À CONCESSÃO DE DIREITOS E VANTAGENS | S | S |
| `023.91` | CONTRATAÇÃO DE SEGURO | S | N |
| `023.92` | OCUPAÇÃO DE IMÓVEL FUNCIONAL | S | N |
| `023.93` | FORNECIMENTO DE TRANSPORTE | S | N |
| `024.01` | PLANEJAMENTO DA CAPACITAÇÃO | S | N |
| `024.31` | PROGRAMAÇÃO | S | N |
| `024.32` | INSCRIÇÃO E FREQUÊNCIA | S | N |
| `024.33` | AVALIAÇÃO E RESULTADOS | S | N |
| `025.13` | PROMOÇÃO DE ATIVIDADE FÍSICA | S | N |
| `025.14` | REGISTRO DE ASSISTÊNCIA À SAÚDE EM PRONTUÁRIO | S | N |
| `025.2` | PRESERVAÇÃO DA SAÚDE E HIGIENE | S | S |
| `025.21` | CONTROLE DE RISCOS AMBIENTAIS | S | N |
| `025.22` | OFERTA DE SERVIÇOS DE REFEITÓRIOS, CANTINAS E COPAS | S | N |
| `025.3` | SEGURANÇA DO TRABALHO. PREVENÇÃO DE ACIDENTES DE TRABALHO | S | S |
| `025.31` | CONSTITUIÇÃO DA COMISSÃO INTERNA DE PREVENÇÃO DE ACIDENTES (CIPA) | S | S |
| `025.311` | COMPOSIÇÃO E ATUAÇÃO | S | N |
| `025.312` | OPERACIONALIZAÇÃO DE REUNIÕES | S | N |
| `025.32` | REGISTRO DE OCORRÊNCIAS DE ACIDENTES DE TRABALHO | S | N |
| `026.3` | AUXÍLIOS | S | N |
| `026.4` | LICENÇAS | S | N |
| `026.51` | INVALIDEZ PERMANENTE | S | N |
| `026.52` | COMPULSÓRIA | S | N |
| `026.53` | VOLUNTÁRIA | S | N |
| `026.54` | ESPECIAL | S | N |
| `026.6` | PENSÃO POR MORTE | S | S |
| `026.61` | PENSÃO PROVISÓRIA. PENSÃO TEMPORÁRIA | S | N |
| `026.9` | OUTRAS AÇÕES REFERENTES À CONCESSÃO DE BENEFÍCIOS DE SEGURIDADE E PREVIDÊNCIA SOCIAL | S | S |
| `026.91` | AUXÍLIO RECLUSÃO | S | N |
| `027` | APURAÇÃO DE RESPONSABILIDADE DISCIPLINAR | S | S |
| `027.1` | AVERIGUAÇÃO DE DENÚNCIAS | S | N |
| `027.2` | APLICAÇÃO DE PENALIDADES DISCIPLINARES | S | N |
| `027.3` | AJUSTAMENTO DE CONDUTA | S | N |
| `028` | CUMPRIMENTO DE MISSÕES E VIAGENS A SERVIÇO | S | S |
| `028.1` | NO PAÍS | S | S |
| `028.11` | COM ÔNUS | S | N |
| `028.12` | COM ÔNUS LIMITADO | S | N |
| `028.2` | NO EXTERIOR | S | S |
| `028.21` | COM ÔNUS | S | N |
| `028.22` | COM ÔNUS LIMITADO | S | N |
| `028.23` | SEM ÔNUS | S | N |
| `029.12` | DEFINIÇÃO DO HORÁRIO DE EXPEDIENTE | S | N |
| `029.13` | REGISTRO DAS ATIVIDADES DE TELETRABALHO | S | N |
| `029.23` | ACOMPANHAMENTO PEDAGÓGICO, MÉDICO E DO DESENVOLVIMENTO DA CRIANÇA | S | N |
| `029.24` | AVALIAÇÃO DO PROGRAMA | S | N |
| `030.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `030.02` | CADASTRAMENTO DE FORNECEDORES E DE PRESTADORES DE SERVIÇOS | S | N |
| `030.03` | ESPECIFICAÇÃO, PADRONIZAÇÃO, CODIFICAÇÃO, PREVISÃO, IDENTIFICAÇÃO E CLASSIFICAÇÃO | S | N |
| `030.04` | QUALIFICAÇÃO DE FORNECEDORES | S | N |
| `031.1` | COMPRA | S | S |
| `031.11` | MATERIAL PERMANENTE | S | N |
| `031.12` | MATERIAL DE CONSUMO | S | N |
| `031.2` | DOAÇÃO E PERMUTA | S | S |
| `031.21` | MATERIAL PERMANENTE | S | N |
| `031.22` | MATERIAL DE CONSUMO | S | N |
| `031.3` | DAÇÃO. ADJUDICAÇÃO | S | S |
| `031.31` | MATERIAL PERMANENTE | S | N |
| `031.32` | MATERIAL DE CONSUMO | S | N |
| `031.4` | CESSÃO, COMODATO E EMPRÉSTIMO | S | S |
| `031.41` | MATERIAL PERMANENTE | S | N |
| `031.42` | MATERIAL DE CONSUMO | S | N |
| `031.5` | LOCAÇÃO. ARRENDAMENTO MERCANTIL (LEASING) | S | N |
| `032.01` | TERMOS DE RESPONSABILIDADE. CAUTELA | S | N |
| `032.1` | CONTROLE DE ESTOQUE | S | N |
| `032.2` | AUTORIZAÇÃO DE ENTRADA E SAÍDA DE MATERIAL | S | N |
| `032.3` | RECOLHIMENTO DE MATERIAL INSERVÍVEL AO DEPÓSITO | S | N |
| `032.4` | TOMBAMENTO | S | N |
| `033.3` | DAÇÃO. ADJUDICAÇÃO | S | S |
| `033.31` | MATERIAL PERMANENTE | S | N |
| `033.32` | MATERIAL DE CONSUMO | S | N |
| `033.4` | DESFAZIMENTO | S | S |
| `033.41` | MATERIAL PERMANENTE | S | N |
| `033.42` | MATERIAL DE CONSUMO | S | N |
| `033.5` | CESSÃO, COMODATO E EMPRÉSTIMO | S | S |
| `033.51` | MATERIAL PERMANENTE | S | N |
| `033.52` | MATERIAL DE CONSUMO | S | N |
| `033.6` | EXTRAVIO, ROUBO, DESAPARECIMENTO, FURTO E AVARIA | S | N |
| `036.01` | COMISSÃO DE INVENTÁRIO | S | N |
| `039.1` | RACIONALIZAÇÃO DO USO DE MATERIAL | S | S |
| `039.11` | CRIAÇÃO E ATUAÇÃO DE GRUPOS DE TRABALHO | S | N |
| `039.12` | OPERACIONALIZAÇÃO DE REUNIÕES | S | N |
| `039.2` | EMPRÉSTIMO E DEVOLUÇÃO DE MATERIAL PERMANENTE | S | N |
| `040.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `041.31` | BENS IMÓVEIS | S | N |
| `041.32` | VEÍCULOS | S | N |
| `041.6` | LOCAÇÃO. ARRENDAMENTO MERCANTIL (LEASING). SUBLOCAÇÃO | S | S |
| `041.61` | BENS IMÓVEIS | S | N |
| `041.62` | VEÍCULOS | S | N |
| `041.7` | DESMEMBRAMENTO | S | N |
| `042.21` | BENS IMÓVEIS | S | N |
| `042.22` | VEÍCULOS | S | N |
| `042.23` | BENS SEMOVENTES | S | N |
| `042.51` | BENS IMÓVEIS | S | N |
| `042.52` | VEÍCULOS | S | N |
| `042.53` | BENS SEMOVENTES | S | N |
| `042.6` | LOCAÇÃO. ARRENDAMENTO. SUBLOCAÇÃO | S | N |
| `042.7` | BAIXA. DESFAZIMENTO | S | S |
| `042.71` | VEÍCULOS | S | N |
| `042.72` | BENS SEMOVENTES | S | N |
| `043.1` | REGISTRO DOS IMÓVEIS | S | N |
| `043.2` | SERVIÇOS DE CONDOMÍNIO | S | N |
| `043.3` | REINTEGRAÇÃO DE POSSE. REIVINDICAÇÃO DE DOMÍNIO. DESPEJO DE PERMISSIONÁRIO | S | N |
| `043.4` | TOMBAMENTO | S | N |
| `043.5` | INSPEÇÃO PATRIMONIAL | S | N |
| `043.6` | MUDANÇA | S | S |
| `043.7` | USO DE DEPENDÊNCIAS | S | N |
| `044.1` | CADASTRAMENTO, LICENCIAMENTO E EMPLACAMENTO | S | N |
| `044.2` | TOMBAMENTO | S | N |
| `044.3` | OCORRÊNCIA DE SINISTROS | S | N |
| `044.4` | CONTROLE DE USO | S | N |
| `044.6` | NOTIFICAÇÕES DE INFRAÇÕES E MULTAS | S | N |
| `045` | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS | S | S |
| `045.01` | SEGURO PATRIMONIAL | S | S |
| `045.1` | FORNECIMENTO DE SERVIÇOS PÚBLICOS ESSENCIAIS | S | S |
| `045.11` | ÁGUA E ESGOTAMENTO SANITÁRIO | S | N |
| `045.13` | ENERGIA ELÉTRICA | S | N |
| `045.2` | MANUTENÇÃO E REPARO DAS INSTALAÇÕES | S | S |
| `045.21` | ELEVADORES | S | S |
| `045.22` | SISTEMAS CENTRAIS DE AR CONDICIONADO | S | S |
| `045.23` | SUBESTAÇÕES ELÉTRICAS E GERADORES | S | S |
| `045.24` | CONSERVAÇÃO PREDIAL | S | S |
| `045.3` | EXECUÇÃO DE OBRAS | S | S |
| `045.33` | ADAPTAÇÃO DE USO | S | N |
| `045.4` | VIGILÂNCIA PATRIMONIAL | S | S |
| `045.5` | ABASTECIMENTO E MANUTENÇÃO DE VEÍCULOS | S | S |
| `045.6` | ASSISTÊNCIA VETERINÁRIA | S | S |
| `045.7` | ADESTRAMENTO | S | S |
| `046` | PROTEÇÃO, GUARDA E SEGURANÇA PATRIMONIAL | S | S |
| `046.1` | PREVENÇÃO DE INCÊNDIO | S | S |
| `046.11` | PLANEJAMENTO, ELABORAÇÃO E ACOMPANHAMENTO DE PROJETOS | S | N |
| `046.12` | CONSTITUIÇÃO DE BRIGADA VOLUNTÁRIA | S | N |
| `046.13` | INSTALAÇÃO E MANUTENÇÃO DE EQUIPAMENTOS DE COMBATE A INCÊNDIO | S | N |
| `046.2` | MONITORAMENTO. VIGILÂNCIA | S | N |
| `046.3` | OCORRÊNCIA DE SINISTROS | S | N |
| `046.4` | CONTROLE DE PORTARIA | S | N |
| `047` | CONTROLE DE BENS PATRIMONIAIS | S | S |
| `047.01` | COMISSÃO DE INVENTÁRIO | S | N |
| `047.1` | INVENTÁRIO DE BENS IMÓVEIS | S | N |
| `047.2` | INVENTÁRIO DE VEÍCULOS | S | N |
| `047.3` | INVENTÁRIO DE BENS SEMOVENTES | S | N |
| `050.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `050.02` | CONFORMIDADE DE REGISTRO DE GESTÃO | S | N |
| `050.03` | CONFORMIDADE CONTÁBIL | S | N |
| `051.3` | EXECUÇÃO ORÇAMENTÁRIA | S | N |
| `051.4` | RETIFICAÇÃO ORÇAMENTÁRIA. CRÉDITOS ADICIONAIS | S | N |
| `052.211` | RECEITA CORRENTE | S | N |
| `052.212` | RECEITA DE CAPITAL | S | N |
| `052.213` | INGRESSO EXTRAORÇAMENTÁRIO | S | N |
| `052.221` | DESPESA CORRENTE | S | N |
| `052.222` | DESPESA DE CAPITAL | S | N |
| `052.23` | DEMONSTRAÇÃO CONTÁBIL | S | N |
| `052.24` | GESTÃO DE FUNDOS ESPECIAIS | S | N |
| `052.25` | GERENCIAMENTO DE BENEFÍCIOS, ESTÍMULOS E INCENTIVOS | S | S |
| `052.251` | FINANCEIROS | S | N |
| `052.252` | CREDITÍCIOS | S | N |
| `053.01` | CONCILIAÇÃO BANCÁRIA | S | N |
| `053.1` | PAGAMENTO EM MOEDA ESTRANGEIRA | S | N |
| `053.2` | GESTÃO DA CONTA ÚNICA | S | N |
| `053.3` | GESTÃO DE CONTAS CORRENTES BANCÁRIAS: TIPO A, B, C, D e E | S | N |
| `053.4` | GESTÃO DE CONTAS ESPECIAIS | S | N |
| `054.1` | PRESTAÇÃO DE CONTAS. TOMADA DE CONTAS | S | N |
| `054.2` | TOMADA DE CONTAS ESPECIAL | S | N |
| `059.2` | RECOLHIMENTO DE IMPOSTOS, TAXAS E DEMAIS TRIBUTOS | S | N |
| `059.3` | FIXAÇÃO DE CUSTOS DE SERVIÇOS | S | N |
| `059.4` | DEVOLUÇÃO AO ERÁRIO | S | N |
| `059.5` | RESTITUIÇÃO DE RENDAS ARRECADADAS | S | N |
| `060.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `061.01` | CONSTITUIÇÃO DA COMISSÃO PERMANENTE DE AVALIAÇÃO DE DOCUMENTOS (CPAD) | S | S |
| `061.011` | COMPOSIÇÃO E ATUAÇÃO | S | N |
| `061.012` | OPERACIONALIZAÇÃO DE REUNIÕES | S | N |
| `061.3` | LEVANTAMENTO DA PRODUÇÃO E DO FLUXO DOCUMENTAL | S | N |
| `061.4` | ELABORAÇÃO DOS INSTRUMENTOS TÉCNICOS DE GESTÃO DE DOCUMENTOS | S | N |
| `061.5` | APLICAÇÃO DOS INSTRUMENTOS TÉCNICOS DE GESTÃO DE DOCUMENTOS | S | S |
| `061.51` | CLASSIFICAÇÃO | S | N |
| `061.52` | AVALIAÇÃO | S | S |
| `061.521` | ELIMINAÇÃO | S | N |
| `061.522` | TRANSFERÊNCIA | S | N |
| `061.523` | RECOLHIMENTO | S | N |
| `062.21` | REGISTRO | S | N |
| `062.22` | CATALOGAÇÃO, CLASSIFICAÇÃO E INDEXAÇÃO | S | N |
| `062.41` | DOAÇÃO | S | N |
| `062.42` | DESCARTE | S | N |
| `063.1` | CONSULTAS | S | N |
| `063.4` | MUDANÇA DE ACERVOS | S | N |
| `064.01` | AVALIAÇÃO E MONITORAMENTO | S | N |
| `064.1` | DESINFESTAÇÃO E HIGIENIZAÇÃO | S | N |
| `064.2` | CONTROLE DAS ÁREAS DE ARMAZENAMENTO | S | N |
| `064.3` | REFORMATAÇÃO | S | S |
| `064.31` | MICROFILMAGEM | S | N |
| `064.32` | DIGITALIZAÇÃO | S | N |
| `064.4` | RESTAURAÇÃO | S | N |
| `065.1` | EDIÇÃO. COEDIÇÃO | S | N |
| `065.2` | EDITORAÇÃO E PROGRAMAÇÃO VISUAL | S | N |
| `065.3` | PROMOÇÃO, DIVULGAÇÃO E DISTRIBUIÇÃO | S | N |
| `066.31` | PROJETO DE MANUTENÇÃO | S | N |
| `066.32` | GERENCIAMENTO E USO | S | N |
| `066.4` | ADMINISTRAÇÃO DE BANCO DE DADOS | S | S |
| `066.41` | INSTALAÇÃO E CONFIGURAÇÃO | S | N |
| `066.42` | GERENCIAMENTO E USO | S | N |
| `066.9` | OUTRAS AÇÕES REFERENTES À GESTÃO DE TECNOLOGIA DA INFORMAÇÃO | S | S |
| `066.91` | CONTROLE DO SUPORTE TÉCNICO | S | N |
| `069.1` | TRATAMENTO TÉCNICO DA DOCUMENTAÇÃO ARQUIVÍSTICA PERMANENTE | S | S |
| `069.11` | ARRANJO E DESCRIÇÃO | S | N |
| `069.12` | ELABORAÇÃO DE INSTRUMENTOS DE PESQUISA | S | N |
| `069.2` | FORNECIMENTO DE CÓPIAS DE DOCUMENTOS | S | N |
| `069.3` | PUBLICAÇÃO DE MATÉRIAS | S | N |
| `070.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `071.4` | SERVIÇO DE TELEFONIA. SERVIÇO DE FAX | S | S |
| `071.5` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | S | S |
| `073.2` | SERVIÇO DE TELEX | S | N |
| `073.3` | SERVIÇO DE TELEFONIA. SERVIÇO DE FAX | S | S |
| `073.31` | TRANSFERÊNCIA DE PROPRIEDADE OU TITULARIDADE | S | N |
| `073.32` | REGISTRO DE LIGAÇÕES | S | N |
| `073.33` | DIVULGAÇÃO DE LISTAS TELEFÔNICAS INTERNAS | S | N |
| `073.4` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | S | N |
| `910` | GESTÃO DE EVENTOS | S | S |
| `910.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `911` | PLANEJAMENTO E PROGRAMAÇÃO | S | N |
| `912` | DIVULGAÇÃO | S | N |
| `913` | INSCRIÇÃO E CONTROLE DE FREQUÊNCIA | S | N |
| `914` | EMISSÃO DE CERTIFICADOS | S | N |
| `915` | AVALIAÇÃO DOS RESULTADOS | S | N |
| `916` | HABILITAÇÃO, JULGAMENTO E RECURSOS | S | N |
| `917` | PREMIAÇÃO | S | N |
| `918` | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS | S | S |
| `919` | OUTRAS AÇÕES REFERENTES À GESTÃO DE EVENTOS | S | S |
| `919.1` | PARTICIPAÇÃO EM EVENTOS PROMOVIDOS E REALIZADOS POR OUTRAS INSTITUIÇÕES | S | N |
| `920` | PROMOÇÃO DE VISITAS | S | S |
| `920.01` | NORMATIZAÇÃO. REGULAMENTAÇÃO | S | N |
| `921` | PROGRAMAÇÃO DE VISITAS | S | N |
| `922` | CONTROLE DE VISITAS E VISITANTES | S | N |

## 9. Remoções candidatas da tabela de 2017

Após excluir as realocações exatas já identificadas, permanecem **359 códigos candidatos a remoção**.

| Código 2017 | Descrição | Ativo | Estrutural |
|---|---|:---:|:---:|
| `010.1` | REGISTRO NOS ÓRGÃOS COMPETENTES | S | N |
| `010.2` | REGIMENTOS. REGULAMENTOS. ESTATUTOS. ORGANOGRAMAS. ESTRUTURAS | S | N |
| `010.3` | AUDIÊNCIAS. DESPACHOS. REUNIÕES | S | N |
| `012.1` | RELAÇÕES COM A IMPRENSA | S | N |
| `012.12` | ENTREVISTAS. NOTICIÁRIOS. REPORTAGENS. EDITORIAIS | S | N |
| `012.2` | DIVULGAÇÃO INTERNA | S | N |
| `012.3` | CAMPANHAS INSTITUCIONAIS. PUBLICIDADE (inclusive Cartazes, Folhetos, Anúncios, Folders e outros documentos de caráter promocional) | S | N |
| `019.01` | INFORMAÇÕES SOBRE O ÓRGÃO (inclusive Pedidos de Informações sobre as Funções e Atividades do Órgão e os Serviços que presta) | S | N |
| `019.3` | RESPONSABILIDADE SOCIAL / VOLUNTARIADO | S | N |
| `019.4` | PROGRAMAS SOCIOEDUCATIVOS | S | N |
| `020.1a` | LEGISLAÇÃO (Normas, Regulamentações, Diretrizes, Estatutos, Regulamentos, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | S | N |
| `020.1b` | LEGISLAÇÃO (Boletins Administrativo, de Pessoal e de Serviço) | S | N |
| `020.3` | OBRIGAÇÕES TRABALHISTAS E ESTATUTÁRIAS. RELAÇÕES COM ÓRGÃOS NORMATIZADORES DA ADMINISTRAÇÃO PÚBLICA. LEI DOS 2/3. RAIS | S | N |
| `020.31` | RELAÇÕES COM OS CONSELHOS PROFISSIONAIS | S | N |
| `020.4` | SINDICATOS. ACORDOS. DISSÍDIOS | S | N |
| `020.5` | ASSENTAMENTOS INDIVIDUAIS. CADASTRO (Vida Funcional do Servidor, bem como os registros e/ou anotações a ele referidos) | S | N |
| `021.2a` | EXAMES DE SELEÇÃO (Concurso Público: Provas e Títulos, Testes Psicotécnicos e Exames Médicos) | S | N |
| `021.2b` | EXAMES DE SELEÇÃO (Concurso Público: Constituição de Bancas Examinadoras, Editais, Exemplares Únicos de Provas, Gabaritos, Resultados e Recursos) | S | N |
| `022.11` | PROMOVIDOS PELA INSTITUIÇÃO (inclusive Propostas, Estudos, Editais, Programas, Relatórios Finais, Exemplares Únicos de Exercícios, Relação de Participantes, Avaliação e Controle de Expedição de Certificados) | S | N |
| `022.12` | PROMOVIDOS POR OUTRAS INSTITUIÇÕES | S | S |
| `022.121` | NO BRASIL | S | N |
| `022.122` | NO EXTERIOR | S | N |
| `022.221` | NO BRASIL | S | N |
| `022.222` | NO EXTERIOR | S | N |
| `022.9` | OUTROS ASSUNTOS REFERENTES A APERFEIÇOAMENTO E TREINAMENTO (inclusive Palestras e Reuniões de caráter informativo geral promovidas pelo órgão) | S | S |
| `023.01` | ESTUDOS E PREVISÃO DE PESSOAL | S | N |
| `023.02` | CRIAÇÃO, CLASSIFICAÇÃO, TRANSFORMAÇÃO, TRANSPOSIÇÃO E REMUNERAÇÃO DE CARGOS E FUNÇÕES | S | N |
| `023.03` | REESTRUTURAÇÕES E ALTERAÇÕES SALARIAIS (inclusive Ascensão e Progressão Funcional; Avaliação de Desempenho; Enquadramento; Equiparação, Reajuste e Reposição Salarial; Promoções) | S | N |
| `024.111` | SALÁRIO-FAMÍLIA | S | N |
| `024.112.a` | ABONO OU PROVENTO PROVISÓRIO | S | N |
| `024.112.b` | ABONO DE PERMANÊNCIA EM SERVIÇO | S | N |
| `024.119` | OUTROS SALÁRIOS, VENCIMENTOS, PROVENTOS E REMUNERAÇÕES | S | N |
| `024.121` | DE FUNÇÃO | S | N |
| `024.124` | NATALINA (Décimo Terceiro Salário) | S | N |
| `024.129` | OUTRAS GRATIFICAÇÕES | S | N |
| `024.131` | TEMPO DE SERVIÇO (Anuênios, Biênios e Quinquênios) | S | N |
| `024.135` | ATIVIDADES PENOSAS | S | N |
| `024.136` | SERVIÇO EXTRAORDINÁRIO (Horas Extras) | S | N |
| `024.137` | FÉRIAS: ADICIONAL DE 1/3 E ABONO PECUNIÁRIO | S | N |
| `024.139` | OUTROS ADICIONAIS | S | N |
| `024.141` | CONTRIBUIÇÃO SINDICAL DO SERVIDOR | S | N |
| `024.142` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | S | N |
| `024.144` | PENSÕES ALIMENTÍCIAS | S | N |
| `024.145` | CONSIGNAÇÕES | S | N |
| `024.149` | OUTROS DESCONTOS | S | N |
| `024.15` | ENCARGOS PATRONAIS. RECOLHIMENTOS | S | S |
| `024.152` | FUNDO DE GARANTIA POR TEMPO DE SERVIÇO (FGTS) | S | N |
| `024.154` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL (inclusive Contribuições anteriores) | S | N |
| `024.155` | SALÁRIO MATERNIDADE | S | N |
| `024.59` | OUTROS REEMBOLSOS | S | N |
| `024.9` | OUTROS DIREITOS, OBRIGAÇÕES E VANTAGENS | S | S |
| `024.91` | CONCESSÕES (Doação de Sangue; Alistamento Eleitoral; Casamento - Gala; Falecimento de Familiares - Nojo; Horário Especial para Servidor Estudante; Horário Especial para Servidor Portador de Deficiência) | S | N |
| `024.92` | AUXÍLIOS (Alimentação/Refeição; Assistência Pré-Escolar/Creche; Fardamento/Uniforme; Moradia; Vale-Transporte) | S | N |
| `026.11` | SEGUROS | S | N |
| `026.12a` | AUXÍLIOS (Acidente; Doença; Funeral; Natalidade) | S | N |
| `026.12b` | AUXÍLIOS (Reclusão) | S | N |
| `026.132.a` | PENSÕES: PROVISÓRIA E TEMPORÁRIA | S | N |
| `026.19` | OUTROS BENEFÍCIOS | S | S |
| `026.191` | ADIANTAMENTOS E EMPRÉSTIMOS A SERVIDORES | S | N |
| `026.192.a` | ASSISTÊNCIA À SAÚDE (inclusive Planos de Saúde) | S | N |
| `026.192.b` | ASSISTÊNCIA À SAÚDE (Prontuário Médico do Servidor) | S | N |
| `026.193` | AQUISIÇÃO DE IMÓVEIS | S | N |
| `026.194` | OCUPAÇÃO DE IMÓVEIS PRÓPRIOS DA UNIÃO | S | N |
| `026.195` | TRANSPORTES PARA SERVIDORES | S | N |
| `026.21a` | PREVENÇÃO DE ACIDENTES DE TRABALHO | S | N |
| `026.21b` | COMISSÃO INTERNA DE PREVENÇÃO DE ACIDENTES - CIPA (inclusive Criação, Designação, Propostas, Relatórios e Atas) | S | N |
| `026.22` | REFEITÓRIOS, CANTINAS E COPAS (Fornecimento de Refeições) | S | N |
| `026.23` | INSPEÇÕES PERIÓDICAS DE SAÚDE | S | N |
| `029.221` | SEM ÔNUS PARA A INSTITUIÇÃO | S | N |
| `029.222` | COM ÔNUS PARA A INSTITUIÇÃO (Autorização de Afastamento; Diárias, inclusive Compra de Moeda Estrangeira; Lista de Participantes, no caso de Comitivas e Delegações; Passagens; Passaportes; Prestações de Contas; Relatórios de Viagem; Reservas de Hotel) | S | N |
| `029.31` | PRÊMIOS (Concessão de Medalhas, Diplomas de Honra ao Mérito e Elogios) | S | N |
| `029.7` | MOVIMENTOS REIVINDICATÓRIOS: GREVES E PARALISAÇÕES | S | N |
| `030.1` | CADASTRO DE FORNECEDORES | S | N |
| `033.13a` | EMPRÉSTIMO. CESSÃO | S | N |
| `033.13b` | DOAÇÃO. PERMUTA | S | N |
| `033.23` | CONFECÇÃO DE IMPRESSOS (inclusive Formulários, Convites, Cartazes, Cartões e outros) | S | N |
| `034.01` | TERMOS DE RESPONSABILIDADE (inclusive Relatório de Movimentação de Bens Móveis - RMBM) | S | N |
| `034.1` | CONTROLE DE ESTOQUE (inclusive Requisição, Distribuição e Relatório de Movimentação de Almoxarifado - RMA) | S | N |
| `034.2` | EXTRAVIO. ROUBO. DESAPARECIMENTO | S | N |
| `034.3` | TRANSPORTE DE MATERIAL | S | N |
| `034.4` | AUTORIZAÇÃO DE SAÍDA DE MATERIAL | S | N |
| `034.5` | RECOLHIMENTO DE MATERIAL AO DEPÓSITO | S | N |
| `035.1` | VENDA (inclusive Leilão) | S | N |
| `035.2` | CESSÃO. DOAÇÃO. PERMUTA | S | N |
| `037` | INVENTÁRIO | S | S |
| `037.1` | MATERIAL PERMANENTE | S | N |
| `037.2` | MATERIAL DE CONSUMO | S | N |
| `041.01` | FORNECIMENTO E MANUTENÇÃO DE SERVIÇOS BÁSICOS | S | S |
| `041.011` | ÁGUA E ESGOTO | S | N |
| `041.013` | LUZ E FORÇA | S | N |
| `041.02` | COMISSÃO INTERNA DE CONSERVAÇÃO DE ENERGIA - CICE (Criação, Designação, Propostas de Redução de Gastos com Energia, Relatórios e Atas) | S | N |
| `041.03` | CONDOMÍNIO | S | N |
| `041.14` | PERMUTA | S | N |
| `041.15` | LOCAÇÃO. ARRENDAMENTO. COMODATO | S | N |
| `041.24` | PERMUTA | S | N |
| `041.54` | LIMPEZA. IMUNIZAÇÃO. DESINFESTAÇÃO (inclusive para Jardins) | S | N |
| `041.59` | OUTROS SERVIÇOS DE MANUTENÇÃO | S | S |
| `042.9` | OUTROS ASSUNTOS REFERENTES A VEÍCULOS | S | S |
| `042.91` | CONTROLE DE USO DE VEÍCULOS | S | N |
| `042.911` | REQUISIÇÃO | S | N |
| `042.912` | AUTORIZAÇÃO PARA USO FORA DO HORÁRIO DE EXPEDIENTE | S | N |
| `049.13a` | PREVENÇÃO DE INCÊNDIO (Treinamento de Pessoal, Instalação e Manutenção de Extintores, Inspeções Periódicas) | S | N |
| `049.13b` | PREVENÇÃO DE INCÊNDIO (Constituição de Brigadas de Incêndio, Planos, Projetos e Relatórios) | S | N |
| `049.14` | SINISTRO (inclusive Vistorias, Sindicâncias e Perícias Técnicas relativas a Arrombamento, Desaparecimento, Extravio, Incêndio e Roubo) | S | N |
| `049.15a` | CONTROLE DE PORTARIA (Entrada e Saída de Pessoas, Materiais e Veículos; Permissão para Entrada e Permanência fora do horário de expediente; Controle de Entrega e Devolução de Chaves) | S | N |
| `049.15b` | CONTROLE DE PORTARIA (Registro de Ocorrências) | S | N |
| `049.2` | MUDANÇAS | S | S |
| `049.3` | USO DE DEPENDÊNCIAS (Utilização de Auditório e demais Dependências do Imóvel, pelo órgão ou por terceiros) | S | N |
| `049.4` | GESTÃO DE RESÍDUOS (incluem-se documentos referentes à reciclagem de resíduos e outras formas de destinação ambiental) | S | N |
| `050.1` | AUDITORIA | S | N |
| `050.2` | Verbas Fundo Nacional de Desenvolvimento da Educação (FNDE) | S | N |
| `051.11` | PREVISÃO ORÇAMENTÁRIA | S | N |
| `051.12` | PROPOSTA ORÇAMENTÁRIA | S | N |
| `051.13` | QUADRO DE DETALHAMENTO DE DESPESA - QDD (inclusive as Metas e Destinação de Recursos e Receitas por Fontes) | S | N |
| `051.14` | CRÉDITOS ADICIONAIS (Crédito Suplementar. Crédito Especial. Crédito Extraordinário) | S | N |
| `051.21` | DESCENTRALIZAÇÃO DE RECURSOS (Distribuição Orçamentária) (Transferências, Provisão, Destaques, Estornos e Subvenções) | S | N |
| `051.22` | ACOMPANHAMENTO DE DESPESA MENSAL (Pessoal/Dívida) | S | N |
| `051.23` | PLANO OPERATIVO. CRONOGRAMA DE DESEMBOLSO | S | N |
| `055` | OPERAÇÕES BANCÁRIAS | S | S |
| `055.01` | PAGAMENTOS EM MOEDA ESTRANGEIRA | S | N |
| `055.1` | CONTA ÚNICA (inclusive Assinaturas Autorizadas e Extratos de Contas) | S | N |
| `055.2` | OUTRAS CONTAS: TIPO B, C e D (inclusive Assinaturas Autorizadas e Extratos de Contas) | S | N |
| `056` | BALANÇOS. BALANCETES | S | N |
| `057` | TOMADA DE CONTAS. PRESTAÇÃO DE CONTAS (inclusive Parecer de Aprovação das Contas). TOMADA DE CONSTAS ESPECIAL | S | N |
| `060.1` | PUBLICAÇÃO DE MATÉRIAS NO DIÁRIO OFICIAL | S | N |
| `060.2` | PUBLICAÇÃO DE MATÉRIAS NOS BOLETINS ADMINISTRATIVO, DE PESSOAL E DE SERVIÇO | S | N |
| `060.3` | PUBLICAÇÃO DE MATÉRIAS EM OUTROS PERIÓDICOS | S | N |
| `062.01` | NORMAS E MANUAIS (inclusive Estudos e Textos referentes à Elaboração de Metodologias e Procedimentos Técnicos adotados para o Tratamento da Documentação Bibliográfica) | S | N |
| `062.5` | INVENTÁRIO | S | N |
| `063.01` | NORMAS E MANUAIS (inclusive Estudos e Orientações referentes à Elaboração de Documentos, Metodologias e Procedimentos Técnicos) | S | N |
| `063.1a` | PRODUÇÃO DE DOCUMENTOS. LEVANTAMENTO. DIAGNÓSTICO. FLUXO | S | N |
| `063.1b` | PRODUÇÃO DE DOCUMENTOS. LEVANTAMENTO. DIAGNÓSTICO. FLUXO (Diagnóstico) | S | N |
| `063.4a` | CLASSIFICAÇÃO E ARQUIVAMENTO | S | N |
| `063.4b` | CLASSIFICAÇÃO E ARQUIVAMENTO (Códigos de Classificação de Documentos) | S | N |
| `063.5` | POLÍTICA DE ACESSO AOS DOCUMENTOS | S | N |
| `063.51` | CONSULTAS. EMPRÉSTIMOS | S | N |
| `063.6` | DESTINAÇÃO DE DOCUMENTOS | S | S |
| `063.61a` | ANÁLISE. AVALIAÇÃO. SELEÇÃO | S | N |
| `063.61b` | ANÁLISE. AVALIAÇÃO. SELEÇÃO (Tabela de Temporalidade) | S | N |
| `063.62` | ELIMINAÇÃO (inclusive Termos, Listagens e Editais de Ciência de Eliminação) | S | N |
| `063.63` | TRANSFERÊNCIA. RECOLHIMENTO (inclusive Guias e Termos de Transferência; Guias, Relações e Termos de Recolhimento; e Listagens Descritivas do Acervo) | S | N |
| `067.1` | PLANOS E PROJETOS | S | N |
| `067.2` | PROGRAMAS. SISTEMAS. REDES (inclusive Licença e Registro de Uso e Compra) | S | N |
| `067.21` | MANUAIS TÉCNICOS (Exemplares Únicos) | S | N |
| `067.22` | MANUAIS DO USUÁRIO (Exemplares Únicos) | S | N |
| `067.3` | ASSISTÊNCIA TÉCNICA | S | N |
| `071.11` | NACIONAL | S | N |
| `071.12` | INTERNACIONAL | S | N |
| `071.9` | OUTROS SERVIÇOS POSTAIS | S | N |
| `072.1` | INSTALAÇÃO. MANUTENÇÃO. REPARO | S | N |
| `074` | SERVIÇO TELEFÔNICO (inclusive Autorização para Ligações Interurbanas). FAC-SÍMILE (Fax) | S | N |
| `074.1` | INSTALAÇÃO. TRANSFERÊNCIA. MANUTENÇÃO. REPARO | S | N |
| `074.2` | LISTAS TELEFÔNICAS INTERNAS | S | N |
| `074.3` | CONTAS TELEFÔNICAS | S | N |
| `075` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | S | N |
| `079` | OUTROS ASSUNTOS REFERENTES A COMUNICAÇÕES | S | S |
| `090` | OUTROS ASSUNTOS REFERENTES À ADMINISTRAÇÃO GERAL | S | S |
| `091` | AÇÕES JUDICIAIS | S | N |
| `092` | CONTRATAÇÃO E EXECUÇÃO DE SERVIÇO (Incluem-se documentos referentes a todas as fases da prestação de serviço por pessoa jurídica: Licitação, Contratação, Execução, Acompanhamento e Pagamento) | S | N |
| `098.1` | Assunto adicional reservado para a Área-Meio 1 | N | S |
| `098.11` | Assunto adicional reservado para a Área-Meio 2 | N | S |
| `098.12` | Assunto adicional reservado para a Área-Meio 3 | N | S |
| `098.13` | Assunto adicional reservado para a Área-Meio 4 | N | S |
| `098.14` | Assunto adicional reservado para a Área-Meio 5 | N | S |
| `098.15` | Assunto adicional reservado para a Área-Meio 6 | N | S |
| `098.16` | Assunto adicional reservado para a Área-Meio 7 | N | S |
| `098.17` | Assunto adicional reservado para a Área-Meio 8 | N | S |
| `098.18` | Assunto adicional reservado para a Área-Meio 9 | N | S |
| `098.19` | Assunto adicional reservado para a Área-Meio 10 | N | S |
| `098.2` | Assunto adicional reservado para a Área-Meio 11 | N | S |
| `098.21` | Assunto adicional reservado para a Área-Meio 12 | N | S |
| `098.22` | Assunto adicional reservado para a Área-Meio 13 | N | S |
| `098.23` | Assunto adicional reservado para a Área-Meio 14 | N | S |
| `098.24` | Assunto adicional reservado para a Área-Meio 15 | N | S |
| `098.25` | Assunto adicional reservado para a Área-Meio 16 | N | S |
| `098.26` | Assunto adicional reservado para a Área-Meio 17 | N | S |
| `098.27` | Assunto adicional reservado para a Área-Meio 18 | N | S |
| `098.28` | Assunto adicional reservado para a Área-Meio 19 | N | S |
| `098.29` | Assunto adicional reservado para a Área-Meio 20 | N | S |
| `098.3` | Assunto adicional reservado para a Área-Meio 21 | N | S |
| `098.31` | Assunto adicional reservado para a Área-Meio 22 | N | S |
| `098.32` | Assunto adicional reservado para a Área-Meio 23 | N | S |
| `098.33` | Assunto adicional reservado para a Área-Meio 24 | N | S |
| `098.34` | Assunto adicional reservado para a Área-Meio 25 | N | S |
| `098.35` | Assunto adicional reservado para a Área-Meio 26 | N | S |
| `098.36` | Assunto adicional reservado para a Área-Meio 27 | N | S |
| `098.37` | Assunto adicional reservado para a Área-Meio 28 | N | S |
| `098.38` | Assunto adicional reservado para a Área-Meio 29 | N | S |
| `098.39` | Assunto adicional reservado para a Área-Meio 30 | N | S |
| `098.4` | Assunto adicional reservado para a Área-Meio 31 | N | S |
| `098.41` | Assunto adicional reservado para a Área-Meio 32 | N | S |
| `098.42` | Assunto adicional reservado para a Área-Meio 33 | N | S |
| `098.43` | Assunto adicional reservado para a Área-Meio 34 | N | S |
| `098.44` | Assunto adicional reservado para a Área-Meio 35 | N | S |
| `098.45` | Assunto adicional reservado para a Área-Meio 36 | N | S |
| `098.46` | Assunto adicional reservado para a Área-Meio 37 | N | S |
| `098.47` | Assunto adicional reservado para a Área-Meio 38 | N | S |
| `098.48` | Assunto adicional reservado para a Área-Meio 39 | N | S |
| `098.49` | Assunto adicional reservado para a Área-Meio 40 | N | S |
| `098.5` | Assunto adicional reservado para a Área-Meio 41 | N | S |
| `098.51` | Assunto adicional reservado para a Área-Meio 42 | N | S |
| `098.52` | Assunto adicional reservado para a Área-Meio 43 | N | S |
| `098.53` | Assunto adicional reservado para a Área-Meio 44 | N | S |
| `098.54` | Assunto adicional reservado para a Área-Meio 45 | N | S |
| `098.55` | Assunto adicional reservado para a Área-Meio 46 | N | S |
| `098.56` | Assunto adicional reservado para a Área-Meio 47 | N | S |
| `098.57` | Assunto adicional reservado para a Área-Meio 48 | N | S |
| `098.58` | Assunto adicional reservado para a Área-Meio 49 | N | S |
| `098.59` | Assunto adicional reservado para a Área-Meio 50 | N | S |
| `098.6` | Assunto adicional reservado para a Área-Meio 51 | N | S |
| `098.61` | Assunto adicional reservado para a Área-Meio 52 | N | S |
| `098.62` | Assunto adicional reservado para a Área-Meio 53 | N | S |
| `098.63` | Assunto adicional reservado para a Área-Meio 54 | N | S |
| `098.64` | Assunto adicional reservado para a Área-Meio 55 | N | S |
| `098.65` | Assunto adicional reservado para a Área-Meio 56 | N | S |
| `098.66` | Assunto adicional reservado para a Área-Meio 57 | N | S |
| `098.67` | Assunto adicional reservado para a Área-Meio 58 | N | S |
| `098.68` | Assunto adicional reservado para a Área-Meio 59 | N | S |
| `098.69` | Assunto adicional reservado para a Área-Meio 60 | N | S |
| `098.7` | Assunto adicional reservado para a Área-Meio 61 | N | S |
| `098.71` | Assunto adicional reservado para a Área-Meio 62 | N | S |
| `098.72` | Assunto adicional reservado para a Área-Meio 63 | N | S |
| `098.73` | Assunto adicional reservado para a Área-Meio 64 | N | S |
| `098.74` | Assunto adicional reservado para a Área-Meio 65 | N | S |
| `098.75` | Assunto adicional reservado para a Área-Meio 66 | N | S |
| `098.76` | Assunto adicional reservado para a Área-Meio 67 | N | S |
| `098.77` | Assunto adicional reservado para a Área-Meio 68 | N | S |
| `098.78` | Assunto adicional reservado para a Área-Meio 69 | N | S |
| `098.79` | Assunto adicional reservado para a Área-Meio 70 | N | S |
| `098.8` | Assunto adicional reservado para a Área-Meio 71 | N | S |
| `098.81` | Assunto adicional reservado para a Área-Meio 72 | N | S |
| `098.82` | Assunto adicional reservado para a Área-Meio 73 | N | S |
| `098.83` | Assunto adicional reservado para a Área-Meio 74 | N | S |
| `098.84` | Assunto adicional reservado para a Área-Meio 75 | N | S |
| `098.85` | Assunto adicional reservado para a Área-Meio 76 | N | S |
| `098.86` | Assunto adicional reservado para a Área-Meio 77 | N | S |
| `098.87` | Assunto adicional reservado para a Área-Meio 78 | N | S |
| `098.88` | Assunto adicional reservado para a Área-Meio 79 | N | S |
| `098.89` | Assunto adicional reservado para a Área-Meio 80 | N | S |
| `098.9` | Assunto adicional reservado para a Área-Meio 81 | N | S |
| `098.91` | Assunto adicional reservado para a Área-Meio 82 | N | S |
| `098.92` | Assunto adicional reservado para a Área-Meio 83 | N | S |
| `098.93` | Assunto adicional reservado para a Área-Meio 84 | N | S |
| `098.94` | Assunto adicional reservado para a Área-Meio 85 | N | S |
| `098.95` | Assunto adicional reservado para a Área-Meio 86 | N | S |
| `098.96` | Assunto adicional reservado para a Área-Meio 87 | N | S |
| `098.97` | Assunto adicional reservado para a Área-Meio 88 | N | S |
| `098.98` | Assunto adicional reservado para a Área-Meio 89 | N | S |
| `098.99` | Assunto adicional reservado para a Área-Meio 90 | N | S |
| `099.1` | Assunto adicional reservado para a Área-Meio 91 | N | S |
| `099.11` | Assunto adicional reservado para a Área-Meio 92 | N | S |
| `099.12` | Assunto adicional reservado para a Área-Meio 93 | N | S |
| `099.13` | Assunto adicional reservado para a Área-Meio 94 | N | S |
| `099.14` | Assunto adicional reservado para a Área-Meio 95 | N | S |
| `099.15` | Assunto adicional reservado para a Área-Meio 96 | N | S |
| `099.16` | Assunto adicional reservado para a Área-Meio 97 | N | S |
| `099.17` | Assunto adicional reservado para a Área-Meio 98 | N | S |
| `099.18` | Assunto adicional reservado para a Área-Meio 99 | N | S |
| `099.19` | Assunto adicional reservado para a Área-Meio 100 | N | S |
| `099.2` | Assunto adicional reservado para a Área-Meio 101 | N | S |
| `099.21` | Assunto adicional reservado para a Área-Meio 102 | N | S |
| `099.22` | Assunto adicional reservado para a Área-Meio 103 | N | S |
| `099.23` | Assunto adicional reservado para a Área-Meio 104 | N | S |
| `099.24` | Assunto adicional reservado para a Área-Meio 105 | N | S |
| `099.25` | Assunto adicional reservado para a Área-Meio 106 | N | S |
| `099.26` | Assunto adicional reservado para a Área-Meio 107 | N | S |
| `099.27` | Assunto adicional reservado para a Área-Meio 108 | N | S |
| `099.28` | Assunto adicional reservado para a Área-Meio 109 | N | S |
| `099.29` | Assunto adicional reservado para a Área-Meio 110 | N | S |
| `099.3` | Assunto adicional reservado para a Área-Meio 111 | N | S |
| `099.31` | Assunto adicional reservado para a Área-Meio 112 | N | S |
| `099.32` | Assunto adicional reservado para a Área-Meio 113 | N | S |
| `099.33` | Assunto adicional reservado para a Área-Meio 114 | N | S |
| `099.34` | Assunto adicional reservado para a Área-Meio 115 | N | S |
| `099.35` | Assunto adicional reservado para a Área-Meio 116 | N | S |
| `099.36` | Assunto adicional reservado para a Área-Meio 117 | N | S |
| `099.37` | Assunto adicional reservado para a Área-Meio 118 | N | S |
| `099.38` | Assunto adicional reservado para a Área-Meio 119 | N | S |
| `099.39` | Assunto adicional reservado para a Área-Meio 120 | N | S |
| `099.4` | Assunto adicional reservado para a Área-Meio 121 | N | S |
| `099.41` | Assunto adicional reservado para a Área-Meio 122 | N | S |
| `099.42` | Assunto adicional reservado para a Área-Meio 123 | N | S |
| `099.43` | Assunto adicional reservado para a Área-Meio 124 | N | S |
| `099.44` | Assunto adicional reservado para a Área-Meio 125 | N | S |
| `099.45` | Assunto adicional reservado para a Área-Meio 126 | N | S |
| `099.46` | Assunto adicional reservado para a Área-Meio 127 | N | S |
| `099.47` | Assunto adicional reservado para a Área-Meio 128 | N | S |
| `099.48` | Assunto adicional reservado para a Área-Meio 129 | N | S |
| `099.49` | Assunto adicional reservado para a Área-Meio 130 | N | S |
| `099.5` | Assunto adicional reservado para a Área-Meio 131 | N | S |
| `099.51` | Assunto adicional reservado para a Área-Meio 132 | N | S |
| `099.52` | Assunto adicional reservado para a Área-Meio 133 | N | S |
| `099.53` | Assunto adicional reservado para a Área-Meio 134 | N | S |
| `099.54` | Assunto adicional reservado para a Área-Meio 135 | N | S |
| `099.55` | Assunto adicional reservado para a Área-Meio 136 | N | S |
| `099.56` | Assunto adicional reservado para a Área-Meio 137 | N | S |
| `099.57` | Assunto adicional reservado para a Área-Meio 138 | N | S |
| `099.58` | Assunto adicional reservado para a Área-Meio 139 | N | S |
| `099.59` | Assunto adicional reservado para a Área-Meio 140 | N | S |
| `099.6` | Assunto adicional reservado para a Área-Meio 141 | N | S |
| `099.61` | Assunto adicional reservado para a Área-Meio 142 | N | S |
| `099.62` | Assunto adicional reservado para a Área-Meio 143 | N | S |
| `099.63` | Assunto adicional reservado para a Área-Meio 144 | N | S |
| `099.64` | Assunto adicional reservado para a Área-Meio 145 | N | S |
| `099.65` | Assunto adicional reservado para a Área-Meio 146 | N | S |
| `099.66` | Assunto adicional reservado para a Área-Meio 147 | N | S |
| `099.67` | Assunto adicional reservado para a Área-Meio 148 | N | S |
| `099.68` | Assunto adicional reservado para a Área-Meio 149 | N | S |
| `099.69` | Assunto adicional reservado para a Área-Meio 150 | N | S |
| `099.7` | Assunto adicional reservado para a Área-Meio 151 | N | S |
| `099.71` | Assunto adicional reservado para a Área-Meio 152 | N | S |
| `099.72` | Assunto adicional reservado para a Área-Meio 153 | N | S |
| `099.73` | Assunto adicional reservado para a Área-Meio 154 | N | S |
| `099.74` | Assunto adicional reservado para a Área-Meio 155 | N | S |
| `099.75` | Assunto adicional reservado para a Área-Meio 156 | N | S |
| `099.76` | Assunto adicional reservado para a Área-Meio 157 | N | S |
| `099.77` | Assunto adicional reservado para a Área-Meio 158 | N | S |
| `099.78` | Assunto adicional reservado para a Área-Meio 159 | N | S |
| `099.79` | Assunto adicional reservado para a Área-Meio 160 | N | S |
| `099.80` | Assunto adicional reservado para a Área-Meio 161 | N | S |
| `099.81` | Assunto adicional reservado para a Área-Meio 162 | N | S |
| `099.82` | Assunto adicional reservado para a Área-Meio 163 | N | S |
| `099.83` | Assunto adicional reservado para a Área-Meio 164 | N | S |
| `099.84` | Assunto adicional reservado para a Área-Meio 165 | N | S |
| `099.85` | Assunto adicional reservado para a Área-Meio 166 | N | S |
| `099.86` | Assunto adicional reservado para a Área-Meio 167 | N | S |
| `099.87` | Assunto adicional reservado para a Área-Meio 168 | N | S |
| `099.88` | Assunto adicional reservado para a Área-Meio 169 | N | S |
| `099.89` | Assunto adicional reservado para a Área-Meio 170 | N | S |
| `099.90` | Assunto adicional reservado para a Área-Meio 171 | N | S |
| `099.91` | Assunto adicional reservado para a Área-Meio 172 | N | S |
| `099.92` | Assunto adicional reservado para a Área-Meio 173 | N | S |
| `099.93` | Assunto adicional reservado para a Área-Meio 174 | N | S |
| `099.94` | Assunto adicional reservado para a Área-Meio 175 | N | S |
| `099.95` | Assunto adicional reservado para a Área-Meio 176 | N | S |
| `099.96` | Assunto adicional reservado para a Área-Meio 177 | N | S |
| `099.97` | Assunto adicional reservado para a Área-Meio 178 | N | S |
| `099.98` | Assunto adicional reservado para a Área-Meio 179 | N | S |
| `099.99` | Assunto adicional reservado para a Área-Meio 180 | N | S |
| `099.99.a` | Assunto adicional reservado para a Área-Meio 181 | N | S |
| `099.99.b` | Assunto adicional reservado para a Área-Meio 182 | N | S |
| `099.99.c` | Assunto adicional reservado para a Área-Meio 183 | N | S |
| `099.99.d` | Assunto adicional reservado para a Área-Meio 184 | N | S |
| `099.99.e` | Assunto adicional reservado para a Área-Meio 185 | N | S |
| `099.99.f` | Assunto adicional reservado para a Área-Meio 186 | N | S |
| `099.99.g` | Assunto adicional reservado para a Área-Meio 187 | N | S |
| `910.a` | SOLENIDADES. COMEMORAÇÕES. HOMENAGENS (inclusive Discursos e Palestras proferidas por convidados) | S | N |
| `910.b` | SOLENIDADES. COMEMORAÇÕES. HOMENAGENS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | S | N |
| `920.a` | CONGRESSOS. CONFERÊNCIAS. SEMINÁRIOS. SIMPÓSIOS. ENCONTROS. CONVENÇÕES. CICLOS DE PALESTRAS. MESAS REDONDAS | S | N |
| `920.b` | CONGRESSOS. CONFERÊNCIAS. SEMINÁRIOS. SIMPÓSIOS. ENCONTROS. CONVENÇÕES. CICLOS DE PALESTRAS. MESAS REDONDAS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | S | N |
| `930.a` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS | S | N |
| `930.b` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | S | N |
| `930.c` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Planejamento, Editais, Habilitação dos Candidatos, Julgamento da Banca, Trabalhos Concorrentes, Premiação e Recursos) | S | N |
| `930.d` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Normas) | S | N |
| `940` | VISITAS E VISITANTES (inclusive Solicitações de Audiência, Assistência, Orientação e Assessoramento a Visitantes) | S | N |
| `993` | AGRADECIMENTOS. CONVITES. FELICITAÇÕES. PÊSAMES | S | N |
| `994` | PROTESTOS. REIVINDICAÇÕES. SUGESTÕES | S | N |
| `995` | PEDIDOS, OFERECIMENTOS E INFORMAÇÕES DIVERSAS | S | N |
| `996` | ASSOCIAÇÕES: CULTURAIS, DE AMIGOS E DE SERVIDORES | S | N |

## 10. Anomalias de dados encontradas

- A tabela de 2017 contém **80 registros** em que `codigo_estruturado` possui espaços que precisam ser removidos para comparação confiável.
- Há alteração ampla nos campos de temporalidade e destinação. Assim, a equivalência de assunto não pode ser inferida apenas pela descrição.
- A tabela de 2024 utiliza `NULL` em diversos campos de prazo/destinação, especialmente em nós estruturais; isso deve ser considerado na carga e na interface do GD-SEI.

## 11. Impacto técnico preliminar para o GD-SEI

Uma eventual migração para 2024 deve evitar qualquer `UPDATE` direto baseado somente no código. O cenário exige uma **tabela de correspondência 2017 → 2024** com decisão explícita por assunto.

Essa correspondência deverá diferenciar:

1. equivalência direta;
2. alteração apenas de texto/propriedades;
3. mudança de código;
4. desdobramento de um assunto antigo em vários novos;
5. consolidação de vários assuntos antigos em um novo;
6. assunto efetivamente descontinuado;
7. assunto efetivamente novo.

## 12. Próximas etapas sugeridas

### Etapa 2 — Mapa de correspondência semântica

Cruzar os 379 códigos exclusivos de 2017 com os 362 exclusivos de 2024 usando descrição, observação e hierarquia, classificando cada relação como `1:1`, `1:N`, `N:1` ou `sem correspondência`.

### Etapa 3 — Comparação arquivística

Para os assuntos equivalentes ou realocados, comparar `prazo_corrente`, `prazo_intermediario`, `sta_destinacao`, `sin_estrutural` e `sin_ativo`. Essa etapa mede o impacto sobre temporalidade, eliminação e guarda permanente.

### Etapa 4 — Cruzamento com uso real no SEI

Adicionar quantidade de processos/vínculos atualmente associados a cada assunto de 2017. Isso permitirá priorizar a análise pelo impacto real e identificar assuntos removidos que possuem acervo ativo.

### Etapa 5 — Estratégia de migração

Com o mapa validado, definir a política técnica: manter histórico com a classificação antiga, migrar apenas novos processos para 2024, ou remapear registros existentes quando houver equivalência segura.

---

## Apêndice A — Assuntos mantidos quanto a código e descrição

| Código | Descrição | Ativo 2017 | Ativo 2024 |
|---|---|:---:|:---:|
| `000` | ADMINISTRAÇÃO GERAL | S | S |
| `021` | RECRUTAMENTO E SELEÇÃO | S | S |
| `029.3` | INCENTIVOS FUNCIONAIS | S | S |
| `051.1` | PROGRAMAÇÃO ORÇAMENTÁRIA | S | S |
| `062.12` | DOAÇÃO | S | S |
| `062.13` | PERMUTA | S | S |
| `080.1` | LEGISLAÇÃO (normas; avisos; portarias de caráter geral; boletins administrativo, de pessoal e de serviço; diretrizes; procedimentos; pareceres; estudos e/ou decisões de caráter geral) | S | N |
| `080.2` | IDENTIFICAÇÃO MILITAR | S | N |
| `080.21` | IDENTIDADE MILITAR. CARTEIRA. CARTÃO | S | N |
| `080.21.a` | FICHA DE IDENTIDADE GRANDE, FICHA INDIVIDUAL DATILOSCÓPICA, CARTÃO ÍNDICE, FICHA DE DADOS CADASTRAIS | S | N |
| `080.21.b` | GUIA DE REMESSA DE MATERIAL DE IDENTIFICAÇÃO, MAPA MENSAL DO MATERIAL TÉCNICO | S | N |
| `080.21.c` | IDENTIDADE PROVISÓRIA | S | N |
| `080.22` | CONCESSÃO DE PASSAPORTE: DIPLOMÁTICO E/OU OFICIAL | S | N |
| `080.3.b` | FICHA DE APRESENTAÇÃO, CONTAGEM DE TEMPO DE SERVIÇO, FICHA PADRÃO PASEP, FICHA DE CÓDIGO DE ESPECIALIDADE, CONCESSÃO E CESSAÇÃO DE PORTE DE ARMA | S | N |
| `081` | INGRESSO NAS FORÇAS ARMADAS | S | N |
| `081.1.a` | EDITAL DE CONCURSOS E ORIENTAÇÕES ESPECÍFICAS. MATERIAL DE DIVULGAÇÃO*, RELATÓRIOS E ATAS DOS PROCESSOS SELETIVOS, PROVAS ESCRITAS, PRÁTICAS E ORAIS*, GABARITOS*, INSTRUÇÕES COMPLEMENTARES DE CONVOCAÇÃO E DE SISTEMA DE SERVIÇO MILITAR | S | N |
| `081.2` | INCORPORAÇÃO | S | N |
| `081.2.a` | ATOS DE CONVOCAÇÃO À INCORPORAÇÃO, ALISTAMENTOS, ESTÁGIOS, DISPENSA OU ISENÇÃO DO SERVIÇO MILITAR, CONVOCAÇÃO À INCORPORAÇÃO PARA PRESTAR SERVIÇO MILITAR OBRIGATÓRIO (SERVIÇO MILITAR INICIAL OU OUTRAS FORMAS POSTERIORES) | S | N |
| `081.3` | MATRÍCULA | S | N |
| `081.3.a` | ADMISSÃO EM ESCOLAS, CENTROS E CURSOS DE FORMAÇÃO | S | N |
| `081.4` | NOMEAÇÃO | S | N |
| `081.5.a` | CAMPANHAS DE CONVOCAÇÃO, MAPAS DE ENCARGOS DE MOBILIZAÇÃO, RELATÓRIOS SOBRE O EXERCÍCIO DE APRESENTAÇÃO DA RESERVA, CONTROLE DE EFETIVO DE MILITARES TEMPORÁRIOS (MÉDICOS, FARMACÊUTICOS, DENTISTAS, VETERINÁRIOS), TIROS DE GUERRA | S | N |
| `081.9` | OUTROS ASSUNTOS REFERENTES A INGRESSO NAS FORÇAS ARMADAS | S | N |
| `082` | PLANO DE CARREIRA | S | N |
| `082.1` | PROMOÇÃO | S | N |
| `082.2` | CURSOS | S | N |
| `082.21` | FORMAÇÃO. ADAPTAÇÃO | S | N |
| `082.21.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CONCURSOS | S | N |
| `082.22` | APERFEIÇOAMENTO.ESPECIALIZAÇÃO | S | N |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.23` | ESTADO-MAIOR | S | N |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.24` | ALTOS ESTUDOS MILITARES | S | N |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.3` | AVALIAÇÃO | S | N |
| `082.4` | REQUISITOS ESPECÍFICOS DE CARREIRA | S | N |
| `082.4.a` | MANOBRA, TEMPO DE TROPA, TEMPO DE EMBARQUE, VIVÊNCIA NACIONAL, DIAS DE MAR, ATIVIDADE BÉLICA, HORAS DE VOO | S | N |
| `082.5` | CURSOS COMPLEMENTARES | S | N |
| `082.51` | ADESTRAMENTO | S | N |
| `082.51.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS DIVERSOS TIPOS DE ADESTRAMENTO | S | N |
| `082.52` | PÓS-GRADUAÇÃO LATO SENSU | S | N |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.53` | QUALIFICAÇÃO TÉCNICA ESPECIAL | S | N |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.54` | PÓS-GRADUAÇÃO STRICTO SENSU | S | N |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.55` | PÓS-DOUTORADO | S | N |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | S | N |
| `082.6` | PRORROGAÇÃO DE TEMPO DE SERVIÇO. REENGAJAMENTO | S | N |
| `082.6.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | S | N |
| `082.7` | TRANSPOSIÇÃO DE QUADRO | S | N |
| `082.7.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | S | N |
| `082.9` | OUTROS ASSUNTOS REFERENTES A PLANO DE CARREIRA | S | N |
| `083` | MOVIMENTAÇÃO. DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO: MAPAS DE LOTAÇÃO DE OFICIAIS E PRAÇAS | S | N |
| `083.1` | MOVIMENTAÇÃO | S | N |
| `083.11` | MOTIVO DE SAÚDE | S | N |
| `083.11.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, CÓPIA DA ATA DE INSPEÇÃO DE SAÚDE, TERMO DE INSPEÇÃO DE SAÚDE | S | N |
| `083.12` | INTERESSE DO MILITAR | S | N |
| `083.12.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, ORDEM DE MOVIMENTAÇÃO, PORTARIA DE MOVIMENTAÇÃO | S | N |
| `083.13` | NECESSIDADE DO SERVIÇO | S | N |
| `083.13.a` | PROPOSTA DE PLANO DE MOVIMENTAÇÃO, SOLICITAÇÕES DE ÓRGÃOS DE DIREÇÃO-GERAL OU SETORIAL, INCOMPATIBILIDADE DE POSTO, MATRÍCULA, TÉRMINO DE CURSO, INTERCÂMBIO E A BEM DA DISCIPLINA | S | N |
| `083.14` | MOTIVO DE JUSTIÇA | S | N |
| `083.14.a` | ORDEM JUDICIAL | S | N |
| `083.2` | DESTAQUE. ADIÇÃO | S | N |
| `083.2.a` | PARECERES, DESPACHOS | S | N |
| `083.3` | EXCLUSÃO DO SERVIÇO ATIVO | S | N |
| `083.3.a` | DEMISSÃO, PERDA DE POSTO E DA PATENTE, LICENCIAMENTO, ANULAÇÃO DE INCORPORAÇÃO, DESINCORPORAÇÃO, A BEM DA DISCIPLINA, FALECIMENTO | S | N |
| `083.3.b` | DESERÇÃO. EXTRAVIO | S | N |
| `083.9` | OUTROS ASSUNTOS REFERENTES À MOVIMENTAÇÃO.DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO | S | N |
| `083.9.a` | POSSE E NOMEAÇÃO PARA CARGOS PÚBLICOS | S | N |
| `083.a` | PLANOS DE MOVIMENTAÇÃO | S | N |
| `084` | VIOLAÇÃO DAS OBRIGAÇÕES E DOS DEVERES | S | N |
| `084.1` | TRANSGRESSÕES E/OU CONTRAVENÇÕES DISCIPLINARES | S | N |
| `084.1.a` | SINDICÂNCIA, ACAREAÇÃO E APURAÇÃO DAS TRANSGRESSÕES E/OU CONTRAVENÇÕES, APLICAÇÃO DAS PUNIÇÕES DISCIPLINARES | S | N |
| `084.2` | CRIMES MILITARES | S | N |
| `084.2.a` | PORTARIA DE NOMEAÇÃO DO ENCARREGADO E ESCRIVÃO DO IPM, SOLUÇÃO DO IPM, OFÍCIO DE REMESSA DO IPM À JUSTIÇA MILITAR | S | N |
| `084.3` | CONSELHOS | S | N |
| `084.31` | DE DISCIPLINA | S | N |
| `084.31.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | S | N |
| `084.32` | DE JUSTIFICAÇÃO | S | N |
| `084.32.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | S | N |
| `085` | DIREITOS E PRERROGATIVAS | S | N |
| `085.1` | RECOMPENSAS. DISTINÇÕES. HONRARIAS | S | N |
| `085.1.a` | PRÊMIOS DE HONRA AO MÉRITO, ELOGIOS, LOUVORES, REFERÊNCIAS ELOGIOSAS, DISTINTIVOS, DISPENSAS DE SERVIÇO | S | N |
| `085.1.b` | RELAÇÕES DE AGRACIADOS COM AS CONDECORAÇÕES, RELAÇÕES DAQUELES QUE TIVERAM AS CONDECORAÇÕES CASSADAS | S | N |
| `085.2` | LICENÇAS | S | N |
| `085.3` | AFASTAMENTOS | S | N |
| `085.3.a` | INSTALAÇÃO (NO BRASIL E NO EXTERIOR), LUTO, NÚPCIAS, TRÂNSITO (NO BRASIL E NO EXTERIOR) | S | N |
| `085.4` | DISPENSAS DE SERVIÇO | S | N |
| `085.4.a` | PARA DESCONTO EM FÉRIAS, POR PRESCRIÇÃO MÉDICA | S | N |
| `085.5` | FÉRIAS | S | N |
| `085.5.a` | PLANEJAMENTO, SOLICITAÇÃO, CONCESSÃO, CANCELAMENTO E PUBLICAÇÃO | S | N |
| `085.6` | REMUNERAÇÃO. PROVENTOS | S | N |
| `085.61` | REMUNERAÇÃO NA ATIVA | S | N |
| `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | S | N |
| `085.611` | ADICIONAIS | S | N |
| `085.611.a` | MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | S | N |
| `085.612` | GRATIFICAÇÕES | S | N |
| `085.612.a` | DE LOCALIDADE ESPECIAL, DE REPRESENTAÇÃO | S | N |
| `085.619` | OUTROS DIREITOS REMUNERATÓRIOS NA ATIVA | S | N |
| `085.62` | PROVENTOS NA INATIVIDADE | S | N |
| `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | S | N |
| `085.621` | ADICIONAIS | S | N |
| `085.621.a` | ADICIONAIS: MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | S | N |
| `085.629` | OUTROS DIREITOS PECUNIÁRIOS NA INATIVIDADE | S | N |
| `085.63` | DESCONTOS | S | N |
| `085.631` | OBRIGATÓRIOS | S | N |
| `085.632` | AUTORIZADOS | S | N |
| `085.632.a` | DESCONTOS EM FAVOR DE ENTIDADE CONSIGNATÁRIAS, DE TERCEIRO OU BENEFÍCIO FAMÍLIA | S | N |
| `086` | INATIVOS E PENSIONISTAS | S | N |
| `086.1` | INATIVOS | S | N |
| `086.11` | RESERVA | S | N |
| `086.111` | REMUNERADA | S | N |
| `086.111.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA REMUNERADA | S | N |
| `086.112` | NÃO REMUNERADA | S | N |
| `086.112.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA NÃO REMUNERADA | S | N |
| `086.12` | REFORMA | S | N |
| `086.121` | POR INVALIDEZ | S | N |
| `086.121.a` | PROCESSO DE REFORMA POR INVALIDEZ | S | N |
| `086.122` | POR IDADES-LIMITE | S | N |
| `086.122.a` | PROCESSO DE REFORMA POR IDADES-LIMITE | S | N |
| `086.13` | DESIGNAÇÃO PARA O SERVIÇO ATIVO | S | N |
| `086.13.a` | PROCESSO DE DESIGNAÇÃO PARA O SERVIÇO ATIVO | S | N |
| `086.14` | TAREFA POR TEMPO CERTO | S | N |
| `086.14.a` | PROCESSO DE DESIGNAÇÃO PARA TAREFA POR TEMPO CERTO | S | N |
| `086.2` | PENSIONISTAS | S | N |
| `086.21` | PENSÕES | S | N |
| `086.211` | TEMPORÁRIA | S | N |
| `086.212` | VITALÍCIA | S | N |
| `086.213` | ESPECIAL | S | N |
| `087` | ASSISTÊNCIA | S | N |
| `087.1` | MÉDICA | S | N |
| `087.11` | HOSPITALAR | S | N |
| `087.11.a` | ATENDIMENTO AMBULATORIAL OU PRONTO-ATENDIMENTO | S | N |
| `087.11.b` | PRONTUÁRIOS MÉDICOS, FICHAS ODONTOLÓGICAS | S | N |
| `087.12` | PERICIAL | S | N |
| `087.2` | SOCIAL | S | N |
| `087.2.a` | PROGRAMAS DE ASSISTÊNCIA SOCIAL COM VISTAS À CONCESSÃO DE LICENÇAS E BENEFÍCIOS; ATENDIMENTOS EDUCACIONAIS E ASSISTENCIAIS PRESTADOS POR EMPRESAS CONVENIADAS | S | N |
| `087.3` | JURÍDICA | S | N |
| `087.3.a` | ORIENTAÇÃO DE CARÁTER PARTICULAR; ATENDIMENTOS JURÍDICOS PRESTADOS POR EMPRESAS CONVENIADAS | S | N |
| `087.4` | PSICOLÓGICA | S | N |
| `087.4.a` | TRIAGEM PARA ENCAMINHAMENTO AO SERVIÇO DE SAÚDE ESPECÍFICO; ORIENTAÇÃO E ACONSELHAMENTO PSICOLÓGICO; ATENDIMENTOS PSICOLÓGICOS PRESTADOS POR EMPRESAS CONVENIADAS | S | N |
| `087.5` | RELIGIOSA | S | N |
| `087.5.a` | CENSO RELIGIOSO | S | N |
| `087.5.b` | PROCESSOS DE HABILITAÇÃO E REGISTROS DE CASAMENTO; BATIZADO E CRISMA; LIVRO TOMBO | S | N |
| `089` | OUTROS ASSUNTOS REFERENTES A PESSOAL MILITAR | S | N |
| `089.1` | SERVIÇOS DE ESCALA | S | N |
| `089.1.a` | ESCALAS DE SERVIÇO | S | N |
| `089.2` | TABELAS MESTRAS | S | N |
| `089.2.a` | TABELAS INDIVIDUAIS E GERAIS | S | N |
| `089.3` | CONTROLE DE FREQUÊNCIA | S | N |
| `089.3.a` | FICHAS DE CONTROLE DE EFETIVOS; LIVROS DE LICENCIADOS | S | N |
| `089.4` | DELEGAÇÕES DE COMPETÊNCIA | S | N |
| `089.4.a` | ATOS DE DELEGAÇÃO; RELAÇÃO DE ENCARGOS COLATERAIS | S | N |

## Apêndice B — Códigos reutilizados com provável mudança de significado

| Código | Similaridade textual | Descrição 2017 | Descrição 2024 |
|---|---:|---|---|
| `001` | 33% | MODERNIZAÇÃO E REFORMA ADMINISTRATIVA (inclusive Projetos, Estudos e Normas) | RELAÇÃO INTERINSTITUCIONAL |
| `002` | 35% | PLANOS, PROGRAMAS E PROJETOS DE TRABALHO | ATENDIMENTO AO CIDADÃO |
| `003` | 31% | RELATÓRIOS DE ATIVIDADES | CONTROLE E FISCALIZAÇÃO DA GESTÃO PÚBLICA |
| `004` | 10% | ACORDOS. AJUSTES. CONTRATOS. CONVÊNIOS (Inclusive formalização, execução, acompanhamento, fiscalização, prestação de contas, tomada de contas e tomada de contas especial de convênios, contratos de repasse, termos de parceria e termos de cooperação) | ASSESSORAMENTO JURÍDICO |
| `010` | 34% | ORGANIZAÇÃO E FUNCIONAMENTO (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | ORGANIZAÇÃO E FUNCIONAMENTO |
| `011` | 20% | COMISSÕES. CONSELHOS. GRUPOS DE TRABALHO. JUNTAS. COMITÊS (inclusive Atos de Criação, Atas e Relatórios) | ORGANIZAÇÃO ADMINISTRATIVA |
| `012` | 33% | COMUNICAÇÃO SOCIAL | HABILITAÇÃO JURÍDICA E REGULARIZAÇÃO FISCAL |
| `019.1` | 33% | PLANEJAMENTO INSTITUCIONAL | GERENCIAMENTO DE ESTRATÉGIAS DE MARKETING E DE COMUNICAÇÃO SOCIAL |
| `019.11` | 39% | GESTÃO DE PROJETOS | ADMINISTRAÇÃO DA COMUNICAÇÃO |
| `019.12` | 13% | MAPEAMENTO E MODELAGEM DE PROCESSOS DE TRABALHO. ATRIBUIÇÕES E COMPETÊNCIAS | DIVULGAÇÃO INTERNA |
| `019.13` | 22% | DESEMPENHO INSTITUCIONAL | PLANEJAMENTO, ELABORAÇÃO E ACOMPANHAMENTO |
| `019.2` | 38% | GESTÃO SOCIOAMBIENTAL | AÇÃO DE RESPONSABILIDADE SOCIAL |
| `020` | 50% | PESSOAL | GESTÃO DE PESSOAS |
| `020.2` | 38% | IDENTIFICAÇÃO FUNCIONAL (inclusive Carteira, Cartão, Crachá, Credencial e Passaporte Diplomático) | IDENTIFICAÇÃO FUNCIONAL |
| `021.1` | 34% | CANDIDATOS A CARGO E EMPREGO PÚBLICOS: INSCRIÇÃO E CURRICULUM VITAE | PLANEJAMENTO DO PROCESSO SELETIVO |
| `022` | 47% | APERFEIÇOAMENTO E TREINAMENTO | PROVIMENTO, MOVIMENTAÇÃO E VACÂNCIA |
| `022.1` | 35% | CURSOS (inclusive Bolsas de Estudo) | PROVIMENTO DE CARGO PÚBLICO |
| `022.2` | 36% | ESTÁGIOS (inclusive Bolsas de Estágio) | MOVIMENTAÇÃO DE PESSOAL |
| `022.21` | 22% | PROMOVIDOS PELA INSTITUIÇÃO (inclusive Estudos, Propostas, Programas, Relatórios Finais, Relação de Participantes, Avaliação e Declaração de Comprovação de Estágio) | LOTAÇÃO, EXERCÍCIO E PERMUTA |
| `022.22` | 19% | PROMOVIDOS POR OUTRAS INSTITUIÇÕES | CESSÃO. REQUISIÇÃO |
| `023` | 34% | QUADROS, TABELAS E POLÍTICA DE PESSOAL | CONCESSÃO DE DIREITOS E VANTAGENS |
| `023.1` | 39% | MOVIMENTAÇÃO DE PESSOAL | PAGAMENTO DE VENCIMENTOS. REMUNERAÇÕES. SALÁRIOS. PROVENTOS |
| `023.11` | 14% | ADMISSÃO. APROVEITAMENTO. CONTRATAÇÃO. NOMEAÇÃO. READMISSÃO. READAPTAÇÃO. RECONDUÇÃO. REINTEGRAÇÃO. REVERSÃO | FOLHAS DE PAGAMENTO |
| `023.12` | 36% | DEMISSÃO. DISPENSA. EXONERAÇÃO. RESCISÃO CONTRATUAL. FALECIMENTO | REESTRUTURAÇÃO E ALTERAÇÃO SALARIAL |
| `023.13` | 18% | LOTAÇÃO. REMOÇÃO. TRANSFERÊNCIA. PERMUTA | ABONO PROVISÓRIO |
| `023.14` | 18% | DESIGNAÇÃO. DISPONIBILIDADE. REDISTRIBUIÇÃO. SUBSTITUIÇÃO | ABONO DE PERMANÊNCIA EM SERVIÇO |
| `023.15` | 14% | REQUISIÇÃO. CESSÃO (Internas e/ou Externas de Servidores para a realização de serviços temporários) | GRATIFICAÇÕES |
| `024` | 25% | DIREITOS, OBRIGAÇÕES E VANTAGENS | CAPACITAÇÃO DO SERVIDOR |
| `024.1` | 38% | FOLHAS DE PAGAMENTO. FICHAS FINANCEIRAS | PROMOÇÃO DE CURSOS PELO ÓRGÃO E ENTIDADE |
| `024.11` | 24% | SALÁRIOS, VENCIMENTOS, PROVENTOS E REMUNERAÇÕES | PROGRAMAÇÃO |
| `024.12` | 36% | GRATIFICAÇÕES (inclusive Incorporações) | INSCRIÇÃO E FREQUÊNCIA |
| `024.13` | 25% | ADICIONAIS | AVALIAÇÃO E RESULTADOS |
| `024.2` | 14% | FÉRIAS | PARTICIPAÇÃO EM CURSOS PROMOVIDOS POR OUTROS ÓRGÃOS E ENTIDADES |
| `024.3` | 15% | LICENÇAS (Doença em Pessoa da Família; Afastamento do Cônjuge; Serviço Militar; Atividade Política; Capacitação; Prêmio; Interesses Particulares; Mandato Classista; Gestante; Adotante; Paternidade; Tratamento da Própria Saúde; Acidente em Serviço) | PROMOÇÃO DE ESTÁGIOS PELO ÓRGÃO E ENTIDADE |
| `024.4` | 11% | AFASTAMENTOS (Para Depor; Para Exercer Mandato Eletivo; Para Servir ao Tribunal Regional Eleitoral - TRE; Para Servir como Jurado; Suspensão de Contrato de Trabalho - CLT) | PARTICIPAÇÃO EM ESTÁGIOS PROMOVIDOS POR OUTROS ÓRGÃOS E ENTIDADES |
| `024.5` | 39% | REEMBOLSO DE DESPESAS | CONCESSÃO DE ESTÁGIOS E BOLSAS PARA ESTUDANTES |
| `024.51` | 33% | MUDANÇA DE DOMICÍLIO DE SERVIDORES | RELAÇÃO COM INSTITUIÇÕES DE ENSINO E AGENTES DE INTEGRAÇÃO |
| `024.52` | 16% | LOCOMOÇÃO (Despesas Efetuadas com a Utilização de Meio Próprio de Locomoção para a Execução de Serviços Externos) | PLANO DE ESTÁGIO |
| `025` | 47% | APURAÇÃO DE RESPONSABILIDADE E AÇÃO DISCIPLINAR | PROMOÇÃO DA SAÚDE E BEM-ESTAR |
| `025.1` | 33% | DENÚNCIAS. SINDICÂNCIAS. INQUÉRITOS | ASSISTÊNCIA À SAÚDE |
| `025.11` | 35% | PROCESSOS DISCIPLINARES | CELEBRAÇÃO DE CONVÊNIOS DE ASSISTÊNCIA À SAÚDE |
| `025.12` | 21% | PENALIDADES DISCIPLINARES (Advertência, Suspensão, Demissão, Cassação de Aposentadoria, Disponibilidade, Destituição de Cargo em Comissão, Destituição de Função Comissionada) | ORIENTAÇÃO PARA CUIDADOS COM A SAÚDE |
| `026` | 51% | PREVIDÊNCIA, ASSISTÊNCIA E SEGURIDADE SOCIAL | CONCESSÃO DE BENEFÍCIOS DE SEGURIDADE E PREVIDÊNCIA SOCIAL |
| `026.01` | 24% | PREVIDÊNCIA PRIVADA (Planos Privados de Concessão de Pecúlios ou de Rendas, de Benefícios Complementares ou assemelhados aos da previdência social) | ADESÃO À PREVIDÊNCIA COMPLEMENTAR |
| `026.1` | 16% | BENEFÍCIOS | SALÁRIO FAMÍLIA |
| `026.2` | 24% | HIGIENE E SEGURANÇA DO TRABALHO | SALÁRIO MATERNIDADE |
| `029.1` | 38% | HORÁRIO DE EXPEDIENTE (inclusive Escala de Plantão) | CONTROLE DE ASSIDUIDADE E PONTUALIDADE |
| `029.11` | 35% | CONTROLE DE FREQUÊNCIA (Livros, Cartões, Folhas de Ponto, Abono de Faltas, Cumprimento de Horas Extras) | CONTROLE DE FREQUÊNCIA |
| `029.2` | 19% | MISSÕES FORA DA SEDE. VIAGENS A SERVIÇO | INSTITUIÇÃO DO PROGRAMA DE CRECHE |
| `029.21` | 15% | NO PAÍS (Ajudas de Custo; Diárias; Passagens - inclusive Devolução; Prestações de Contas; Relatórios de Viagem) | PUBLICAÇÃO E DIVULGAÇÃO |
| `029.22` | 25% | NO EXTERIOR (Afastamento do País) | INSCRIÇÃO, SELEÇÃO, ADMISSÃO E RENOVAÇÃO |
| `029.5` | 52% | SERVIÇOS PROFISSIONAIS TRANSITÓRIOS: AUTÔNOMOS E COLABORADORES (inclusive Licitações) | CONTRATAÇÃO DE SERVIÇOS PROFISSIONAIS TRANSITÓRIOS |
| `029.6` | 29% | AÇÕES TRABALHISTAS. RECLAMAÇÕES TRABALHISTAS | PETIÇÃO DE DIREITOS |
| `030` | 14% | MATERIAL (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | GESTÃO DE MATERIAIS |
| `031` | 10% | ESPECIFICAÇÃO. PADRONIZAÇÃO. CODIFICAÇÃO. PREVISÃO. CATÁLOGO. IDENTIFICAÇÃO. CLASSIFICAÇÃO (inclusive Amostras) | AQUISIÇÃO E INCORPORAÇÃO |
| `032` | 22% | REQUISIÇÃO E CONTROLE DE SERVIÇOS REPROGRÁFICOS (inclusive Assinaturas Autorizadas e Reprodução de Formulários) | MOVIMENTAÇÃO DE MATERIAL |
| `033` | 41% | AQUISIÇÃO (inclusive Licitações) | ALIENAÇÃO E BAIXA |
| `033.1` | 5% | MATERIAL PERMANENTE (Equipamentos, Mobiliário, Aparelhos, Ferramentas, Máquinas, Instrumentos Técnicos e Obras de Arte) | VENDA |
| `033.11` | 31% | COMPRA (inclusive Compra por Importação) | MATERIAL PERMANENTE |
| `033.12` | 36% | ALUGUEL. COMODATO. LEASING | MATERIAL DE CONSUMO |
| `033.2` | 23% | MATERIAL DE CONSUMO | DOAÇÃO E PERMUTA |
| `033.21` | 32% | COMPRA | MATERIAL PERMANENTE |
| `033.22` | 29% | CESSÃO. DOAÇÃO. PERMUTA | MATERIAL DE CONSUMO |
| `034` | 47% | MOVIMENTAÇÃO DE MATERIAL (Permanente e de Consumo) | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS |
| `035` | 31% | ALIENAÇÃO. BAIXA (Material Permanente e de Consumo) | EXECUÇÃO DE SERVIÇOS DE INSTALAÇÃO E MANUTENÇÃO |
| `036` | 21% | INSTALAÇÃO E MANUTENÇÃO (Serviços de Instalação, Conservação, Recuperação e Consertos de Equipamentos e Mobiliário) | CONTROLE DE MATERIAIS |
| `036.1` | 37% | REQUISIÇÃO E CONTRATAÇÃO DE SERVIÇOS (inclusive Licitações) | INVENTÁRIO DE MATERIAL PERMANENTE |
| `036.2` | 22% | SERVIÇOS EXECUTADOS EM OFICINAS DO ÓRGÃO | INVENTÁRIO DE MATERIAL DE CONSUMO |
| `040` | 18% | PATRIMÔNIO (Bens Imóveis, Veículos e Semoventes pertencentes ao Órgão) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | GESTÃO DE BENS PATRIMONIAIS E DE SERVIÇOS |
| `041` | 19% | BENS IMÓVEIS (Projetos, Plantas e Escrituras relativos aos edifícios, terrenos, residências e salas) | AQUISIÇÃO E INCORPORAÇÃO |
| `041.1` | 13% | AQUISIÇÃO | COMPRA |
| `041.11` | 11% | COMPRA | BENS IMÓVEIS |
| `041.12` | 29% | CESSÃO | VEÍCULOS |
| `041.13` | 10% | DOAÇÃO | BENS SEMOVENTES |
| `041.2` | 32% | ALIENAÇÃO | DOAÇÃO E PERMUTA |
| `041.21` | 24% | VENDA | BENS IMÓVEIS |
| `041.22` | 29% | CESSÃO | VEÍCULOS |
| `041.23` | 10% | DOAÇÃO | BENS SEMOVENTES |
| `041.3` | 34% | DESAPROPRIAÇÃO. REINTEGRAÇÃO DE POSSE. REIVINDICAÇÃO DE DOMÍNIO. TOMBAMENTO | DAÇÃO. ADJUDICAÇÃO |
| `041.4` | 40% | OBRAS | PROCRIAÇÃO |
| `041.5` | 29% | SERVIÇOS DE MANUTENÇÃO (inclusive Licitações) | CESSÃO E COMODATO |
| `041.51` | 28% | MANUTENÇÃO DE ELEVADORES | BENS IMÓVEIS |
| `041.52` | 22% | MANUTENÇÃO DE AR CONDICIONADO | VEÍCULOS |
| `041.53` | 19% | MANUTENÇÃO DE SUBESTAÇÕES E GERADORES | BENS SEMOVENTES |
| `042` | 35% | VEÍCULOS | ALIENAÇÃO |
| `042.1` | 16% | AQUISIÇÃO (inclusive Licitações) | VENDA |
| `042.11` | 23% | COMPRA (inclusive Compra por Importação) | BENS IMÓVEIS |
| `042.12` | 13% | ALUGUEL | VEÍCULOS |
| `042.13` | 8% | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | BENS SEMOVENTES |
| `042.2` | 25% | CADASTRO. LICENCIAMENTO. EMPLACAMENTO. TOMBAMENTO | DOAÇÃO E PERMUTA |
| `042.3` | 44% | ALIENAÇÃO (inclusive Licitações) | DAÇÃO. ADJUDICAÇÃO |
| `042.31` | 22% | VENDA (inclusive Leilão) | BENS IMÓVEIS |
| `042.32` | 9% | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | VEÍCULOS |
| `042.4` | 22% | ABASTECIMENTO. LIMPEZA. MANUTENÇÃO. REPARO | DESAPROPRIAÇÃO E DESMEMBRAMENTO |
| `042.5` | 36% | ACIDENTES. INFRAÇÕES. MULTAS | CESSÃO E COMODATO |
| `043` | 25% | BENS SEMOVENTES | ADMINISTRAÇÃO CONDOMINIAL |
| `044` | 30% | INVENTÁRIO (inclusive Relatório de Movimentação de Bens Imóveis - RMBI) | ADMINISTRAÇÃO DA FROTA DE VEÍCULOS |
| `049.1` | 31% | GUARDA E SEGURANÇA | RACIONALIZAÇÃO DO USO DE BENS E SERVIÇOS |
| `049.11` | 30% | SERVIÇOS DE VIGILÂNCIA | CRIAÇÃO E ATUAÇÃO DE GRUPOS DE TRABALHO |
| `049.12` | 43% | SEGUROS (inclusive de Veículos) | OPERACIONALIZAÇÃO DE REUNIÕES |
| `050` | 15% | ORÇAMENTO E FINANÇAS (Previsão e Execução; Operações Contábeis; Receita e Despesa; Movimentação de Conta; Balanços; Prestações de Contas) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | GESTÃO ORÇAMENTÁRIA E FINANCEIRA |
| `051` | 57% | ORÇAMENTO | GESTÃO ORÇAMENTÁRIA |
| `051.2` | 36% | EXECUÇÃO ORÇAMENTÁRIA | DETALHAMENTO DE DESPESA |
| `052` | 56% | FINANÇAS | GESTÃO FINANCEIRA |
| `052.2` | 46% | EXECUÇÃO FINANCEIRA (inclusive Despesas Correntes e de Capital) | EXECUÇÃO FINANCEIRA |
| `052.21` | 9% | RECEITA (inclusive Créditos do Tesouro Nacional - cota, repasse e sub-repasse; Taxas Cobradas por Serviços; Multas; Emolumentos; e outras rendas arrecadadas) | RECEITA |
| `052.22` | 11% | DESPESA (inclusive Despesas Correntes e de Capital, bem como Adiantamentos, Subvenções, Suprimento de Fundos e Restos a Pagar) | DESPESA |
| `053` | 36% | FUNDOS ESPECIAIS | OPERAÇÃO BANCÁRIA |
| `054` | 22% | ESTÍMULOS FINANCEIROS E CREDITÍCIOS (inclusive Subsídios, Incentivos Fiscais e Investimentos) | CONTROLE EXTERNO. AUDITORIA EXTERNA |
| `059.1` | 33% | TRIBUTOS (Impostos e Taxas) | COMPRA E SUBSCRIÇÃO DE AÇÕES |
| `061` | 25% | PRODUÇÃO EDITORIAL (inclusive Edição ou Coedição de Publicações em Geral produzidas pelo órgão em qualquer suporte) | GESTÃO DE DOCUMENTOS DE ARQUIVO |
| `061.1` | 33% | EDITORAÇÃO. PROGRAMAÇÃO VISUAL | ADOÇÃO E CONTROLE DOS PROCEDIMENTOS DE PROTOCOLO |
| `061.2` | 30% | DISTRIBUIÇÃO. PROMOÇÃO. DIVULGAÇÃO | ANÁLISE DA SITUAÇÃO ARQUIVÍSTICA |
| `062` | 41% | DOCUMENTAÇÃO BIBLIOGRÁFICA (Livros, Periódicos, Folhetos e Audiovisuais) | GESTÃO DE ACERVOS BIBLIOGRÁFICO E MUSEOLÓGICO |
| `062.1` | 51% | AQUISIÇÃO (no Brasil e no exterior) | AQUISIÇÃO E INCORPORAÇÃO |
| `062.11` | 24% | COMPRA (inclusive Assinaturas de Periódicos) | COMPRA |
| `062.2` | 21% | REGISTRO (inclusive Incorporação de Livros e Periódicos ao Acervo) | PROCESSAMENTO TÉCNICO |
| `062.3` | 13% | CATALOGAÇÃO. CLASSIFICAÇÃO. INDEXAÇÃO | INVENTÁRIO |
| `062.4` | 11% | REFERÊNCIA E CIRCULAÇÃO (inclusive Consultas, Pesquisas Bibliográficas, Bibliografias, Empréstimos e Intercâmbio entre Bibliotecas) | DESINCORPORAÇÃO |
| `063` | 33% | DOCUMENTAÇÃO ARQUIVÍSTICA: GESTÃO DE DOCUMENTOS E SISTEMA DE ARQUIVOS | CONTROLE DE ACESSO E DE MOVIMENTAÇÃO DE ACERVOS |
| `063.2` | 18% | PROTOCOLO: RECEPÇÃO, TRAMITAÇÃO E EXPEDIÇÃO DE DOCUMENTOS | EMPRÉSTIMOS |
| `063.3` | 29% | ASSISTÊNCIA TÉCNICA | MOVIMENTAÇÃO DE ACERVOS |
| `064` | 37% | DOCUMENTAÇÃO MUSEOLÓGICA | CONSERVAÇÃO E PRESERVAÇÃO DE ACERVOS |
| `065` | 20% | REPRODUÇÃO DE DOCUMENTOS (em qualquer suporte, de material arquivístico, bibliográfico e museológico) (inclusive Estudos, Projetos e Normas) | PRODUÇÃO EDITORIAL |
| `066` | 37% | CONSERVAÇÃO DE DOCUMENTOS | GESTÃO DE TECNOLOGIA DA INFORMAÇÃO |
| `066.1` | 28% | DESINFESTAÇÃO. HIGIENIZAÇÃO | DESENVOLVIMENTO E CONTROLE DE SISTEMAS INFORMATIZADOS |
| `066.2` | 40% | ARMAZENAMENTO. DEPÓSITOS | INSTALAÇÃO DE EQUIPAMENTOS |
| `066.3` | 38% | RESTAURAÇÃO (inclusive Encadernação) | ADMINISTRAÇÃO DA INFRAESTRUTURA TECNOLÓGICA |
| `067` | 26% | INFORMÁTICA | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS |
| `070` | 32% | COMUNICAÇÕES (Instalação, Manutenção, Operação e Uso dos Recursos e Serviços Postais, de Telecomunicações e de Tecnologias da Informação) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | GESTÃO DOS SERVIÇOS POSTAIS E DE TELECOMUNICAÇÕES |
| `071` | 32% | SERVIÇO POSTAL | CONTRATAÇÃO DE PRESTAÇÃO DE SERVIÇOS |
| `071.1` | 48% | SERVIÇOS DE ENTREGA EXPRESSA | SERVIÇO POSTAL |
| `071.2` | 41% | SERVIÇOS DE COLETA, TRANSPORTE E ENTREGA DE CORRESPONDÊNCIA AGRUPADA – MALOTE | SERVIÇO DE RADIOFREQUÊNCIA |
| `071.3` | 21% | MALA OFICIAL | SERVIÇO DE TELEX |
| `072` | 34% | SERVIÇO DE RÁDIO | EXECUÇÃO DE SERVIÇOS PELO ÓRGÃO E ENTIDADE |
| `073` | 31% | SERVIÇO DE TELEX | AUTORIZAÇÃO E CONTROLE DE USO |
| `073.1` | 29% | INSTALAÇÃO. MANUTENÇÃO. REPARO | SERVIÇO DE RADIOFREQUÊNCIA |
| `080.3` | 26% | ASSENTAMENTOS INDIVIDUAIS.CADASTRO | ASSENTAMENTOS INDIVIDUAIS.CADASTRO (Incluem-se ficha de apresentação; ficha padrão Pasep e ficha de código de especialidade, bem como os documentos referentes à contagem de tempo de serviço e à concessão e cessação de porte de arma) |
| `081.1.b` | 28% | SELEÇÃO E DESIGNAÇÃO PARA INCORPORAÇÃO E MATRÍCULA, NOMEAÇÃO E TERMO DE COMPROMISSO DE BANCA DE PROVAS, LISTA DE CANDIDATOS, QUESTIONÁRIO BIOGRÁFICO SIMPLIFICADO, CARTÕES RESPOSTAS DE TESTES OU PROVAS DO CANDIDATO, TESTES, PROVAS DE TÍTULO, RESULTADO | SELEÇÃO E DESIGNAÇÃO, NOMEAÇÃO E TERMO DE COMPROMISSO DE BANCA, LISTA DE CANDIDATOS, QUESTIONÁRIO BIOGRÁFICO SIMPLIFICADO, CARTÕES RESPOSTAS, TESTES, PROVAS DE TÍTULO, RESULTADOS, RELAÇÃO DOS APROVADOS, RECURSOS, SELEÇÃO INGRESSO NA CARREIRA MILITAR |
| `082.1.a` | 24% | CONTAGEM DE ANTIGUIDADE, PROPOSTAS DE POSICIONAMENTO NO QUADRO DE ACESSO, FAIXA DE COGITAÇÃO, COGITAÇÃO / INCLUSÃO NO QUADRO DE ACESSO, LISTA DE ESCOLHA, ATO DE PROMOÇÃO, RESSARCIMENTO E RECONSIDERAÇÃO DE ATO, RECONTAGEM DE PONTOS, CORREÇÃO DE POSIÇÃ | ANTIGUIDADE, POSICIONAMENTO E COGITAÇÃO/INCLUSÃO QUADRO DE ACESSO, FAIXA DE COGITAÇÃO, LISTA DE ESCOLHA, ATO, RESSARCIMENTO/RECONSIDERAÇÃO, RECONTAGEM DE PONTOS, CORREÇÃO, RETIFICAÇÃO, MÉRITOS, INQUÉRITOS, PROMOÇÃO POST-MORTEM E POR MOTIVO DE JUSTIÇA |
| `085.631.a` | 35% | OBRIGATÓRIOS: CONTRIBUIÇÃO PARA A ASSISTÊNCIA MÉDICO-HOSPITALAR E SOCIAL (PRESTADA POR ENTIDADE MILITAR), IMPOSTOS INCIDENTES SOBRE A REMUNERAÇÃO OU PROVENTOS, INDENIZAÇÃO PELA ASSISTÊNCIA MÉDICO-HOSPITALAR (PRESTADA POR ENTIDADE MILITAR), INDENIZAÇÃ | CONTR. PARA A ASSISTÊNCIA MÉDICO-HOSPITALAR E SOCIAL, INDENIZAÇÃO PELA ASSISTÊNCIA, INDENIZAÇÃO À FAZENDA, MULTA POR OCUPAÇÃO IRREGULAR DE PRÓPRIO NACIONAL RESIDENCIAL, PENSÃO ALIMENTÍCIA OU JUDICIAL, CONTR. A PENSÃO MILITAR, TAXA DE USO POR OCUPAÇÃO |
| `087.12.a` | 32% | CONTROLE E VERIFICAÇÃO DO ESTADO DE HIGIDEZ (EM ESTADO SAUDÁVEL) DO PESSOAL EM SERVIÇO ATIVO, INATIVO E A SER SELECIONADO PARA INGRESSO NAS FORÇAS ARMADAS; ATESTADO SANITÁRIO DE ORIGEM; INQUÉRITO SANITÁRIO DE ORIGEM; RESULTADO DE EXAMES; AUTO DE CORP | CONTROLE E VERIFICAÇÃO DE HIGIDEZ DO PESSOAL; ATESTADO E INQUÉRITO SANITÁRIO; RESULTADO DE EXAMES; CORPO DE DELITO; INSPEÇÃO; PROCESSOS DE PERÍCIA PARA REFORMA, ISENÇÃO DE IMPOSTO DE RENDA, MELHORIA DE REFORMA E MOVIMENTAÇÃO POR MOTIVO DE SAÚDE |
| `900` | 7% | ASSUNTOS DIVERSOS | ADMINISTRAÇÃO DE ATIVIDADES ACESSÓRIAS |
| `990` | 28% | ASSUNTOS TRANSITÓRIOS | OUTRAS AÇÕES REFERENTES À ADMINISTRAÇÃO DE ATIVIDADES ACESSÓRIAS |
| `991` | 30% | APRESENTAÇÃO. RECOMENDAÇÃO (inclusive Cartas de Apresentação e Recomendação) | GESTÃO DE COMUNICAÇÕES EVENTUAIS |
| `992` | 33% | COMUNICADOS E INFORMES (inclusive Comunicações de Posse, Afastamento de Cargos e Alterações de Endereços e Telefones) | RELACIONAMENTO COM ASSOCIAÇÕES CULTURAIS, DE AMIGOS E DE SERVIDORES |

# Migração da tabela de assuntos — DE (2017) → PARA (2024)

> **Etapa 3 — Revisão da árvore completa e mapa técnico de correspondência**
> **Situação: diagnóstico analítico, NÃO homologado.**
> Fontes: `tabela_2017.csv` (701 registros) e `tabela_2024.csv` (684 registros).
> A ordem dos campos e das análises é sempre **DE 2017 → PARA 2024**.

## 1. Objetivo e limite

Este cruzamento amplia a Etapa 2 para **todos** os 701 assuntos de 2017 e todos os 684 assuntos de 2024, incluindo os 322 códigos comuns. Evidência textual não autoriza reclassificar processos nem altera automaticamente prazos de guarda ou destinação.

## 2. Resultados auditáveis

| Indicador | Resultado |
|---|---:|
| Registros DE (2017) | 701 |
| Registros PARA (2024) | 684 |
| Códigos em ambas | 322 |
| Códigos comuns com descrições distintas | 167 |
| Pares de códigos distintos com títulos normalizados idênticos | 168 |
| Linhas no mapa DE → PARA | 822 |
| Assuntos DE sem correspondência aprovada automaticamente | 468 |
| Relações textuais candidatas catalogadas | 424 |

**Atenção:** “sem correspondência comprovada” é uma situação de investigação, não um parecer de exclusão. Também não se deve afirmar que uma palavra coincidente determina desdobramento ou consolidação.

### Distribuição por hipótese de relação

| Relação preliminar | Linhas DE → PARA |
|---|---:|
| 1:1 (candidata) | 178 |
| 1:N (hipótese, não comprovado) | 48 |
| N:1 (hipótese, não comprovado) | 9 |
| N:M (ambiguidade) | 119 |
| sem correspondência comprovada | 468 |

## 3. Método e garantias

1. Conferência de unicidade do código dentro de cada versão; espaços indevidos nos códigos são eliminados **apenas em memória**.
2. Construção de hierarquia pela maior sequência de prefixo que também é um código válido da mesma versão (a hierarquia inferida deve ser conferida contra a estrutura oficial).
3. Busca cruzada de todos os assuntos por descrição normalizada, observação e contexto, sem restringir o destino a códigos exclusivos.
4. Coincidência integral do título produz apenas **equivalência textual**; não é homologação arquivística.
5. Similaridade computacional é empregada para triagem; os escores são relativos, não probabilidades.
6. Multiplicidade de pares textuais é rotulada hipótese 1:N/N:1/N:M. O desdobramento e a consolidação reais dependem de confirmação do escopo de cada nota explicativa.
7. Prazos e destinação são cotejados por par e diferenças preservadas para análise posterior.
8. Um código que exista em ambas as tabelas pode ter **significado alterado**; nunca é migrado por identidade numérica isolada.

## 4. Exemplos críticos: DE 2017 → PARA 2024

| DE — código | DE — descrição | PARA — código | PARA — descrição | Relação e ressalva |
|---|---|---|---|---|
| `023.1` | MOVIMENTAÇÃO DE PESSOAL | `022.2` | MOVIMENTAÇÃO DE PESSOAL | 1:1 (candidata); Equivalência textual, validar escopo e hierarquia |
| `024.1` | FOLHAS DE PAGAMENTO. FICHAS FINANCEIRAS | `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade); Hipótese por similaridade, requer revisão |
| `024.1` | FOLHAS DE PAGAMENTO. FICHAS FINANCEIRAS | `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade); Hipótese por similaridade, requer revisão |
| `024.13` | ADICIONAIS | `023.16` | ADICIONAIS | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |
| `024.13` | ADICIONAIS | `085.611` | ADICIONAIS | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |
| `024.13` | ADICIONAIS | `085.621` | ADICIONAIS | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |
| `024.2` | FÉRIAS | `023.2` | FÉRIAS | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |
| `024.2` | FÉRIAS | `085.5` | FÉRIAS | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |
| `025` | APURAÇÃO DE RESPONSABILIDADE E AÇÃO DISCIPLINAR | `027` | APURAÇÃO DE RESPONSABILIDADE DISCIPLINAR | 1:1 (candidata); Hipótese por similaridade, requer revisão |
| `029` | OUTROS ASSUNTOS REFERENTES A PESSOAL | `089` | OUTROS ASSUNTOS REFERENTES A PESSOAL MILITAR | N:1 (hipótese, não comprovado); Hipótese por similaridade, requer revisão |
| `031` | ESPECIFICAÇÃO. PADRONIZAÇÃO. CODIFICAÇÃO. PREVISÃO. CATÁLOGO. IDENTIFICAÇÃO. CLASSIFICAÇÃO (inclusive Amostras) | `030.03` | ESPECIFICAÇÃO, PADRONIZAÇÃO, CODIFICAÇÃO, PREVISÃO, IDENTIFICAÇÃO E CLASSIFICAÇÃO | 1:1 (candidata); Hipótese por similaridade, requer revisão |
| `033.2` | MATERIAL DE CONSUMO | `031.12` | MATERIAL DE CONSUMO | N:M (ambiguidade); Equivalência textual, validar escopo e hierarquia |

## 5. Mapa integral de correspondência (DE → PARA)

Esta listagem identifica os destinos textuais mais fortes, incluindo os códigos compartilhados; os campos de hierarquia, divergências e melhores candidatos não selecionados estão no CSV auditável. **Nenhuma linha está homologada.**

| DE — código 2017 | DE — descrição | PARA — código 2024 | PARA — descrição | Relação | Status |
|---|---|---|---|---|---|
| `000` | ADMINISTRAÇÃO GERAL | `000` | ADMINISTRAÇÃO GERAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `001` | MODERNIZAÇÃO E REFORMA ADMINISTRATIVA (inclusive Projetos, Estudos e Normas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `002` | PLANOS, PROGRAMAS E PROJETOS DE TRABALHO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `003` | RELATÓRIOS DE ATIVIDADES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `004` | ACORDOS. AJUSTES. CONTRATOS. CONVÊNIOS (Inclusive formalização, execução, acompanhamento, fiscalização, prestação de contas, tomada de contas e tomada de contas especial de convênios, contratos de repasse, termos de parceria e termos de cooperação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `010` | ORGANIZAÇÃO E FUNCIONAMENTO (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `010.1` | REGISTRO NOS ÓRGÃOS COMPETENTES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `010.2` | REGIMENTOS. REGULAMENTOS. ESTATUTOS. ORGANOGRAMAS. ESTRUTURAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `010.3` | AUDIÊNCIAS. DESPACHOS. REUNIÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `011` | COMISSÕES. CONSELHOS. GRUPOS DE TRABALHO. JUNTAS. COMITÊS (inclusive Atos de Criação, Atas e Relatórios) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `012` | COMUNICAÇÃO SOCIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `012.1` | RELAÇÕES COM A IMPRENSA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `012.11` | CREDENCIAMENTO DE JORNALISTAS | `019.111` | CREDENCIAMENTO DE JORNALISTAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `012.12` | ENTREVISTAS. NOTICIÁRIOS. REPORTAGENS. EDITORIAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `012.2` | DIVULGAÇÃO INTERNA | `019.12` | DIVULGAÇÃO INTERNA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `012.3` | CAMPANHAS INSTITUCIONAIS. PUBLICIDADE (inclusive Cartazes, Folhetos, Anúncios, Folders e outros documentos de caráter promocional) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019` | OUTROS ASSUNTOS REFERENTES À ORGANIZAÇÃO E FUNCIONAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.01` | INFORMAÇÕES SOBRE O ÓRGÃO (inclusive Pedidos de Informações sobre as Funções e Atividades do Órgão e os Serviços que presta) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020` | PESSOAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.1a` | LEGISLAÇÃO (Normas, Regulamentações, Diretrizes, Estatutos, Regulamentos, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.1b` | LEGISLAÇÃO (Boletins Administrativo, de Pessoal e de Serviço) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.2` | IDENTIFICAÇÃO FUNCIONAL (inclusive Carteira, Cartão, Crachá, Credencial e Passaporte Diplomático) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.3` | OBRIGAÇÕES TRABALHISTAS E ESTATUTÁRIAS. RELAÇÕES COM ÓRGÃOS NORMATIZADORES DA ADMINISTRAÇÃO PÚBLICA. LEI DOS 2/3. RAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.31` | RELAÇÕES COM OS CONSELHOS PROFISSIONAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.4` | SINDICATOS. ACORDOS. DISSÍDIOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `020.5` | ASSENTAMENTOS INDIVIDUAIS. CADASTRO (Vida Funcional do Servidor, bem como os registros e/ou anotações a ele referidos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `021` | RECRUTAMENTO E SELEÇÃO | `021` | RECRUTAMENTO E SELEÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `021.1` | CANDIDATOS A CARGO E EMPREGO PÚBLICOS: INSCRIÇÃO E CURRICULUM VITAE | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `021.2a` | EXAMES DE SELEÇÃO (Concurso Público: Provas e Títulos, Testes Psicotécnicos e Exames Médicos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `021.2b` | EXAMES DE SELEÇÃO (Concurso Público: Constituição de Bancas Examinadoras, Editais, Exemplares Únicos de Provas, Gabaritos, Resultados e Recursos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022` | APERFEIÇOAMENTO E TREINAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.1` | CURSOS (inclusive Bolsas de Estudo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.11` | PROMOVIDOS PELA INSTITUIÇÃO (inclusive Propostas, Estudos, Editais, Programas, Relatórios Finais, Exemplares Únicos de Exercícios, Relação de Participantes, Avaliação e Controle de Expedição de Certificados) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.12` | PROMOVIDOS POR OUTRAS INSTITUIÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.121` | NO BRASIL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.122` | NO EXTERIOR | `028.2` | NO EXTERIOR | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `022.2` | ESTÁGIOS (inclusive Bolsas de Estágio) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.21` | PROMOVIDOS PELA INSTITUIÇÃO (inclusive Estudos, Propostas, Programas, Relatórios Finais, Relação de Participantes, Avaliação e Declaração de Comprovação de Estágio) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.22` | PROMOVIDOS POR OUTRAS INSTITUIÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.221` | NO BRASIL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `022.222` | NO EXTERIOR | `028.2` | NO EXTERIOR | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `022.9` | OUTROS ASSUNTOS REFERENTES A APERFEIÇOAMENTO E TREINAMENTO (inclusive Palestras e Reuniões de caráter informativo geral promovidas pelo órgão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023` | QUADROS, TABELAS E POLÍTICA DE PESSOAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.01` | ESTUDOS E PREVISÃO DE PESSOAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.02` | CRIAÇÃO, CLASSIFICAÇÃO, TRANSFORMAÇÃO, TRANSPOSIÇÃO E REMUNERAÇÃO DE CARGOS E FUNÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.03` | REESTRUTURAÇÕES E ALTERAÇÕES SALARIAIS (inclusive Ascensão e Progressão Funcional; Avaliação de Desempenho; Enquadramento; Equiparação, Reajuste e Reposição Salarial; Promoções) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.1` | MOVIMENTAÇÃO DE PESSOAL | `022.2` | MOVIMENTAÇÃO DE PESSOAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `023.11` | ADMISSÃO. APROVEITAMENTO. CONTRATAÇÃO. NOMEAÇÃO. READMISSÃO. READAPTAÇÃO. RECONDUÇÃO. REINTEGRAÇÃO. REVERSÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.12` | DEMISSÃO. DISPENSA. EXONERAÇÃO. RESCISÃO CONTRATUAL. FALECIMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.13` | LOTAÇÃO. REMOÇÃO. TRANSFERÊNCIA. PERMUTA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.14` | DESIGNAÇÃO. DISPONIBILIDADE. REDISTRIBUIÇÃO. SUBSTITUIÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `023.15` | REQUISIÇÃO. CESSÃO (Internas e/ou Externas de Servidores para a realização de serviços temporários) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024` | DIREITOS, OBRIGAÇÕES E VANTAGENS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.1` | FOLHAS DE PAGAMENTO. FICHAS FINANCEIRAS | `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `024.1` | FOLHAS DE PAGAMENTO. FICHAS FINANCEIRAS | `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `024.11` | SALÁRIOS, VENCIMENTOS, PROVENTOS E REMUNERAÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.111` | SALÁRIO-FAMÍLIA | `026.1` | SALÁRIO FAMÍLIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.112.a` | ABONO OU PROVENTO PROVISÓRIO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.112.b` | ABONO DE PERMANÊNCIA EM SERVIÇO | `023.14` | ABONO DE PERMANÊNCIA EM SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.119` | OUTROS SALÁRIOS, VENCIMENTOS, PROVENTOS E REMUNERAÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.12` | GRATIFICAÇÕES (inclusive Incorporações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.121` | DE FUNÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.122` | JETONS | `023.152` | JETONS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.123` | CARGOS EM COMISSÃO | `023.153` | CARGOS EM COMISSÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.124` | NATALINA (Décimo Terceiro Salário) | `023.154` | NATALINA. DÉCIMO TERCEIRO SALÁRIO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.129` | OUTRAS GRATIFICAÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.13` | ADICIONAIS | `023.16` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.13` | ADICIONAIS | `085.611` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.13` | ADICIONAIS | `085.621` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.131` | TEMPO DE SERVIÇO (Anuênios, Biênios e Quinquênios) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.132` | NOTURNO | `023.162` | NOTURNO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.133` | PERICULOSIDADE | `023.163` | PERICULOSIDADE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.134` | INSALUBRIDADE | `023.164` | INSALUBRIDADE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.135` | ATIVIDADES PENOSAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.136` | SERVIÇO EXTRAORDINÁRIO (Horas Extras) | `023.166` | SERVIÇO EXTRAORDINÁRIO. HORAS EXTRAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.137` | FÉRIAS: ADICIONAL DE 1/3 E ABONO PECUNIÁRIO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.139` | OUTROS ADICIONAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.14` | DESCONTOS | `023.17` | DESCONTOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.14` | DESCONTOS | `085.63` | DESCONTOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.141` | CONTRIBUIÇÃO SINDICAL DO SERVIDOR | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.142` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | `023.172` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.142` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | `023.184` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.143` | IMPOSTO DE RENDA RETIDO NA FONTE (IRRF) | `023.173` | IMPOSTO DE RENDA RETIDO NA FONTE (IRRF) | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.144` | PENSÕES ALIMENTÍCIAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.145` | CONSIGNAÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.149` | OUTROS DESCONTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.15` | ENCARGOS PATRONAIS. RECOLHIMENTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.151` | PROGRAMA DE FORMAÇÃO DO PATRIMÔNIO DO SERVIDOR PÚBLICO (PASEP). PROGRAMA DE INTEGRAÇÃO SOCIAL (PIS) | `023.181` | PROGRAMA DE FORMAÇÃO DO PATRIMÔNIO DO SERVIDOR PÚBLICO (PASEP). PROGRAMA DE INTEGRAÇÃO SOCIAL (PIS) | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.152` | FUNDO DE GARANTIA POR TEMPO DE SERVIÇO (FGTS) | `023.182` | FUNDO DE GARANTIA DO TEMPO DE SERVIÇO (FGTS) | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `024.153` | CONTRIBUIÇÃO SINDICAL DO EMPREGADOR | `023.183` | CONTRIBUIÇÃO SINDICAL DO EMPREGADOR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.154` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL (inclusive Contribuições anteriores) | `023.184` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `024.154` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL (inclusive Contribuições anteriores) | `023.172` | CONTRIBUIÇÃO PARA O PLANO DE SEGURIDADE SOCIAL | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `024.155` | SALÁRIO MATERNIDADE | `026.2` | SALÁRIO MATERNIDADE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.156` | IMPOSTO DE RENDA | `023.185` | IMPOSTO DE RENDA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `024.2` | FÉRIAS | `023.2` | FÉRIAS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.2` | FÉRIAS | `085.5` | FÉRIAS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `024.3` | LICENÇAS (Doença em Pessoa da Família; Afastamento do Cônjuge; Serviço Militar; Atividade Política; Capacitação; Prêmio; Interesses Particulares; Mandato Classista; Gestante; Adotante; Paternidade; Tratamento da Própria Saúde; Acidente em Serviço) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.4` | AFASTAMENTOS (Para Depor; Para Exercer Mandato Eletivo; Para Servir ao Tribunal Regional Eleitoral - TRE; Para Servir como Jurado; Suspensão de Contrato de Trabalho - CLT) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.5` | REEMBOLSO DE DESPESAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.51` | MUDANÇA DE DOMICÍLIO DE SERVIDORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.52` | LOCOMOÇÃO (Despesas Efetuadas com a Utilização de Meio Próprio de Locomoção para a Execução de Serviços Externos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.59` | OUTROS REEMBOLSOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.9` | OUTROS DIREITOS, OBRIGAÇÕES E VANTAGENS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.91` | CONCESSÕES (Doação de Sangue; Alistamento Eleitoral; Casamento - Gala; Falecimento de Familiares - Nojo; Horário Especial para Servidor Estudante; Horário Especial para Servidor Portador de Deficiência) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `024.92` | AUXÍLIOS (Alimentação/Refeição; Assistência Pré-Escolar/Creche; Fardamento/Uniforme; Moradia; Vale-Transporte) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `025` | APURAÇÃO DE RESPONSABILIDADE E AÇÃO DISCIPLINAR | `027` | APURAÇÃO DE RESPONSABILIDADE DISCIPLINAR | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `025.1` | DENÚNCIAS. SINDICÂNCIAS. INQUÉRITOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `025.11` | PROCESSOS DISCIPLINARES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `025.12` | PENALIDADES DISCIPLINARES (Advertência, Suspensão, Demissão, Cassação de Aposentadoria, Disponibilidade, Destituição de Cargo em Comissão, Destituição de Função Comissionada) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026` | PREVIDÊNCIA, ASSISTÊNCIA E SEGURIDADE SOCIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.01` | PREVIDÊNCIA PRIVADA (Planos Privados de Concessão de Pecúlios ou de Rendas, de Benefícios Complementares ou assemelhados aos da previdência social) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.1` | BENEFÍCIOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.11` | SEGUROS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.12a` | AUXÍLIOS (Acidente; Doença; Funeral; Natalidade) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.12b` | AUXÍLIOS (Reclusão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.13` | APOSENTADORIA | `026.5` | APOSENTADORIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `026.131` | CONTAGEM E AVERBAÇÃO DE TEMPO DE SERVIÇO | `026.02` | CONTAGEM E AVERBAÇÃO DE TEMPO DE SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `026.132.a` | PENSÕES: PROVISÓRIA E TEMPORÁRIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.132.b` | PENSÃO VITALÍCIA | `026.62` | PENSÃO VITALÍCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `026.19` | OUTROS BENEFÍCIOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.191` | ADIANTAMENTOS E EMPRÉSTIMOS A SERVIDORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.192.a` | ASSISTÊNCIA À SAÚDE (inclusive Planos de Saúde) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.192.b` | ASSISTÊNCIA À SAÚDE (Prontuário Médico do Servidor) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.193` | AQUISIÇÃO DE IMÓVEIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.194` | OCUPAÇÃO DE IMÓVEIS PRÓPRIOS DA UNIÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.195` | TRANSPORTES PARA SERVIDORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.2` | HIGIENE E SEGURANÇA DO TRABALHO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.21a` | PREVENÇÃO DE ACIDENTES DE TRABALHO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.21b` | COMISSÃO INTERNA DE PREVENÇÃO DE ACIDENTES - CIPA (inclusive Criação, Designação, Propostas, Relatórios e Atas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.22` | REFEITÓRIOS, CANTINAS E COPAS (Fornecimento de Refeições) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `026.23` | INSPEÇÕES PERIÓDICAS DE SAÚDE | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029` | OUTROS ASSUNTOS REFERENTES A PESSOAL | `089` | OUTROS ASSUNTOS REFERENTES A PESSOAL MILITAR | N:1 (hipótese, não comprovado) | Hipótese por similaridade, requer revisão |
| `029.1` | HORÁRIO DE EXPEDIENTE (inclusive Escala de Plantão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.11` | CONTROLE DE FREQUÊNCIA (Livros, Cartões, Folhas de Ponto, Abono de Faltas, Cumprimento de Horas Extras) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.2` | MISSÕES FORA DA SEDE. VIAGENS A SERVIÇO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.21` | NO PAÍS (Ajudas de Custo; Diárias; Passagens - inclusive Devolução; Prestações de Contas; Relatórios de Viagem) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.22` | NO EXTERIOR (Afastamento do País) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.221` | SEM ÔNUS PARA A INSTITUIÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.222` | COM ÔNUS PARA A INSTITUIÇÃO (Autorização de Afastamento; Diárias, inclusive Compra de Moeda Estrangeira; Lista de Participantes, no caso de Comitivas e Delegações; Passagens; Passaportes; Prestações de Contas; Relatórios de Viagem; Reservas de Hotel) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.3` | INCENTIVOS FUNCIONAIS | `029.3` | INCENTIVOS FUNCIONAIS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `029.31` | PRÊMIOS (Concessão de Medalhas, Diplomas de Honra ao Mérito e Elogios) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.4` | DELEGAÇÕES DE COMPETÊNCIA. PROCURAÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.5` | SERVIÇOS PROFISSIONAIS TRANSITÓRIOS: AUTÔNOMOS E COLABORADORES (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.6` | AÇÕES TRABALHISTAS. RECLAMAÇÕES TRABALHISTAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `029.7` | MOVIMENTOS REIVINDICATÓRIOS: GREVES E PARALISAÇÕES | `020.032` | MOVIMENTOS REIVINDICATÓRIOS. GREVES. PARALISAÇÕES | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `030` | MATERIAL (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `030.1` | CADASTRO DE FORNECEDORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `031` | ESPECIFICAÇÃO. PADRONIZAÇÃO. CODIFICAÇÃO. PREVISÃO. CATÁLOGO. IDENTIFICAÇÃO. CLASSIFICAÇÃO (inclusive Amostras) | `030.03` | ESPECIFICAÇÃO, PADRONIZAÇÃO, CODIFICAÇÃO, PREVISÃO, IDENTIFICAÇÃO E CLASSIFICAÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `032` | REQUISIÇÃO E CONTROLE DE SERVIÇOS REPROGRÁFICOS (inclusive Assinaturas Autorizadas e Reprodução de Formulários) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033` | AQUISIÇÃO (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.1` | MATERIAL PERMANENTE (Equipamentos, Mobiliário, Aparelhos, Ferramentas, Máquinas, Instrumentos Técnicos e Obras de Arte) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.11` | COMPRA (inclusive Compra por Importação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.12` | ALUGUEL. COMODATO. LEASING | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.13a` | EMPRÉSTIMO. CESSÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.13b` | DOAÇÃO. PERMUTA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.2` | MATERIAL DE CONSUMO | `031.12` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `031.22` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `031.32` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `031.42` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `033.12` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `033.22` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `033.32` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `033.42` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.2` | MATERIAL DE CONSUMO | `033.52` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.21` | COMPRA | `031.1` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.21` | COMPRA | `041.1` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.21` | COMPRA | `062.11` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `033.22` | CESSÃO. DOAÇÃO. PERMUTA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `033.23` | CONFECÇÃO DE IMPRESSOS (inclusive Formulários, Convites, Cartazes, Cartões e outros) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034` | MOVIMENTAÇÃO DE MATERIAL (Permanente e de Consumo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.01` | TERMOS DE RESPONSABILIDADE (inclusive Relatório de Movimentação de Bens Móveis - RMBM) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.1` | CONTROLE DE ESTOQUE (inclusive Requisição, Distribuição e Relatório de Movimentação de Almoxarifado - RMA) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.2` | EXTRAVIO. ROUBO. DESAPARECIMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.3` | TRANSPORTE DE MATERIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.4` | AUTORIZAÇÃO DE SAÍDA DE MATERIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `034.5` | RECOLHIMENTO DE MATERIAL AO DEPÓSITO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `035` | ALIENAÇÃO. BAIXA (Material Permanente e de Consumo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `035.1` | VENDA (inclusive Leilão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `035.2` | CESSÃO. DOAÇÃO. PERMUTA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `036` | INSTALAÇÃO E MANUTENÇÃO (Serviços de Instalação, Conservação, Recuperação e Consertos de Equipamentos e Mobiliário) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `036.1` | REQUISIÇÃO E CONTRATAÇÃO DE SERVIÇOS (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `036.2` | SERVIÇOS EXECUTADOS EM OFICINAS DO ÓRGÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `037` | INVENTÁRIO | `062.3` | INVENTÁRIO | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `031.11` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `031.21` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `031.31` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `031.41` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `033.11` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `033.21` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `033.31` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `033.41` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.1` | MATERIAL PERMANENTE | `033.51` | MATERIAL PERMANENTE | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `031.12` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `031.22` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `031.32` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `031.42` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `033.12` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `033.22` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `033.32` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `033.42` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `037.2` | MATERIAL DE CONSUMO | `033.52` | MATERIAL DE CONSUMO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `039` | OUTROS ASSUNTOS REFERENTES A MATERIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `040` | PATRIMÔNIO (Bens Imóveis, Veículos e Semoventes pertencentes ao Órgão) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041` | BENS IMÓVEIS (Projetos, Plantas e Escrituras relativos aos edifícios, terrenos, residências e salas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.01` | FORNECIMENTO E MANUTENÇÃO DE SERVIÇOS BÁSICOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.011` | ÁGUA E ESGOTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.012` | GÁS | `045.12` | GÁS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `041.013` | LUZ E FORÇA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.02` | COMISSÃO INTERNA DE CONSERVAÇÃO DE ENERGIA - CICE (Criação, Designação, Propostas de Redução de Gastos com Energia, Relatórios e Atas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.03` | CONDOMÍNIO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.1` | AQUISIÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.11` | COMPRA | `031.1` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.11` | COMPRA | `041.1` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.11` | COMPRA | `062.11` | COMPRA | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.12` | CESSÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.13` | DOAÇÃO | `062.12` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.13` | DOAÇÃO | `062.41` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.14` | PERMUTA | `062.13` | PERMUTA | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `041.15` | LOCAÇÃO. ARRENDAMENTO. COMODATO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.2` | ALIENAÇÃO | `042` | ALIENAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `041.21` | VENDA | `033.1` | VENDA | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `041.21` | VENDA | `042.1` | VENDA | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `041.22` | CESSÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.23` | DOAÇÃO | `062.12` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.23` | DOAÇÃO | `062.41` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `041.24` | PERMUTA | `062.13` | PERMUTA | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `041.3` | DESAPROPRIAÇÃO. REINTEGRAÇÃO DE POSSE. REIVINDICAÇÃO DE DOMÍNIO. TOMBAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.4` | OBRAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.41` | REFORMA. RECUPERAÇÃO. RESTAURAÇÃO | `045.32` | REFORMA. RECUPERAÇÃO. RESTAURAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `041.42` | CONSTRUÇÃO | `045.31` | CONSTRUÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `041.5` | SERVIÇOS DE MANUTENÇÃO (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.51` | MANUTENÇÃO DE ELEVADORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.52` | MANUTENÇÃO DE AR CONDICIONADO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.53` | MANUTENÇÃO DE SUBESTAÇÕES E GERADORES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.54` | LIMPEZA. IMUNIZAÇÃO. DESINFESTAÇÃO (inclusive para Jardins) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `041.59` | OUTROS SERVIÇOS DE MANUTENÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042` | VEÍCULOS | `041.12` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `041.22` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `041.32` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `041.52` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `041.62` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `042.12` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `042.22` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `042.32` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `042.52` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042` | VEÍCULOS | `042.71` | VEÍCULOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `042.1` | AQUISIÇÃO (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.11` | COMPRA (inclusive Compra por Importação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.12` | ALUGUEL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.13` | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.2` | CADASTRO. LICENCIAMENTO. EMPLACAMENTO. TOMBAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.3` | ALIENAÇÃO (inclusive Licitações) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.31` | VENDA (inclusive Leilão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.32` | CESSÃO. DOAÇÃO. PERMUTA. TRANSFERÊNCIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.4` | ABASTECIMENTO. LIMPEZA. MANUTENÇÃO. REPARO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.5` | ACIDENTES. INFRAÇÕES. MULTAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.9` | OUTROS ASSUNTOS REFERENTES A VEÍCULOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.91` | CONTROLE DE USO DE VEÍCULOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.911` | REQUISIÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.912` | AUTORIZAÇÃO PARA USO FORA DO HORÁRIO DE EXPEDIENTE | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `042.913` | ESTACIONAMENTO. GARAGEM | `044.5` | ESTACIONAMENTO. GARAGEM | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `041.13` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `041.23` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `041.53` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `042.13` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `042.23` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `042.53` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `043` | BENS SEMOVENTES | `042.72` | BENS SEMOVENTES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `044` | INVENTÁRIO (inclusive Relatório de Movimentação de Bens Imóveis - RMBI) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049` | OUTROS ASSUNTOS REFERENTES A PATRIMÔNIO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.1` | GUARDA E SEGURANÇA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.11` | SERVIÇOS DE VIGILÂNCIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.12` | SEGUROS (inclusive de Veículos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.13a` | PREVENÇÃO DE INCÊNDIO (Treinamento de Pessoal, Instalação e Manutenção de Extintores, Inspeções Periódicas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.13b` | PREVENÇÃO DE INCÊNDIO (Constituição de Brigadas de Incêndio, Planos, Projetos e Relatórios) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.14` | SINISTRO (inclusive Vistorias, Sindicâncias e Perícias Técnicas relativas a Arrombamento, Desaparecimento, Extravio, Incêndio e Roubo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.15a` | CONTROLE DE PORTARIA (Entrada e Saída de Pessoas, Materiais e Veículos; Permissão para Entrada e Permanência fora do horário de expediente; Controle de Entrega e Devolução de Chaves) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.15b` | CONTROLE DE PORTARIA (Registro de Ocorrências) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.2` | MUDANÇAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.21` | PARA OUTROS IMÓVEIS | `043.61` | PARA OUTROS IMÓVEIS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `049.22` | DENTRO DO MESMO IMÓVEL | `043.62` | DENTRO DO MESMO IMÓVEL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `049.3` | USO DE DEPENDÊNCIAS (Utilização de Auditório e demais Dependências do Imóvel, pelo órgão ou por terceiros) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `050` | ORÇAMENTO E FINANÇAS (Previsão e Execução; Operações Contábeis; Receita e Despesa; Movimentação de Conta; Balanços; Prestações de Contas) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `050.1` | AUDITORIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051` | ORÇAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.1` | PROGRAMAÇÃO ORÇAMENTÁRIA | `051.1` | PROGRAMAÇÃO ORÇAMENTÁRIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `051.11` | PREVISÃO ORÇAMENTÁRIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.12` | PROPOSTA ORÇAMENTÁRIA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.13` | QUADRO DE DETALHAMENTO DE DESPESA - QDD (inclusive as Metas e Destinação de Recursos e Receitas por Fontes) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.14` | CRÉDITOS ADICIONAIS (Crédito Suplementar. Crédito Especial. Crédito Extraordinário) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.2` | EXECUÇÃO ORÇAMENTÁRIA | `051.3` | EXECUÇÃO ORÇAMENTÁRIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `051.21` | DESCENTRALIZAÇÃO DE RECURSOS (Distribuição Orçamentária) (Transferências, Provisão, Destaques, Estornos e Subvenções) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.22` | ACOMPANHAMENTO DE DESPESA MENSAL (Pessoal/Dívida) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `051.23` | PLANO OPERATIVO. CRONOGRAMA DE DESEMBOLSO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `052` | FINANÇAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `052.1` | PROGRAMAÇÃO FINANCEIRA DE DESEMBOLSO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `052.2` | EXECUÇÃO FINANCEIRA (inclusive Despesas Correntes e de Capital) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `052.21` | RECEITA (inclusive Créditos do Tesouro Nacional - cota, repasse e sub-repasse; Taxas Cobradas por Serviços; Multas; Emolumentos; e outras rendas arrecadadas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `052.22` | DESPESA (inclusive Despesas Correntes e de Capital, bem como Adiantamentos, Subvenções, Suprimento de Fundos e Restos a Pagar) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `053` | FUNDOS ESPECIAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `054` | ESTÍMULOS FINANCEIROS E CREDITÍCIOS (inclusive Subsídios, Incentivos Fiscais e Investimentos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `055` | OPERAÇÕES BANCÁRIAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `055.01` | PAGAMENTOS EM MOEDA ESTRANGEIRA | `053.1` | PAGAMENTO EM MOEDA ESTRANGEIRA | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `055.1` | CONTA ÚNICA (inclusive Assinaturas Autorizadas e Extratos de Contas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `055.2` | OUTRAS CONTAS: TIPO B, C e D (inclusive Assinaturas Autorizadas e Extratos de Contas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `056` | BALANÇOS. BALANCETES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `057` | TOMADA DE CONTAS. PRESTAÇÃO DE CONTAS (inclusive Parecer de Aprovação das Contas). TOMADA DE CONSTAS ESPECIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `059` | OUTROS ASSUNTOS REFERENTES A ORÇAMENTO E FINANÇAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `059.1` | TRIBUTOS (Impostos e Taxas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `060` | DOCUMENTAÇÃO E INFORMAÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `060.1` | PUBLICAÇÃO DE MATÉRIAS NO DIÁRIO OFICIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `060.2` | PUBLICAÇÃO DE MATÉRIAS NOS BOLETINS ADMINISTRATIVO, DE PESSOAL E DE SERVIÇO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `060.3` | PUBLICAÇÃO DE MATÉRIAS EM OUTROS PERIÓDICOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `061` | PRODUÇÃO EDITORIAL (inclusive Edição ou Coedição de Publicações em Geral produzidas pelo órgão em qualquer suporte) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `061.1` | EDITORAÇÃO. PROGRAMAÇÃO VISUAL | `065.2` | EDITORAÇÃO E PROGRAMAÇÃO VISUAL | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `061.2` | DISTRIBUIÇÃO. PROMOÇÃO. DIVULGAÇÃO | `065.3` | PROMOÇÃO, DIVULGAÇÃO E DISTRIBUIÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `062` | DOCUMENTAÇÃO BIBLIOGRÁFICA (Livros, Periódicos, Folhetos e Audiovisuais) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.01` | NORMAS E MANUAIS (inclusive Estudos e Textos referentes à Elaboração de Metodologias e Procedimentos Técnicos adotados para o Tratamento da Documentação Bibliográfica) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.1` | AQUISIÇÃO (no Brasil e no exterior) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.11` | COMPRA (inclusive Assinaturas de Periódicos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.12` | DOAÇÃO | `062.12` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `062.12` | DOAÇÃO | `062.41` | DOAÇÃO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `062.13` | PERMUTA | `062.13` | PERMUTA | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `062.2` | REGISTRO (inclusive Incorporação de Livros e Periódicos ao Acervo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.3` | CATALOGAÇÃO. CLASSIFICAÇÃO. INDEXAÇÃO | `062.22` | CATALOGAÇÃO, CLASSIFICAÇÃO E INDEXAÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `062.4` | REFERÊNCIA E CIRCULAÇÃO (inclusive Consultas, Pesquisas Bibliográficas, Bibliografias, Empréstimos e Intercâmbio entre Bibliotecas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `062.5` | INVENTÁRIO | `062.3` | INVENTÁRIO | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `063` | DOCUMENTAÇÃO ARQUIVÍSTICA: GESTÃO DE DOCUMENTOS E SISTEMA DE ARQUIVOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.01` | NORMAS E MANUAIS (inclusive Estudos e Orientações referentes à Elaboração de Documentos, Metodologias e Procedimentos Técnicos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.1a` | PRODUÇÃO DE DOCUMENTOS. LEVANTAMENTO. DIAGNÓSTICO. FLUXO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.1b` | PRODUÇÃO DE DOCUMENTOS. LEVANTAMENTO. DIAGNÓSTICO. FLUXO (Diagnóstico) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.2` | PROTOCOLO: RECEPÇÃO, TRAMITAÇÃO E EXPEDIÇÃO DE DOCUMENTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.3` | ASSISTÊNCIA TÉCNICA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.4a` | CLASSIFICAÇÃO E ARQUIVAMENTO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.4b` | CLASSIFICAÇÃO E ARQUIVAMENTO (Códigos de Classificação de Documentos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.5` | POLÍTICA DE ACESSO AOS DOCUMENTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.51` | CONSULTAS. EMPRÉSTIMOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.6` | DESTINAÇÃO DE DOCUMENTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.61a` | ANÁLISE. AVALIAÇÃO. SELEÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.61b` | ANÁLISE. AVALIAÇÃO. SELEÇÃO (Tabela de Temporalidade) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.62` | ELIMINAÇÃO (inclusive Termos, Listagens e Editais de Ciência de Eliminação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `063.63` | TRANSFERÊNCIA. RECOLHIMENTO (inclusive Guias e Termos de Transferência; Guias, Relações e Termos de Recolhimento; e Listagens Descritivas do Acervo) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `064` | DOCUMENTAÇÃO MUSEOLÓGICA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `065` | REPRODUÇÃO DE DOCUMENTOS (em qualquer suporte, de material arquivístico, bibliográfico e museológico) (inclusive Estudos, Projetos e Normas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `066` | CONSERVAÇÃO DE DOCUMENTOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `066.1` | DESINFESTAÇÃO. HIGIENIZAÇÃO | `064.1` | DESINFESTAÇÃO E HIGIENIZAÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `066.2` | ARMAZENAMENTO. DEPÓSITOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `066.3` | RESTAURAÇÃO (inclusive Encadernação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067` | INFORMÁTICA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067.1` | PLANOS E PROJETOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067.2` | PROGRAMAS. SISTEMAS. REDES (inclusive Licença e Registro de Uso e Compra) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067.21` | MANUAIS TÉCNICOS (Exemplares Únicos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067.22` | MANUAIS DO USUÁRIO (Exemplares Únicos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `067.3` | ASSISTÊNCIA TÉCNICA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `069` | OUTROS ASSUNTOS REFERENTES À DOCUMENTAÇÃO E INFORMAÇÃO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `070` | COMUNICAÇÕES (Instalação, Manutenção, Operação e Uso dos Recursos e Serviços Postais, de Telecomunicações e de Tecnologias da Informação) (inclusive Normas, Regulamentações, Diretrizes, Procedimentos, Estudos e/ou Decisões de Caráter Geral) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071` | SERVIÇO POSTAL | `071.1` | SERVIÇO POSTAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `071.1` | SERVIÇOS DE ENTREGA EXPRESSA | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071.11` | NACIONAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071.12` | INTERNACIONAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071.2` | SERVIÇOS DE COLETA, TRANSPORTE E ENTREGA DE CORRESPONDÊNCIA AGRUPADA – MALOTE | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071.3` | MALA OFICIAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `071.9` | OUTROS SERVIÇOS POSTAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `072` | SERVIÇO DE RÁDIO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `072.1` | INSTALAÇÃO. MANUTENÇÃO. REPARO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `073` | SERVIÇO DE TELEX | `071.3` | SERVIÇO DE TELEX | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `073` | SERVIÇO DE TELEX | `073.2` | SERVIÇO DE TELEX | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `073.1` | INSTALAÇÃO. MANUTENÇÃO. REPARO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `074` | SERVIÇO TELEFÔNICO (inclusive Autorização para Ligações Interurbanas). FAC-SÍMILE (Fax) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `074.1` | INSTALAÇÃO. TRANSFERÊNCIA. MANUTENÇÃO. REPARO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `074.2` | LISTAS TELEFÔNICAS INTERNAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `074.3` | CONTAS TELEFÔNICAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `075` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | `071.5` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `075` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | `073.4` | SERVIÇO DE TRANSMISSÃO DE DADOS, VOZ E IMAGEM | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `079` | OUTROS ASSUNTOS REFERENTES A COMUNICAÇÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `090` | OUTROS ASSUNTOS REFERENTES À ADMINISTRAÇÃO GERAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `091` | AÇÕES JUDICIAIS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `900` | ASSUNTOS DIVERSOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `910.a` | SOLENIDADES. COMEMORAÇÕES. HOMENAGENS (inclusive Discursos e Palestras proferidas por convidados) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `910.b` | SOLENIDADES. COMEMORAÇÕES. HOMENAGENS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `920.a` | CONGRESSOS. CONFERÊNCIAS. SEMINÁRIOS. SIMPÓSIOS. ENCONTROS. CONVENÇÕES. CICLOS DE PALESTRAS. MESAS REDONDAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `920.b` | CONGRESSOS. CONFERÊNCIAS. SEMINÁRIOS. SIMPÓSIOS. ENCONTROS. CONVENÇÕES. CICLOS DE PALESTRAS. MESAS REDONDAS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `930.a` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `930.b` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Planejamento, Programação, Discursos, Palestras e Trabalhos apresentados por Técnicos do Órgão) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `930.c` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Planejamento, Editais, Habilitação dos Candidatos, Julgamento da Banca, Trabalhos Concorrentes, Premiação e Recursos) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `930.d` | FEIRAS. SALÕES. EXPOSIÇÕES. MOSTRAS. CONCURSOS. FESTAS (Normas) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `940` | VISITAS E VISITANTES (inclusive Solicitações de Audiência, Assistência, Orientação e Assessoramento a Visitantes) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `990` | ASSUNTOS TRANSITÓRIOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `991` | APRESENTAÇÃO. RECOMENDAÇÃO (inclusive Cartas de Apresentação e Recomendação) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `992` | COMUNICADOS E INFORMES (inclusive Comunicações de Posse, Afastamento de Cargos e Alterações de Endereços e Telefones) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `993` | AGRADECIMENTOS. CONVITES. FELICITAÇÕES. PÊSAMES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `994` | PROTESTOS. REIVINDICAÇÕES. SUGESTÕES | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `995` | PEDIDOS, OFERECIMENTOS E INFORMAÇÕES DIVERSAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `996` | ASSOCIAÇÕES: CULTURAIS, DE AMIGOS E DE SERVIDORES | `992` | RELACIONAMENTO COM ASSOCIAÇÕES CULTURAIS, DE AMIGOS E DE SERVIDORES | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `019.1` | PLANEJAMENTO INSTITUCIONAL | `015.1` | PLANEJAMENTO INSTITUCIONAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `019.11` | GESTÃO DE PROJETOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.12` | MAPEAMENTO E MODELAGEM DE PROCESSOS DE TRABALHO. ATRIBUIÇÕES E COMPETÊNCIAS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.13` | DESEMPENHO INSTITUCIONAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.2` | GESTÃO SOCIOAMBIENTAL | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.3` | RESPONSABILIDADE SOCIAL / VOLUNTARIADO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `019.4` | PROGRAMAS SOCIOEDUCATIVOS | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `049.4` | GESTÃO DE RESÍDUOS (incluem-se documentos referentes à reciclagem de resíduos e outras formas de destinação ambiental) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `092` | CONTRATAÇÃO E EXECUÇÃO DE SERVIÇO (Incluem-se documentos referentes a todas as fases da prestação de serviço por pessoa jurídica: Licitação, Contratação, Execução, Acompanhamento e Pagamento) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `080` | PESSOAL MILITAR | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `080.1` | LEGISLAÇÃO (normas; avisos; portarias de caráter geral; boletins administrativo, de pessoal e de serviço; diretrizes; procedimentos; pareceres; estudos e/ou decisões de caráter geral) | `080.1` | LEGISLAÇÃO (normas; avisos; portarias de caráter geral; boletins administrativo, de pessoal e de serviço; diretrizes; procedimentos; pareceres; estudos e/ou decisões de caráter geral) | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.2` | IDENTIFICAÇÃO MILITAR | `080.2` | IDENTIFICAÇÃO MILITAR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.21` | IDENTIDADE MILITAR. CARTEIRA. CARTÃO | `080.21` | IDENTIDADE MILITAR. CARTEIRA. CARTÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.21.a` | FICHA DE IDENTIDADE GRANDE, FICHA INDIVIDUAL DATILOSCÓPICA, CARTÃO ÍNDICE, FICHA DE DADOS CADASTRAIS | `080.21.a` | FICHA DE IDENTIDADE GRANDE, FICHA INDIVIDUAL DATILOSCÓPICA, CARTÃO ÍNDICE, FICHA DE DADOS CADASTRAIS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.21.b` | GUIA DE REMESSA DE MATERIAL DE IDENTIFICAÇÃO, MAPA MENSAL DO MATERIAL TÉCNICO | `080.21.b` | GUIA DE REMESSA DE MATERIAL DE IDENTIFICAÇÃO, MAPA MENSAL DO MATERIAL TÉCNICO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.21.c` | IDENTIDADE PROVISÓRIA | `080.21.c` | IDENTIDADE PROVISÓRIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.22` | CONCESSÃO DE PASSAPORTE: DIPLOMÁTICO E/OU OFICIAL | `080.22` | CONCESSÃO DE PASSAPORTE: DIPLOMÁTICO E/OU OFICIAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `080.3` | ASSENTAMENTOS INDIVIDUAIS.CADASTRO | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `080.3.a` | FOLHAS DE ALTERAÇÕES, CADERNETA REGISTRO CADASTRO, CADERNETA SANITÁRIA, DECLARAÇÃO / CADASTRO DE DEPENDENTES, FICHA INDIVIDUAL, DECLARAÇÃO / ALTERAÇÃO DE BENEFICIÁRIOS, TERMO DE OPÇÃO OU DE RETIFICAÇÃO DA LICENÇA ESPECIAL, TERMO DE RENÚNCIA DE PENSÃO | `080.3.a` | FOLHAS DE ALTERAÇÕES, CADERNETA REGISTRO CADASTRO, CADERNETA SANITÁRIA, DECLARAÇÃO/CADASTRO DE DEPENDENTES, FICHA INDIVIDUAL, DECLARAÇÃO/ALTERAÇÃO DE BENEFICIÁRIOS, TERMO DE OPÇÃO OU DE RETIFICAÇÃO DA LICENÇA ESPECIAL, TERMO DE RENÚNCIA DE PENSÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `080.3.b` | FICHA DE APRESENTAÇÃO, CONTAGEM DE TEMPO DE SERVIÇO, FICHA PADRÃO PASEP, FICHA DE CÓDIGO DE ESPECIALIDADE, CONCESSÃO E CESSAÇÃO DE PORTE DE ARMA | `080.3.b` | FICHA DE APRESENTAÇÃO, CONTAGEM DE TEMPO DE SERVIÇO, FICHA PADRÃO PASEP, FICHA DE CÓDIGO DE ESPECIALIDADE, CONCESSÃO E CESSAÇÃO DE PORTE DE ARMA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081` | INGRESSO NAS FORÇAS ARMADAS | `081` | INGRESSO NAS FORÇAS ARMADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.1` | RECRUTAMENTO.SELEÇÃO: INSCRIÇÃO PARA CONCURSO, CRONOGRAMA DE REALIZAÇÃO DE PROVAS, CONTROLE DE APLICAÇÃO DAS PROVAS | `081.1` | RECRUTAMENTO. SELEÇÃO: INSCRIÇÃO PARA CONCURSO, CRONOGRAMA DE REALIZAÇÃO DE PROVAS, CONTROLE DE APLICAÇÃO DAS PROVAS | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `081.1.a` | EDITAL DE CONCURSOS E ORIENTAÇÕES ESPECÍFICAS. MATERIAL DE DIVULGAÇÃO*, RELATÓRIOS E ATAS DOS PROCESSOS SELETIVOS, PROVAS ESCRITAS, PRÁTICAS E ORAIS*, GABARITOS*, INSTRUÇÕES COMPLEMENTARES DE CONVOCAÇÃO E DE SISTEMA DE SERVIÇO MILITAR | `081.1.a` | EDITAL DE CONCURSOS E ORIENTAÇÕES ESPECÍFICAS. MATERIAL DE DIVULGAÇÃO*, RELATÓRIOS E ATAS DOS PROCESSOS SELETIVOS, PROVAS ESCRITAS, PRÁTICAS E ORAIS*, GABARITOS*, INSTRUÇÕES COMPLEMENTARES DE CONVOCAÇÃO E DE SISTEMA DE SERVIÇO MILITAR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.1.b` | SELEÇÃO E DESIGNAÇÃO PARA INCORPORAÇÃO E MATRÍCULA, NOMEAÇÃO E TERMO DE COMPROMISSO DE BANCA DE PROVAS, LISTA DE CANDIDATOS, QUESTIONÁRIO BIOGRÁFICO SIMPLIFICADO, CARTÕES RESPOSTAS DE TESTES OU PROVAS DO CANDIDATO, TESTES, PROVAS DE TÍTULO, RESULTADO | `081.1.b` | SELEÇÃO E DESIGNAÇÃO, NOMEAÇÃO E TERMO DE COMPROMISSO DE BANCA, LISTA DE CANDIDATOS, QUESTIONÁRIO BIOGRÁFICO SIMPLIFICADO, CARTÕES RESPOSTAS, TESTES, PROVAS DE TÍTULO, RESULTADOS, RELAÇÃO DOS APROVADOS, RECURSOS, SELEÇÃO INGRESSO NA CARREIRA MILITAR | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `081.2` | INCORPORAÇÃO | `081.2` | INCORPORAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.2.a` | ATOS DE CONVOCAÇÃO À INCORPORAÇÃO, ALISTAMENTOS, ESTÁGIOS, DISPENSA OU ISENÇÃO DO SERVIÇO MILITAR, CONVOCAÇÃO À INCORPORAÇÃO PARA PRESTAR SERVIÇO MILITAR OBRIGATÓRIO (SERVIÇO MILITAR INICIAL OU OUTRAS FORMAS POSTERIORES) | `081.2.a` | ATOS DE CONVOCAÇÃO À INCORPORAÇÃO, ALISTAMENTOS, ESTÁGIOS, DISPENSA OU ISENÇÃO DO SERVIÇO MILITAR, CONVOCAÇÃO À INCORPORAÇÃO PARA PRESTAR SERVIÇO MILITAR OBRIGATÓRIO (SERVIÇO MILITAR INICIAL OU OUTRAS FORMAS POSTERIORES) | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.3` | MATRÍCULA | `081.3` | MATRÍCULA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.3.a` | ADMISSÃO EM ESCOLAS, CENTROS E CURSOS DE FORMAÇÃO | `081.3.a` | ADMISSÃO EM ESCOLAS, CENTROS E CURSOS DE FORMAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.4` | NOMEAÇÃO | `081.4` | NOMEAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.4.a` | INGRESSO NOS CORPOS E/OU QUADROS DE CARREIRA DE OFICIAIS, NOS POSTOS INICIAIS OU NOS CORPOS / QUADROS DE OFICIAIS DA RESERVA | `081.4.a` | INGRESSO NOS CORPOS E/OU QUADROS DE CARREIRA DE OFICIAIS, NOS POSTOS INICIAIS OU NOS CORPOS/QUADROS DE OFICIAIS DA RESERVA | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `081.5` | EXERCÍCIOS DE MOBILIZAÇÃO /APRESENTAÇÃO | `081.5` | EXERCÍCIOS DE MOBILIZAÇÃO / APRESENTAÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `081.5.a` | CAMPANHAS DE CONVOCAÇÃO, MAPAS DE ENCARGOS DE MOBILIZAÇÃO, RELATÓRIOS SOBRE O EXERCÍCIO DE APRESENTAÇÃO DA RESERVA, CONTROLE DE EFETIVO DE MILITARES TEMPORÁRIOS (MÉDICOS, FARMACÊUTICOS, DENTISTAS, VETERINÁRIOS), TIROS DE GUERRA | `081.5.a` | CAMPANHAS DE CONVOCAÇÃO, MAPAS DE ENCARGOS DE MOBILIZAÇÃO, RELATÓRIOS SOBRE O EXERCÍCIO DE APRESENTAÇÃO DA RESERVA, CONTROLE DE EFETIVO DE MILITARES TEMPORÁRIOS (MÉDICOS, FARMACÊUTICOS, DENTISTAS, VETERINÁRIOS), TIROS DE GUERRA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `081.9` | OUTROS ASSUNTOS REFERENTES A INGRESSO NAS FORÇAS ARMADAS | `081.9` | OUTROS ASSUNTOS REFERENTES A INGRESSO NAS FORÇAS ARMADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082` | PLANO DE CARREIRA | `082` | PLANO DE CARREIRA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.1` | PROMOÇÃO | `082.1` | PROMOÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.1.a` | CONTAGEM DE ANTIGUIDADE, PROPOSTAS DE POSICIONAMENTO NO QUADRO DE ACESSO, FAIXA DE COGITAÇÃO, COGITAÇÃO / INCLUSÃO NO QUADRO DE ACESSO, LISTA DE ESCOLHA, ATO DE PROMOÇÃO, RESSARCIMENTO E RECONSIDERAÇÃO DE ATO, RECONTAGEM DE PONTOS, CORREÇÃO DE POSIÇÃ | `082.1.a` | ANTIGUIDADE, POSICIONAMENTO E COGITAÇÃO/INCLUSÃO QUADRO DE ACESSO, FAIXA DE COGITAÇÃO, LISTA DE ESCOLHA, ATO, RESSARCIMENTO/RECONSIDERAÇÃO, RECONTAGEM DE PONTOS, CORREÇÃO, RETIFICAÇÃO, MÉRITOS, INQUÉRITOS, PROMOÇÃO POST-MORTEM E POR MOTIVO DE JUSTIÇA | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `082.2` | CURSOS | `082.2` | CURSOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.21` | FORMAÇÃO. ADAPTAÇÃO | `082.21` | FORMAÇÃO. ADAPTAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.21.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CONCURSOS | `082.21.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CONCURSOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.22` | APERFEIÇOAMENTO.ESPECIALIZAÇÃO | `082.22` | APERFEIÇOAMENTO.ESPECIALIZAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23` | ESTADO-MAIOR | `082.23` | ESTADO-MAIOR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24` | ALTOS ESTUDOS MILITARES | `082.24` | ALTOS ESTUDOS MILITARES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.3` | AVALIAÇÃO | `061.52` | AVALIAÇÃO | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `082.3` | AVALIAÇÃO | `082.3` | AVALIAÇÃO | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `082.3.a` | FICHAS / FOLHAS DE AVALIAÇÃO | `082.3.a` | FICHAS/FOLHAS DE AVALIAÇÃO | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `082.4` | REQUISITOS ESPECÍFICOS DE CARREIRA | `082.4` | REQUISITOS ESPECÍFICOS DE CARREIRA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.4.a` | MANOBRA, TEMPO DE TROPA, TEMPO DE EMBARQUE, VIVÊNCIA NACIONAL, DIAS DE MAR, ATIVIDADE BÉLICA, HORAS DE VOO | `082.4.a` | MANOBRA, TEMPO DE TROPA, TEMPO DE EMBARQUE, VIVÊNCIA NACIONAL, DIAS DE MAR, ATIVIDADE BÉLICA, HORAS DE VOO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.5` | CURSOS COMPLEMENTARES | `082.5` | CURSOS COMPLEMENTARES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.51` | ADESTRAMENTO | `045.7` | ADESTRAMENTO | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `082.51` | ADESTRAMENTO | `082.51` | ADESTRAMENTO | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `082.51.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS DIVERSOS TIPOS DE ADESTRAMENTO | `082.51.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS DIVERSOS TIPOS DE ADESTRAMENTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.52` | PÓS-GRADUAÇÃO LATO SENSU | `082.52` | PÓS-GRADUAÇÃO LATO SENSU | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53` | QUALIFICAÇÃO TÉCNICA ESPECIAL | `082.53` | QUALIFICAÇÃO TÉCNICA ESPECIAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54` | PÓS-GRADUAÇÃO STRICTO SENSU | `082.54` | PÓS-GRADUAÇÃO STRICTO SENSU | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55` | PÓS-DOUTORADO | `082.55` | PÓS-DOUTORADO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.22.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.23.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.24.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.52.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.53.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.54.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | `082.55.a` | DESIGNAÇÃO, MATRÍCULA, CONCLUSÃO, CANCELAMENTO, TRANCAMENTO E/OU DESLIGAMENTO DOS CURSOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.6` | PRORROGAÇÃO DE TEMPO DE SERVIÇO. REENGAJAMENTO | `082.6` | PRORROGAÇÃO DE TEMPO DE SERVIÇO. REENGAJAMENTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.6.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | `082.6.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.6.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | `082.7.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.7` | TRANSPOSIÇÃO DE QUADRO | `082.7` | TRANSPOSIÇÃO DE QUADRO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `082.7.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | `082.6.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.7.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | `082.7.a` | REQUERIMENTOS, AVALIAÇÕES, PARECERES E DESPACHOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `082.9` | OUTROS ASSUNTOS REFERENTES A PLANO DE CARREIRA | `082.9` | OUTROS ASSUNTOS REFERENTES A PLANO DE CARREIRA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083` | MOVIMENTAÇÃO. DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO: MAPAS DE LOTAÇÃO DE OFICIAIS E PRAÇAS | `083` | MOVIMENTAÇÃO. DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO: MAPAS DE LOTAÇÃO DE OFICIAIS E PRAÇAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.a` | PLANOS DE MOVIMENTAÇÃO | `083.a` | PLANOS DE MOVIMENTAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.1` | MOVIMENTAÇÃO | `083.1` | MOVIMENTAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.11` | MOTIVO DE SAÚDE | `083.11` | MOTIVO DE SAÚDE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.11.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, CÓPIA DA ATA DE INSPEÇÃO DE SAÚDE, TERMO DE INSPEÇÃO DE SAÚDE | `083.11.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, CÓPIA DA ATA DE INSPEÇÃO DE SAÚDE, TERMO DE INSPEÇÃO DE SAÚDE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.12` | INTERESSE DO MILITAR | `083.12` | INTERESSE DO MILITAR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.12.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, ORDEM DE MOVIMENTAÇÃO, PORTARIA DE MOVIMENTAÇÃO | `083.12.a` | SOLICITAÇÃO DA MOVIMENTAÇÃO, ORDEM DE MOVIMENTAÇÃO, PORTARIA DE MOVIMENTAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.13` | NECESSIDADE DO SERVIÇO | `083.13` | NECESSIDADE DO SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.13.a` | PROPOSTA DE PLANO DE MOVIMENTAÇÃO, SOLICITAÇÕES DE ÓRGÃOS DE DIREÇÃO-GERAL OU SETORIAL, INCOMPATIBILIDADE DE POSTO, MATRÍCULA, TÉRMINO DE CURSO, INTERCÂMBIO E A BEM DA DISCIPLINA | `083.13.a` | PROPOSTA DE PLANO DE MOVIMENTAÇÃO, SOLICITAÇÕES DE ÓRGÃOS DE DIREÇÃO-GERAL OU SETORIAL, INCOMPATIBILIDADE DE POSTO, MATRÍCULA, TÉRMINO DE CURSO, INTERCÂMBIO E A BEM DA DISCIPLINA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.14` | MOTIVO DE JUSTIÇA | `083.14` | MOTIVO DE JUSTIÇA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.14.a` | ORDEM JUDICIAL | `083.14.a` | ORDEM JUDICIAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.2` | DESTAQUE. ADIÇÃO | `083.2` | DESTAQUE. ADIÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.2.a` | PARECERES, DESPACHOS | `083.2.a` | PARECERES, DESPACHOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.3` | EXCLUSÃO DO SERVIÇO ATIVO | `083.3` | EXCLUSÃO DO SERVIÇO ATIVO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.3.a` | DEMISSÃO, PERDA DE POSTO E DA PATENTE, LICENCIAMENTO, ANULAÇÃO DE INCORPORAÇÃO, DESINCORPORAÇÃO, A BEM DA DISCIPLINA, FALECIMENTO | `083.3.a` | DEMISSÃO, PERDA DE POSTO E DA PATENTE, LICENCIAMENTO, ANULAÇÃO DE INCORPORAÇÃO, DESINCORPORAÇÃO, A BEM DA DISCIPLINA, FALECIMENTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.3.b` | DESERÇÃO. EXTRAVIO | `083.3.b` | DESERÇÃO. EXTRAVIO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.9` | OUTROS ASSUNTOS REFERENTES À MOVIMENTAÇÃO.DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO | `083.9` | OUTROS ASSUNTOS REFERENTES À MOVIMENTAÇÃO.DESTAQUE. ADIÇÃO. EXCLUSÃO DO SERVIÇO ATIVO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `083.9.a` | POSSE E NOMEAÇÃO PARA CARGOS PÚBLICOS | `083.9.a` | POSSE E NOMEAÇÃO PARA CARGOS PÚBLICOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084` | VIOLAÇÃO DAS OBRIGAÇÕES E DOS DEVERES | `084` | VIOLAÇÃO DAS OBRIGAÇÕES E DOS DEVERES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.1` | TRANSGRESSÕES E/OU CONTRAVENÇÕES DISCIPLINARES | `084.1` | TRANSGRESSÕES E/OU CONTRAVENÇÕES DISCIPLINARES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.1.a` | SINDICÂNCIA, ACAREAÇÃO E APURAÇÃO DAS TRANSGRESSÕES E/OU CONTRAVENÇÕES, APLICAÇÃO DAS PUNIÇÕES DISCIPLINARES | `084.1.a` | SINDICÂNCIA, ACAREAÇÃO E APURAÇÃO DAS TRANSGRESSÕES E/OU CONTRAVENÇÕES, APLICAÇÃO DAS PUNIÇÕES DISCIPLINARES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.2` | CRIMES MILITARES | `084.2` | CRIMES MILITARES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.2.a` | PORTARIA DE NOMEAÇÃO DO ENCARREGADO E ESCRIVÃO DO IPM, SOLUÇÃO DO IPM, OFÍCIO DE REMESSA DO IPM À JUSTIÇA MILITAR | `084.2.a` | PORTARIA DE NOMEAÇÃO DO ENCARREGADO E ESCRIVÃO DO IPM, SOLUÇÃO DO IPM, OFÍCIO DE REMESSA DO IPM À JUSTIÇA MILITAR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.3` | CONSELHOS | `084.3` | CONSELHOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.31` | DE DISCIPLINA | `084.31` | DE DISCIPLINA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.31.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | `084.31.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `084.31.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | `084.32.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `084.32` | DE JUSTIFICAÇÃO | `084.32` | DE JUSTIFICAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `084.32.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | `084.31.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `084.32.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | `084.32.a` | NOMEAÇÃO DOS MEMBROS DO CONSELHO, ATOS DE AFASTAMENTO DO ACUSADO, AUTOS DO CONSELHO, CONCLUSÕES E DECISÕES | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085` | DIREITOS E PRERROGATIVAS | `085` | DIREITOS E PRERROGATIVAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.1` | RECOMPENSAS. DISTINÇÕES. HONRARIAS | `085.1` | RECOMPENSAS. DISTINÇÕES. HONRARIAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.1.a` | PRÊMIOS DE HONRA AO MÉRITO, ELOGIOS, LOUVORES, REFERÊNCIAS ELOGIOSAS, DISTINTIVOS, DISPENSAS DE SERVIÇO | `085.1.a` | PRÊMIOS DE HONRA AO MÉRITO, ELOGIOS, LOUVORES, REFERÊNCIAS ELOGIOSAS, DISTINTIVOS, DISPENSAS DE SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.1.b` | RELAÇÕES DE AGRACIADOS COM AS CONDECORAÇÕES, RELAÇÕES DAQUELES QUE TIVERAM AS CONDECORAÇÕES CASSADAS | `085.1.b` | RELAÇÕES DE AGRACIADOS COM AS CONDECORAÇÕES, RELAÇÕES DAQUELES QUE TIVERAM AS CONDECORAÇÕES CASSADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.2` | LICENÇAS | `023.3` | LICENÇAS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.2` | LICENÇAS | `026.4` | LICENÇAS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.2` | LICENÇAS | `085.2` | LICENÇAS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.2.a` | ADOTANTE, PARA ACOMPANHAR CÔNJUGE / COMPANHEIRO, CANDIDATO A CARGO ELETIVO, ESPECIAL, GESTANTE, PATERNIDADE, PARA TRATAR DE INTERESSE PARTICULAR, PARA TRATAMENTO DE SAÚDE DE PESSOA DA FAMÍLIA, PARA TRATAMENTO DE SAÚDE PRÓPRIA | `085.2.a` | ADOTANTE, PARA ACOMPANHAR CÔNJUGE/COMPANHEIRO, CANDIDATO A CARGO ELETIVO, ESPECIAL, GESTANTE, PATERNIDADE, PARA TRATAR DE INTERESSE PARTICULAR, PARA TRATAMENTO DE SAÚDE DE PESSOA DA FAMÍLIA, PARA TRATAMENTO DE SAÚDE PRÓPRIA | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `085.3` | AFASTAMENTOS | `023.4` | AFASTAMENTOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.3` | AFASTAMENTOS | `085.3` | AFASTAMENTOS | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.3.a` | INSTALAÇÃO (NO BRASIL E NO EXTERIOR), LUTO, NÚPCIAS, TRÂNSITO (NO BRASIL E NO EXTERIOR) | `085.3.a` | INSTALAÇÃO (NO BRASIL E NO EXTERIOR), LUTO, NÚPCIAS, TRÂNSITO (NO BRASIL E NO EXTERIOR) | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.4` | DISPENSAS DE SERVIÇO | `085.4` | DISPENSAS DE SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.4.a` | PARA DESCONTO EM FÉRIAS, POR PRESCRIÇÃO MÉDICA | `085.4.a` | PARA DESCONTO EM FÉRIAS, POR PRESCRIÇÃO MÉDICA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.5` | FÉRIAS | `023.2` | FÉRIAS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.5` | FÉRIAS | `085.5` | FÉRIAS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.5.a` | PLANEJAMENTO, SOLICITAÇÃO, CONCESSÃO, CANCELAMENTO E PUBLICAÇÃO | `085.5.a` | PLANEJAMENTO, SOLICITAÇÃO, CONCESSÃO, CANCELAMENTO E PUBLICAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.6` | REMUNERAÇÃO. PROVENTOS | `085.6` | REMUNERAÇÃO. PROVENTOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.61` | REMUNERAÇÃO NA ATIVA | `085.61` | REMUNERAÇÃO NA ATIVA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.611` | ADICIONAIS | `023.16` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.611` | ADICIONAIS | `085.611` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.611` | ADICIONAIS | `085.621` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.611.a` | MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | `085.611.a` | MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.612` | GRATIFICAÇÕES | `023.15` | GRATIFICAÇÕES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.612` | GRATIFICAÇÕES | `085.612` | GRATIFICAÇÕES | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `085.612.a` | DE LOCALIDADE ESPECIAL, DE REPRESENTAÇÃO | `085.612.a` | DE LOCALIDADE ESPECIAL, DE REPRESENTAÇÃO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.619` | OUTROS DIREITOS REMUNERATÓRIOS NA ATIVA | `085.619` | OUTROS DIREITOS REMUNERATÓRIOS NA ATIVA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.619.a` | ADICIONAL DE FÉRIAS, ADICIONAL NATALINO, AJUDA DE CUSTO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: FARDAMENTO, ALIMENTAÇÃO, NATALIDADE, INVALIDEZ, FUNERAL E TRANSPORTE, COMPENSAÇÃO PECUNIÁRIA, DIÁRIAS, SALÁRIO-FAMÍLIA, TRANSPORTE DE PESSOAL E BAGAGENS POR M | `085.619.a` | ADICIONAL DE FÉRIAS E NATALINO; AJUDA DE CUSTO; ASSISTÊNCIA PRÉ-ESCOLAR; AUXÍLIOS FARDAMENTO, ALIMENTAÇÃO, NATALIDADE, INVALIDEZ, FUNERAL E TRANSPORTE; COMPENSAÇÃO; DIÁRIAS; SALÁRIO-FAMÍLIA; TRANSPORTE; ADIANTAMENTO DE FÉRIAS; RETRIBUIÇÃO NO EXTERIOR | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `085.62` | PROVENTOS NA INATIVIDADE | `085.62` | PROVENTOS NA INATIVIDADE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | `085.61.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | `085.62.a` | FICHAS FINANCEIRAS E FOLHAS DE PAGAMENTO | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.621` | ADICIONAIS | `023.16` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.621` | ADICIONAIS | `085.611` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.621` | ADICIONAIS | `085.621` | ADICIONAIS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.621.a` | ADICIONAIS: MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | `085.621.a` | ADICIONAIS: MILITAR, DE HABILITAÇÃO, DE TEMPO DE SERVIÇO, DE COMPENSAÇÃO ORGÂNICA, DE PERMANÊNCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.629` | OUTROS DIREITOS PECUNIÁRIOS NA INATIVIDADE | `085.629` | OUTROS DIREITOS PECUNIÁRIOS NA INATIVIDADE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.629.a` | ADICIONAL NATALINO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: INVALIDEZ, NATALIDADE E FUNERAL, SALÁRIO-FAMÍLIA, ADICIONAL POR DESIGNAÇÃO PARA O SERVIÇO ATIVO, PRO-LABORE PARA TAREFA POR TEMPO CERTO, AJUDA DE TRANSPORTE POR BAIXA / ALTA EM ORGANIZAÇÃO, HOSPI | `085.629.a` | ADICIONAL NATALINO, ASSISTÊNCIA PRÉ-ESCOLAR, AUXÍLIOS: INVALIDEZ, NATALIDADE E FUNERAL, SALÁRIO-FAMÍLIA, ADICIONAL DESIGNAÇÃO PARA O SERVIÇO ATIVO, PRO-LABORE PARA TAREFA POR TEMPO CERTO, AJUDA DE TRANSPORTE POR BAIXA/ALTA EM ORGANIZAÇÃO, HOSPITALAR | 1:1 (candidata) | Hipótese por similaridade, requer revisão |
| `085.63` | DESCONTOS | `023.17` | DESCONTOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.63` | DESCONTOS | `085.63` | DESCONTOS | N:M (ambiguidade) | Equivalência textual, validar escopo e hierarquia |
| `085.631` | OBRIGATÓRIOS | `085.631` | OBRIGATÓRIOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.631.a` | OBRIGATÓRIOS: CONTRIBUIÇÃO PARA A ASSISTÊNCIA MÉDICO-HOSPITALAR E SOCIAL (PRESTADA POR ENTIDADE MILITAR), IMPOSTOS INCIDENTES SOBRE A REMUNERAÇÃO OU PROVENTOS, INDENIZAÇÃO PELA ASSISTÊNCIA MÉDICO-HOSPITALAR (PRESTADA POR ENTIDADE MILITAR), INDENIZAÇÃ | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `085.632` | AUTORIZADOS | `085.632` | AUTORIZADOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `085.632.a` | DESCONTOS EM FAVOR DE ENTIDADE CONSIGNATÁRIAS, DE TERCEIRO OU BENEFÍCIO FAMÍLIA | `085.632.a` | DESCONTOS EM FAVOR DE ENTIDADE CONSIGNATÁRIAS, DE TERCEIRO OU BENEFÍCIO FAMÍLIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086` | INATIVOS E PENSIONISTAS | `086` | INATIVOS E PENSIONISTAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.1` | INATIVOS | `086.1` | INATIVOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.11` | RESERVA | `086.11` | RESERVA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.111` | REMUNERADA | `086.111` | REMUNERADA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.111.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA REMUNERADA | `086.111.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA REMUNERADA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.112` | NÃO REMUNERADA | `086.112` | NÃO REMUNERADA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.112.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA NÃO REMUNERADA | `086.112.a` | PROCESSO DE TRANSFERÊNCIA PARA A RESERVA NÃO REMUNERADA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.12` | REFORMA | `086.12` | REFORMA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.121` | POR INVALIDEZ | `086.121` | POR INVALIDEZ | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.121.a` | PROCESSO DE REFORMA POR INVALIDEZ | `086.121.a` | PROCESSO DE REFORMA POR INVALIDEZ | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.122` | POR IDADES-LIMITE | `086.122` | POR IDADES-LIMITE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.122.a` | PROCESSO DE REFORMA POR IDADES-LIMITE | `086.122.a` | PROCESSO DE REFORMA POR IDADES-LIMITE | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.13` | DESIGNAÇÃO PARA O SERVIÇO ATIVO | `086.13` | DESIGNAÇÃO PARA O SERVIÇO ATIVO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.13.a` | PROCESSO DE DESIGNAÇÃO PARA O SERVIÇO ATIVO | `086.13.a` | PROCESSO DE DESIGNAÇÃO PARA O SERVIÇO ATIVO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.14` | TAREFA POR TEMPO CERTO | `086.14` | TAREFA POR TEMPO CERTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.14.a` | PROCESSO DE DESIGNAÇÃO PARA TAREFA POR TEMPO CERTO | `086.14.a` | PROCESSO DE DESIGNAÇÃO PARA TAREFA POR TEMPO CERTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.2` | PENSIONISTAS | `086.2` | PENSIONISTAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.21` | PENSÕES | `086.21` | PENSÕES | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.211` | TEMPORÁRIA | `086.211` | TEMPORÁRIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.211.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA | `086.211.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `086.211.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA | `086.213.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR ESPECIAL | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `086.212` | VITALÍCIA | `086.212` | VITALÍCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `086.212.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR VITALÍCIA | `086.212.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR VITALÍCIA | 1:N (hipótese, não comprovado) | Hipótese por similaridade, requer revisão |
| `086.212.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR VITALÍCIA | `086.213.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR ESPECIAL | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `086.213` | ESPECIAL | `026.54` | ESPECIAL | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `086.213` | ESPECIAL | `086.213` | ESPECIAL | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `086.213.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR ESPECIAL | `086.213.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR ESPECIAL | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `086.213.a` | PROCESSOS DE SOLICITAÇÃO /CONCESSÃO DE PENSÃO MILITAR ESPECIAL | `086.211.a` | PROCESSOS DE SOLICITAÇÃO/CONCESSÃO DE PENSÃO MILITAR TEMPORÁRIA | N:M (ambiguidade) | Hipótese por similaridade, requer revisão |
| `087` | ASSISTÊNCIA | `087` | ASSISTÊNCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.1` | MÉDICA | `087.1` | MÉDICA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.11` | HOSPITALAR | `087.11` | HOSPITALAR | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.11.a` | ATENDIMENTO AMBULATORIAL OU PRONTO-ATENDIMENTO | `087.11.a` | ATENDIMENTO AMBULATORIAL OU PRONTO-ATENDIMENTO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.11.b` | PRONTUÁRIOS MÉDICOS, FICHAS ODONTOLÓGICAS | `087.11.b` | PRONTUÁRIOS MÉDICOS, FICHAS ODONTOLÓGICAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.12` | PERICIAL | `087.12` | PERICIAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.12.a` | CONTROLE E VERIFICAÇÃO DO ESTADO DE HIGIDEZ (EM ESTADO SAUDÁVEL) DO PESSOAL EM SERVIÇO ATIVO, INATIVO E A SER SELECIONADO PARA INGRESSO NAS FORÇAS ARMADAS; ATESTADO SANITÁRIO DE ORIGEM; INQUÉRITO SANITÁRIO DE ORIGEM; RESULTADO DE EXAMES; AUTO DE CORP | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `087.2` | SOCIAL | `087.2` | SOCIAL | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.2.a` | PROGRAMAS DE ASSISTÊNCIA SOCIAL COM VISTAS À CONCESSÃO DE LICENÇAS E BENEFÍCIOS; ATENDIMENTOS EDUCACIONAIS E ASSISTENCIAIS PRESTADOS POR EMPRESAS CONVENIADAS | `087.2.a` | PROGRAMAS DE ASSISTÊNCIA SOCIAL COM VISTAS À CONCESSÃO DE LICENÇAS E BENEFÍCIOS; ATENDIMENTOS EDUCACIONAIS E ASSISTENCIAIS PRESTADOS POR EMPRESAS CONVENIADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.3` | JURÍDICA | `087.3` | JURÍDICA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.3.a` | ORIENTAÇÃO DE CARÁTER PARTICULAR; ATENDIMENTOS JURÍDICOS PRESTADOS POR EMPRESAS CONVENIADAS | `087.3.a` | ORIENTAÇÃO DE CARÁTER PARTICULAR; ATENDIMENTOS JURÍDICOS PRESTADOS POR EMPRESAS CONVENIADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.4` | PSICOLÓGICA | `087.4` | PSICOLÓGICA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.4.a` | TRIAGEM PARA ENCAMINHAMENTO AO SERVIÇO DE SAÚDE ESPECÍFICO; ORIENTAÇÃO E ACONSELHAMENTO PSICOLÓGICO; ATENDIMENTOS PSICOLÓGICOS PRESTADOS POR EMPRESAS CONVENIADAS | `087.4.a` | TRIAGEM PARA ENCAMINHAMENTO AO SERVIÇO DE SAÚDE ESPECÍFICO; ORIENTAÇÃO E ACONSELHAMENTO PSICOLÓGICO; ATENDIMENTOS PSICOLÓGICOS PRESTADOS POR EMPRESAS CONVENIADAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.5` | RELIGIOSA | `087.5` | RELIGIOSA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.5.a` | CENSO RELIGIOSO | `087.5.a` | CENSO RELIGIOSO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `087.5.b` | PROCESSOS DE HABILITAÇÃO E REGISTROS DE CASAMENTO; BATIZADO E CRISMA; LIVRO TOMBO | `087.5.b` | PROCESSOS DE HABILITAÇÃO E REGISTROS DE CASAMENTO; BATIZADO E CRISMA; LIVRO TOMBO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `088` | (VAGA) | `088` | VAGA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089` | OUTROS ASSUNTOS REFERENTES A PESSOAL MILITAR | `089` | OUTROS ASSUNTOS REFERENTES A PESSOAL MILITAR | N:1 (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `089.1` | SERVIÇOS DE ESCALA | `089.1` | SERVIÇOS DE ESCALA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.1.a` | ESCALAS DE SERVIÇO | `089.1.a` | ESCALAS DE SERVIÇO | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.2` | TABELAS MESTRAS | `089.2` | TABELAS MESTRAS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.2.a` | TABELAS INDIVIDUAIS E GERAIS | `089.2.a` | TABELAS INDIVIDUAIS E GERAIS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.3` | CONTROLE DE FREQUÊNCIA | `029.11` | CONTROLE DE FREQUÊNCIA | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `089.3` | CONTROLE DE FREQUÊNCIA | `089.3` | CONTROLE DE FREQUÊNCIA | 1:N (hipótese, não comprovado) | Equivalência textual, validar escopo e hierarquia |
| `089.3.a` | FICHAS DE CONTROLE DE EFETIVOS; LIVROS DE LICENCIADOS | `089.3.a` | FICHAS DE CONTROLE DE EFETIVOS; LIVROS DE LICENCIADOS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.4` | DELEGAÇÕES DE COMPETÊNCIA | `089.4` | DELEGAÇÕES DE COMPETÊNCIA | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `089.4.a` | ATOS DE DELEGAÇÃO; RELAÇÃO DE ENCARGOS COLATERAIS | `089.4.a` | ATOS DE DELEGAÇÃO; RELAÇÃO DE ENCARGOS COLATERAIS | 1:1 (candidata) | Equivalência textual, validar escopo e hierarquia |
| `098.1` | Assunto adicional reservado para a Área-Meio 1 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.11` | Assunto adicional reservado para a Área-Meio 2 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.12` | Assunto adicional reservado para a Área-Meio 3 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.13` | Assunto adicional reservado para a Área-Meio 4 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.14` | Assunto adicional reservado para a Área-Meio 5 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.15` | Assunto adicional reservado para a Área-Meio 6 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.16` | Assunto adicional reservado para a Área-Meio 7 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.17` | Assunto adicional reservado para a Área-Meio 8 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.18` | Assunto adicional reservado para a Área-Meio 9 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.19` | Assunto adicional reservado para a Área-Meio 10 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.2` | Assunto adicional reservado para a Área-Meio 11 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.21` | Assunto adicional reservado para a Área-Meio 12 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.22` | Assunto adicional reservado para a Área-Meio 13 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.23` | Assunto adicional reservado para a Área-Meio 14 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.24` | Assunto adicional reservado para a Área-Meio 15 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.25` | Assunto adicional reservado para a Área-Meio 16 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.26` | Assunto adicional reservado para a Área-Meio 17 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.27` | Assunto adicional reservado para a Área-Meio 18 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.28` | Assunto adicional reservado para a Área-Meio 19 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.29` | Assunto adicional reservado para a Área-Meio 20 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.3` | Assunto adicional reservado para a Área-Meio 21 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.31` | Assunto adicional reservado para a Área-Meio 22 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.32` | Assunto adicional reservado para a Área-Meio 23 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.33` | Assunto adicional reservado para a Área-Meio 24 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.34` | Assunto adicional reservado para a Área-Meio 25 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.35` | Assunto adicional reservado para a Área-Meio 26 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.36` | Assunto adicional reservado para a Área-Meio 27 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.37` | Assunto adicional reservado para a Área-Meio 28 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.38` | Assunto adicional reservado para a Área-Meio 29 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.39` | Assunto adicional reservado para a Área-Meio 30 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.4` | Assunto adicional reservado para a Área-Meio 31 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.41` | Assunto adicional reservado para a Área-Meio 32 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.42` | Assunto adicional reservado para a Área-Meio 33 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.43` | Assunto adicional reservado para a Área-Meio 34 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.44` | Assunto adicional reservado para a Área-Meio 35 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.45` | Assunto adicional reservado para a Área-Meio 36 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.46` | Assunto adicional reservado para a Área-Meio 37 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.47` | Assunto adicional reservado para a Área-Meio 38 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.48` | Assunto adicional reservado para a Área-Meio 39 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.49` | Assunto adicional reservado para a Área-Meio 40 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.5` | Assunto adicional reservado para a Área-Meio 41 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.51` | Assunto adicional reservado para a Área-Meio 42 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.52` | Assunto adicional reservado para a Área-Meio 43 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.53` | Assunto adicional reservado para a Área-Meio 44 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.54` | Assunto adicional reservado para a Área-Meio 45 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.55` | Assunto adicional reservado para a Área-Meio 46 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.56` | Assunto adicional reservado para a Área-Meio 47 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.57` | Assunto adicional reservado para a Área-Meio 48 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.58` | Assunto adicional reservado para a Área-Meio 49 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.59` | Assunto adicional reservado para a Área-Meio 50 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.6` | Assunto adicional reservado para a Área-Meio 51 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.61` | Assunto adicional reservado para a Área-Meio 52 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.62` | Assunto adicional reservado para a Área-Meio 53 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.63` | Assunto adicional reservado para a Área-Meio 54 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.64` | Assunto adicional reservado para a Área-Meio 55 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.65` | Assunto adicional reservado para a Área-Meio 56 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.66` | Assunto adicional reservado para a Área-Meio 57 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.67` | Assunto adicional reservado para a Área-Meio 58 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.68` | Assunto adicional reservado para a Área-Meio 59 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.69` | Assunto adicional reservado para a Área-Meio 60 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.7` | Assunto adicional reservado para a Área-Meio 61 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.71` | Assunto adicional reservado para a Área-Meio 62 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.72` | Assunto adicional reservado para a Área-Meio 63 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.73` | Assunto adicional reservado para a Área-Meio 64 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.74` | Assunto adicional reservado para a Área-Meio 65 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.75` | Assunto adicional reservado para a Área-Meio 66 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.76` | Assunto adicional reservado para a Área-Meio 67 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.77` | Assunto adicional reservado para a Área-Meio 68 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.78` | Assunto adicional reservado para a Área-Meio 69 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.79` | Assunto adicional reservado para a Área-Meio 70 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.8` | Assunto adicional reservado para a Área-Meio 71 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.81` | Assunto adicional reservado para a Área-Meio 72 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.82` | Assunto adicional reservado para a Área-Meio 73 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.83` | Assunto adicional reservado para a Área-Meio 74 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.84` | Assunto adicional reservado para a Área-Meio 75 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.85` | Assunto adicional reservado para a Área-Meio 76 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.86` | Assunto adicional reservado para a Área-Meio 77 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.87` | Assunto adicional reservado para a Área-Meio 78 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.88` | Assunto adicional reservado para a Área-Meio 79 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.89` | Assunto adicional reservado para a Área-Meio 80 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.9` | Assunto adicional reservado para a Área-Meio 81 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.91` | Assunto adicional reservado para a Área-Meio 82 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.92` | Assunto adicional reservado para a Área-Meio 83 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.93` | Assunto adicional reservado para a Área-Meio 84 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.94` | Assunto adicional reservado para a Área-Meio 85 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.95` | Assunto adicional reservado para a Área-Meio 86 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.96` | Assunto adicional reservado para a Área-Meio 87 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.97` | Assunto adicional reservado para a Área-Meio 88 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.98` | Assunto adicional reservado para a Área-Meio 89 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `098.99` | Assunto adicional reservado para a Área-Meio 90 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.1` | Assunto adicional reservado para a Área-Meio 91 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.11` | Assunto adicional reservado para a Área-Meio 92 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.12` | Assunto adicional reservado para a Área-Meio 93 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.13` | Assunto adicional reservado para a Área-Meio 94 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.14` | Assunto adicional reservado para a Área-Meio 95 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.15` | Assunto adicional reservado para a Área-Meio 96 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.16` | Assunto adicional reservado para a Área-Meio 97 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.17` | Assunto adicional reservado para a Área-Meio 98 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.18` | Assunto adicional reservado para a Área-Meio 99 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.19` | Assunto adicional reservado para a Área-Meio 100 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.2` | Assunto adicional reservado para a Área-Meio 101 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.21` | Assunto adicional reservado para a Área-Meio 102 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.22` | Assunto adicional reservado para a Área-Meio 103 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.23` | Assunto adicional reservado para a Área-Meio 104 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.24` | Assunto adicional reservado para a Área-Meio 105 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.25` | Assunto adicional reservado para a Área-Meio 106 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.26` | Assunto adicional reservado para a Área-Meio 107 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.27` | Assunto adicional reservado para a Área-Meio 108 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.28` | Assunto adicional reservado para a Área-Meio 109 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.29` | Assunto adicional reservado para a Área-Meio 110 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.3` | Assunto adicional reservado para a Área-Meio 111 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.31` | Assunto adicional reservado para a Área-Meio 112 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.32` | Assunto adicional reservado para a Área-Meio 113 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.33` | Assunto adicional reservado para a Área-Meio 114 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.34` | Assunto adicional reservado para a Área-Meio 115 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.35` | Assunto adicional reservado para a Área-Meio 116 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.36` | Assunto adicional reservado para a Área-Meio 117 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.37` | Assunto adicional reservado para a Área-Meio 118 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.38` | Assunto adicional reservado para a Área-Meio 119 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.39` | Assunto adicional reservado para a Área-Meio 120 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.4` | Assunto adicional reservado para a Área-Meio 121 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.41` | Assunto adicional reservado para a Área-Meio 122 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.42` | Assunto adicional reservado para a Área-Meio 123 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.43` | Assunto adicional reservado para a Área-Meio 124 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.44` | Assunto adicional reservado para a Área-Meio 125 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.45` | Assunto adicional reservado para a Área-Meio 126 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.46` | Assunto adicional reservado para a Área-Meio 127 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.47` | Assunto adicional reservado para a Área-Meio 128 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.48` | Assunto adicional reservado para a Área-Meio 129 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.49` | Assunto adicional reservado para a Área-Meio 130 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.5` | Assunto adicional reservado para a Área-Meio 131 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.51` | Assunto adicional reservado para a Área-Meio 132 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.52` | Assunto adicional reservado para a Área-Meio 133 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.53` | Assunto adicional reservado para a Área-Meio 134 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.54` | Assunto adicional reservado para a Área-Meio 135 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.55` | Assunto adicional reservado para a Área-Meio 136 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.56` | Assunto adicional reservado para a Área-Meio 137 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.57` | Assunto adicional reservado para a Área-Meio 138 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.58` | Assunto adicional reservado para a Área-Meio 139 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.59` | Assunto adicional reservado para a Área-Meio 140 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.6` | Assunto adicional reservado para a Área-Meio 141 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.61` | Assunto adicional reservado para a Área-Meio 142 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.62` | Assunto adicional reservado para a Área-Meio 143 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.63` | Assunto adicional reservado para a Área-Meio 144 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.64` | Assunto adicional reservado para a Área-Meio 145 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.65` | Assunto adicional reservado para a Área-Meio 146 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.66` | Assunto adicional reservado para a Área-Meio 147 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.67` | Assunto adicional reservado para a Área-Meio 148 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.68` | Assunto adicional reservado para a Área-Meio 149 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.69` | Assunto adicional reservado para a Área-Meio 150 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.7` | Assunto adicional reservado para a Área-Meio 151 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.71` | Assunto adicional reservado para a Área-Meio 152 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.72` | Assunto adicional reservado para a Área-Meio 153 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.73` | Assunto adicional reservado para a Área-Meio 154 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.74` | Assunto adicional reservado para a Área-Meio 155 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.75` | Assunto adicional reservado para a Área-Meio 156 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.76` | Assunto adicional reservado para a Área-Meio 157 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.77` | Assunto adicional reservado para a Área-Meio 158 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.78` | Assunto adicional reservado para a Área-Meio 159 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.79` | Assunto adicional reservado para a Área-Meio 160 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.80` | Assunto adicional reservado para a Área-Meio 161 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.81` | Assunto adicional reservado para a Área-Meio 162 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.82` | Assunto adicional reservado para a Área-Meio 163 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.83` | Assunto adicional reservado para a Área-Meio 164 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.84` | Assunto adicional reservado para a Área-Meio 165 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.85` | Assunto adicional reservado para a Área-Meio 166 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.86` | Assunto adicional reservado para a Área-Meio 167 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.87` | Assunto adicional reservado para a Área-Meio 168 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.88` | Assunto adicional reservado para a Área-Meio 169 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.89` | Assunto adicional reservado para a Área-Meio 170 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.90` | Assunto adicional reservado para a Área-Meio 171 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.91` | Assunto adicional reservado para a Área-Meio 172 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.92` | Assunto adicional reservado para a Área-Meio 173 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.93` | Assunto adicional reservado para a Área-Meio 174 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.94` | Assunto adicional reservado para a Área-Meio 175 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.95` | Assunto adicional reservado para a Área-Meio 176 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.96` | Assunto adicional reservado para a Área-Meio 177 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.97` | Assunto adicional reservado para a Área-Meio 178 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.98` | Assunto adicional reservado para a Área-Meio 179 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99` | Assunto adicional reservado para a Área-Meio 180 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.a` | Assunto adicional reservado para a Área-Meio 181 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.b` | Assunto adicional reservado para a Área-Meio 182 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.c` | Assunto adicional reservado para a Área-Meio 183 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.d` | Assunto adicional reservado para a Área-Meio 184 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.e` | Assunto adicional reservado para a Área-Meio 185 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.f` | Assunto adicional reservado para a Área-Meio 186 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `099.99.g` | Assunto adicional reservado para a Área-Meio 187 | Não definido | — | sem correspondência comprovada | Pendente de análise manual |
| `050.2` | Verbas Fundo Nacional de Desenvolvimento da Educação (FNDE) | Não definido | — | sem correspondência comprovada | Pendente de análise manual |

## 6. Pendências de homologação

1. Validar os pares com descrições idênticas conferindo **notas explicativas completas** e mudança de classe/subclasse.
2. Resolver códigos repetidos com títulos genéricos, evitando inferir falsos desdobramentos e consolidações.
3. Analisar destinos ausentes e situações de código compartilhado com significado diferente.
4. Apurar temporalidade, destinação e condição de assunto estrutural **antes** de qualquer definição de migração.
5. Cruzar com dados reais de processos e relações Tipo × Assunto no SEI de Rondônia. Esses dados **não estão nos dois CSVs**, portanto não foi possível estimar o impacto real nesta etapa.
6. Homologar cada linha com parecer arquivístico, responsável, data e justificativa; nenhuma correspondência é definitiva apenas por automação.

## 7. Artefatos

- `de_para_2017_2024_completo.csv`: um ou mais destinos candidatos por assunto DE, com evidências, hierarquia, status e divergências.
- `de_para_2017_2024_candidatos.csv`: candidatos identificados (inclui observações completas das versões).
- `tabela_2017.csv` e `tabela_2024.csv`: fontes originais, preservadas localmente.

## 8. Etapa seguinte recomendada

A etapa prioritária é confrontar os assuntos **efetivamente utilizados no SEI** com este mapa, **sem modificar processos existentes**. A extração deve conter identificador do assunto, código, quantidade de processos relacionados e, se possível, distribuição por tipo de processo e órgão. Esse diagnóstico permite priorizar pareceres técnicos pelas situações de maior impacto.

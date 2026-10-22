# Pendências — 21/10/2026

Referência de desenvolvimento: `AGENTS.md`.

O fluxo principal do MVP está implementado e homologado. Não permanecem como pendências: autenticação SMTP real, manifestação/submissão, autorização entre usuário comum/admin/órgãos e homologação visual principal.

| Prioridade | Pendência | Evidência |
| --- | --- | --- |
| Média | Cores semânticas de avaliação | StatusTag usa azul-cinza para DESCONTINUAR e âmbar para EM_AVALIACAO; AGENTS.md pede verde e marrom. |

Texto/binário vazio no ODBC foi corrigido e verificado no SQL Server. Catálogo,
administração e nova distribuição reutilizam IndicadorCard. Esses itens não
permanecem como defeitos abertos.

Runner padrão do backend e os cinco apontamentos dos analisadores foram corrigidos.
`dart test` executa seis testes; `flutter test` executa treze; ambos os analisadores
estão sem apontamentos. CI mínimo preparado, ainda sem execução remota.
Resultados e limites do format check incremental em `docs/testes_ci.md`.

O botão de nova tentativa em Início/Tipos/Resumo e submissão agora abre o login
para HTTP 401 e limpa a pilha protegida. Quatro testes de navegação/repetição
passaram; falta homologar com sessão real. Outros erros mantêm a recarga.
O logout agora aceita sessão já encerrada e limpa o cookie. Os testes HTTP
cobrem saída sem sessão, cookie desconhecido/revogado, repetição e auditoria
de sessão válida; falta homologar o menu Sair no navegador.
## 1. Pendências de alta prioridade

| Prioridade | Pendência | Situação |
| --- | --- | --- |
| Alta | Instalação/publicação em banco descartável | Scripts e roteiros existem; falta executar e validar a sequência completa em banco novo. |
| Alta | Distribuição com duas sessões e carga 006 | Testes técnicos existem; falta cenário concorrente real com duas sessões administrativas e carga/procedure 006. |
| Alta | Implantação OpenShift | Dockerfiles e proxy estão versionados; build, implantação e smoke test no cluster ainda não foram executados. |

As referências atuais, inclusive a hierarquia de Assuntos, foram conferidas pelo responsável e estão corretas.

## 2. Qualidade técnica

| Prioridade | Pendência | Situação |
| --- | --- | --- |
| Alta | Autorização com sessões reais | Comum não deve consultar/gravar distribuição, administrar usuários ou acessar avaliações de outro órgão. Admin sem vínculo consulta resumo, mas não edita/submete avaliações. Testes HTTP da distribuição usam sessão/banco simulados. |
| Alta | Distribuição com duas sessões e carga 006 | Teste SQL passou em tabelas temporárias para conflitos, autorização, versão, rollback e auditoria. Conferir duas sessões reais, carga simultânea e permissões da credencial de produção. |
| Alta | Decisão do Tipo e submissão | Confirmar 008 instalada, manter/descontinuar, justificativas, Tipo sem vínculos, concorrência, órgão 0 e bloqueio após finalizar. |
| Alta | Instalação/publicação em banco descartável | 009, atualização de 002 e database/tests/publicacao_hierarquia.sql estão versionados. Instalação/migração com escrita ainda não executada. |
| Média | Interface, filtros e totais no navegador | Conferir seleção de Tipos entre páginas/filtros, checkbox do cabeçalho, limpar seleção e vínculo em lote preservando vínculos. Conferir também Home/Tipos, catálogo e administração. Testes do diálogo e integração SQL executados; inspeção visual da tela completa não executada. |
| Média | Cobertura automatizada e CI | Runner Dart e workflow mínimo preparados. Falta executar o CI remoto e ampliar cobertura dos fluxos completos. SQL permanece como executáveis separados, fora do CI. |

Comandos da funcionalidade: `dart test test/distribuicao_test.dart`,
`dart run test/distribuicao_sql.dart`, `flutter test` e
`flutter build web`. Analisadores agora sem apontamentos.
Detalhes em `docs/distribuicao_tipos.md`. Dados persistentes não foram alterados.
| Média | Runner de testes do backend | Adequar os testes ao runner padrão `dart test` com `package:test`, preservando integrações que precisem permanecer executáveis separadamente. |
| Média | CI | Criar pipeline mínima para análise, testes e build de backend/frontend, sem deploy automático. |
| Baixa | Avisos dos analisadores | Corrigir avisos conhecidos de dotenv, variável não utilizada e APIs Flutter obsoletas. |

O comportamento atual do `StatusTag` deve ser preservado. Não existe pendência de alteração de suas cores.

## 3. Produção

Proteção da `main` aplicada e conferida em 22/10/2026: PR, CI backend/frontend,
zero aprovações, branch atualizada e aplicação também a administradores.
Detalhes e configuração dev/produção em `docs/ambientes.md`.

A formalização operacional está em `docs/producao.md`.

Antes da disponibilização em produção, ainda é necessário:

- concluir a homologação da instalação em banco novo;
- concluir o teste concorrente da distribuição;
- implantar e validar no OpenShift;
- conferir as permissões SQL efetivas da credencial de produção;
- manter backend com uma única réplica enquanto sessões/códigos forem armazenados em memória.

## 4. Funcionalidades futuras dependentes de decisão

- Exportação/consolidação entre órgãos para comparação de decisões e divergências.
- Gestão de rodadas e aplicação da distribuição pela interface.
- Tipos de Documento × Assuntos.
- Reabertura de manifestação.
- Decisão final SETIC.
- Integração automática de alterações no SEI.
- Persistência compartilhada de sessões/códigos e múltiplas instâncias.
- Relatório de último acesso/quantidade de acessos.
- Política de correção/substituição de referências imutáveis.
- Referência oficial para códigos de grau de sigilo.

Registrar ambiente, data e resultado das homologações restantes. Não marcar um item como homologado apenas porque existe código, roteiro ou PR.

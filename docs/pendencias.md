# Pendências — 19/10/2026

Referência de desenvolvimento: `AGENTS.md`. Uma implementação ou compilação
bem-sucedida não comprova homologação em produção.

## 1. Defeitos confirmados

| Prioridade | Pendência | Evidência |
| --- | --- | --- |
| Média | Cores semânticas de avaliação | StatusTag usa azul-cinza para DESCONTINUAR e âmbar para EM_AVALIACAO; AGENTS.md pede verde e marrom. |
| Média | Runner de testes do backend | dart test falha por ausência de package:test. Os testes existentes são programas executados com dart run. |
| Baixa | Avisos dos analisadores | Backend: DotEnv.map reservado a testes. Frontend: idAssunto não usado e três usos obsoletos de DropdownButtonFormField.value. Sem avisos novos na distribuição. |

Texto/binário vazio no ODBC foi corrigido e verificado no SQL Server. Catálogo,
administração e nova distribuição reutilizam IndicadorCard. Esses itens não
permanecem como defeitos abertos.

## 2. Testes e homologações pendentes

| Prioridade | Pendência | Situação efetiva |
| --- | --- | --- |
| Alta | Autorização com sessões reais | Comum não deve consultar/gravar distribuição, administrar usuários ou acessar avaliações de outro órgão. Admin sem vínculo consulta resumo, mas não edita/submete avaliações. Testes HTTP da distribuição usam sessão/banco simulados. |
| Alta | Distribuição com duas sessões e carga 006 | Teste SQL passou em tabelas temporárias para conflitos, autorização, versão, rollback e auditoria. Conferir duas sessões reais, carga simultânea e permissões da credencial de produção. |
| Alta | Decisão do Tipo e submissão | Confirmar 008 instalada, manter/descontinuar, justificativas, Tipo sem vínculos, concorrência, órgão 0 e bloqueio após finalizar. |
| Alta | Instalação/publicação em banco descartável | 009, atualização de 002 e database/tests/publicacao_hierarquia.sql estão versionados. Instalação/migração com escrita ainda não executada. |
| Média | Interface, filtros e totais no navegador | Distribuição: 627 Tipos lidos, seleção múltipla, filtros combinados, mais de 50 resultados e telas estreitas. Conferir também Home/Tipos, catálogo e administração. Build Web e testes do diálogo passaram; inspeção visual não executada. |
| Média | Cobertura automatizada e CI | Quatro testes Flutter do editor passaram. Programas Dart de códigos, autenticação, Home e distribuição passaram. Não há CI nem cobertura completa dos fluxos. |

Comandos da funcionalidade: `dart run test/distribuicao_test.dart`,
`dart run test/distribuicao_sql_test.dart`, `flutter test --no-pub` e
`flutter build web --no-pub`. Analisadores executados com os avisos acima.
Detalhes em `docs/distribuicao_tipos.md`. Dados persistentes não foram alterados.

## 3. Ajustes de documentação e instalação

| Prioridade | Pendência | Situação efetiva |
| --- | --- | --- |
| Alta | Hierarquia na referência | Banco inspecionado tem assunto.id_assunto_pai, mas não ref_assunto.id_assunto_pai. Homologar 009/002 e preparar carga explícita dos pais. O script histórico usou o último ponto do código; não incorporar essa inferência à publicação. |
| Alta | Produção | Desativar DEV_AUTH_ENABLED, conferir HTTPS, origem, cookie Secure, SMTP e privilégios SQL mínimos, inclusive os da distribuição. Documentar backup/restauração e implantação. |
| Média | Documentação histórica restante | README/proxima_etapa/administracao ainda tratam partes da autenticação como futuras. inicio/interface/acesso_temporario têm descrições antigas de estados, propriedades e visualização. Instalação está documentada em docs/instalacao_banco.md, mas falta homologá-la. |

As criações de hipotese_legal e tipo_procedimento_restricao estão versionadas
em 009. A ausência dos scripts foi corrigida; carga e implantação são etapas
distintas da existência dos scripts.

## 4. Funcionalidades futuras dependentes de decisão

- Exportação/consolidação entre órgãos para comparar decisões e divergências:
  definir formato e escopo com o responsável.
- Referência dos códigos de grau de sigilo ainda não confirmados: não inferir
  significados. Nível de acesso e hipótese legal já possuem apresentação.
- Importação por interface, gestão de rodadas e aplicação da distribuição em
  rodadas pela interface. Edição da distribuição foi implementada; aplicação
  em rodadas continua sendo uma operação SQL separada e explícita.
- Tipos de Documento × Assuntos, reabertura, decisão final SETIC e integração
  de alterações no SEI: não implementados; não são defeitos do MVP atual.
- Sessões/códigos persistentes e múltiplas instâncias: desenho atual usa
  memória e uma instância. Só ampliar se houver requisito.
- Relatório de último acesso/quantidade de acessos. Eventos de autenticação
  já são auditados.
- Política de correção/substituição de referências imutáveis e de referências
  atuais sem versão própria, como hipótese legal e distribuição.

Registrar ambiente, data e resultado das homologações. Não marcar um item
como testado apenas porque existe roteiro, código ou PR.

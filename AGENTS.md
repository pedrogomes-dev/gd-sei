# GD-SEI — Instruções para agentes

## Objetivo

O GD-SEI é uma aplicação de apoio à Gestão Documental do SEI.

A aplicação permite consultar, avaliar e manifestar-se sobre:

- Tipos de Processo;
- Assuntos;
- vínculos Tipo de Processo × Assunto;
- atribuições de Tipos de Processo aos órgãos.

O sistema não altera diretamente o SEI.

## Stack

- Backend: Dart
- Frontend: Flutter Web
- Banco: Microsoft SQL Server
- Comunicação: HTTP/JSON
- Arquitetura: monolítica

Backend organizado preferencialmente em: routes, controllers, services, repositories e models.

Frontend deve permanecer simples, utilizando preferencialmente StatefulWidget, setState, FutureBuilder, componentes Flutter nativos e componentes compartilhados já existentes no projeto.

Não introduzir gerenciamento de estado, frameworks, bibliotecas ou camadas adicionais sem necessidade concreta.

## Princípios de desenvolvimento

### Simplicidade

Prioridade máxima. Antes de criar código novo:

1. procure implementação semelhante no projeto;
2. reutilize componentes e funções existentes;
3. prefira funções pequenas;
4. evite abstrações prematuras;
5. evite criar arquivos, classes ou camadas sem necessidade.

Não transformar uma solução simples em uma arquitetura genérica.

### Legibilidade

Evitar ternários aninhados, funções muito extensas, condicionais profundamente aninhadas, duplicação de regras e complexidade ciclomática desnecessária.

Prefira funções pequenas e semanticamente claras. Por exemplo, `DataCell(evaluationTag(row))` é preferível a construir toda a regra de estado dentro da árvore de widgets.

### Regras centralizadas

Regras de apresentação compartilhadas devem permanecer em componentes compartilhados. Cores e ícones de status pertencem ao `StatusTag`; telas devem determinar o estado semântico, não repetir regras de cores.

### Não inventar arquitetura

Antes de implementar uma alteração, examine o código existente, identifique os componentes relacionados, entenda o fluxo atual e proponha a menor alteração possível.

Se houver duas soluções equivalentes, priorize nesta ordem:

1. simplicidade;
2. segurança;
3. desempenho;
4. manutenção.

Para conjuntos pequenos de dados, não implementar otimizações prematuras.

## Banco de dados

Banco: SQL Server.

As tabelas de referência são tratadas como imutáveis. A aplicação trabalha sobre cópias/versionamento das referências.

Sempre respeitar `versao` nas consultas que relacionem dados versionados. Nunca relacionar registros de versões diferentes.

### Assuntos

A tabela `assunto` possui `id_assunto`, `codigo_estruturado` e `id_assunto_pai`.

`id_assunto_pai` representa a hierarquia explícita. Não inferir a hierarquia pelo tamanho do código.

Exemplos:

```text
085         -> raiz
085.6       -> filho de 085
085.61      -> filho de 085
085.61.a    -> filho de 085.61
085.611     -> filho de 085
085.611.a   -> filho de 085.611
```

Quando `id_assunto_pai` estiver disponível, ele é a fonte de verdade para navegação hierárquica.

## Interface

Manter consistência visual entre as telas. Antes de criar um componente visual, verificar se já existe equivalente.

Componentes importantes: `StatusTag`, `IndicadorCard`, `SectionCard` e `AppShell`.

Reutilizá-los sempre que adequado.

### Cards de estado

Usar o padrão visual da Home por meio de `IndicadorCard`. Evitar criar implementações paralelas de cards.

### Estados da avaliação

Na listagem de Tipos de Processo:

- Todos
- Pendentes
- Em avaliação
- Avaliados

Os três estados de trabalho são mutuamente exclusivos:

```text
Pendentes
  visualizado != 'S'

Em avaliação
  visualizado == 'S'
  e existem vínculos pendentes

Avaliados
  visualizado == 'S'
  e não existem vínculos pendentes
```

Consequentemente: `Pendentes + Em avaliação + Avaliados = Todos`.

### StatusTag

Estados semânticos relevantes:

- `AVALIADO`
- `DESCONTINUAR`
- `EM_AVALIACAO`
- `NAO_VISUALIZADO`

Representação desejada:

```text
Avaliação completa       -> verde + check
Descontinuação proposta  -> verde + X
Vínculos pendentes       -> marrom + indicador de pendência
Não visualizado          -> vermelho + indicador correspondente
```

Verde significa decisão/avaliação concluída. A diferença entre manutenção e proposta de descontinuação deve ser comunicada também pelo ícone, não apenas pela cor.

## Catálogos

Existem catálogos de Assuntos e Tipos de Processo.

### Expansão de vínculos

A interface permite expandir registros.

Tipo de Processo:

```text
Tipo
  ↳ Assunto
  ↳ Assunto
```

Assunto:

```text
Assunto
  ↳ Tipo de Processo
  ↳ Tipo de Processo
```

No sentido Assunto → Tipo, podem ser apresentadas também as siglas dos órgãos associados ao Tipo.

Como o conjunto possui poucas centenas de vínculos, priorizar carregamento simples em vez de endpoint por clique, cache complexo ou gerenciamento adicional de estado.

## Segurança

Nunca confiar em restrições apenas do frontend.

Autorizações de órgão devem ser validadas no backend. O fato de um usuário alterar parâmetros, IDs ou estado do frontend não pode permitir acesso indevido a outro órgão.

Usuários administradores podem possuir regras de acesso distintas, mas isso deve ser explícito no backend.

Usar queries parametrizadas. Não concatenar entrada do usuário diretamente em SQL.

## Alterações no código

Antes de editar:

1. leia os arquivos relacionados;
2. procure componentes e funções reutilizáveis;
3. identifique impactos no backend, frontend e banco;
4. escolha a solução de menor complexidade.

Durante a implementação:

- faça alterações pequenas;
- preserve o comportamento não relacionado;
- não faça refatorações amplas sem necessidade;
- não altere nomenclaturas ou regras fora do escopo.

## Testes obrigatórios

Uma tarefa não deve ser declarada concluída apenas porque o código parece correto.

Após alterações no backend Dart, executar quando aplicável:

```bash
dart format .
dart analyze
dart test
```

Após alterações no frontend:

```bash
dart format .
flutter analyze
flutter test
```

Se o projeto não possuir testes automatizados suficientes, ainda executar o analisador.

Corrigir erros introduzidos pela alteração antes de considerar a tarefa concluída.

Não afirmar que os testes passaram se não foram executados.

Diferenciar explicitamente revisão manual, análise estática, testes automatizados, teste integrado e teste manual.

## Git

Antes de iniciar:

```bash
git status
git branch --show-current
git fetch
```

Verificar o estado real da `main`.

Nunca assumir que uma branch ou PR continua aberto. Antes de afirmar qualquer estado do Git ou GitHub, verificar.

Criar nova branch a partir da `main` atualizada para cada alteração independente.

Evitar continuar adicionando commits a um PR que já foi mergeado.

Antes de abrir PR:

1. verificar o diff;
2. verificar arquivos alterados;
3. executar análise/testes;
4. confirmar que a branch está baseada na `main` correta.

Não incluir arquivos não relacionados.

## Pull Requests

O PR deve informar objetivamente problema, solução, arquivos/áreas alteradas, testes efetivamente executados e pendências conhecidas.

Não declarar `testado`, `validado` ou `análise estática concluída` sem que a respectiva verificação tenha sido realmente executada.

Se algo não puder ser executado, registrar explicitamente como pendente.

## Regra geral

Não implementar imediatamente uma solução complexa apenas porque ela é tecnicamente possível.

Primeiro pergunte:

> Existe uma maneira menor, mais clara e mais fácil de manter usando o que o projeto já possui?

Se existir, use-a.

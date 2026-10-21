# Pendências — 21/10/2026

Referência de desenvolvimento: `AGENTS.md`.

O fluxo principal do MVP está implementado e homologado. Não permanecem como pendências: autenticação SMTP real, manifestação/submissão, autorização entre usuário comum/admin/órgãos e homologação visual principal.

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
| Média | Runner de testes do backend | Adequar os testes ao runner padrão `dart test` com `package:test`, preservando integrações que precisem permanecer executáveis separadamente. |
| Média | CI | Criar pipeline mínima para análise, testes e build de backend/frontend, sem deploy automático. |
| Baixa | Avisos dos analisadores | Corrigir avisos conhecidos de dotenv, variável não utilizada e APIs Flutter obsoletas. |

O comportamento atual do `StatusTag` deve ser preservado. Não existe pendência de alteração de suas cores.

## 3. Produção

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

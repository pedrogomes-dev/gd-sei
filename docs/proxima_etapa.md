# Próximas etapas

## Estado atual

O MVP funcional está implementado e os principais fluxos de negócio já foram homologados:

- autenticação por e-mail via SMTP;
- manifestação e submissão;
- autorização entre usuário comum, administrador e órgãos;
- interface principal e fluxos visuais;
- administração de usuários;
- distribuição administrativa de Tipos;
- catálogo e propriedades;
- hipóteses legais e hierarquia explícita de Assuntos.

As referências atuais foram conferidas e estão corretas.

## Pendências imediatas

### Instalação completa em banco novo

Homologar a sequência completa de instalação em banco descartável:

`001 → 009 → 002 → carga/publicação → 004 → 005 → 006 → 007 → 008`.

A existência e revisão dos scripts não substituem essa homologação.

### Distribuição concorrente

Executar o teste com duas sessões administrativas reais e carga/procedure 006 concorrente. Os testes automatizados e temporários existentes permanecem válidos como cobertura técnica, mas não substituem o cenário concorrente real.

### OpenShift

A preparação de containers está versionada. A implantação efetiva no OpenShift ainda deve ser executada e validada, incluindo build, Secrets, Services, Route HTTPS, comunicação com SQL Server/SMTP e smoke test.

Enquanto códigos de acesso e sessões permanecerem em memória, o backend deve iniciar com uma única réplica.

## Qualidade técnica

Permanecem como atividades de engenharia:

- adequar o backend ao runner padrão `dart test`;
- criar CI mínimo;
- corrigir avisos restantes dos analisadores.

Essas atividades não alteram regras de negócio.

## Produção

A configuração operacional está formalizada em `docs/producao.md`, incluindo variáveis de ambiente, Secrets, HTTPS/cookies, permissões SQL, SMTP, OpenShift, backup/restauração e checklist de implantação.

## Fora do MVP atual

Dependem de decisão futura:

- exportação e consolidação entre órgãos;
- gestão completa de rodadas pela interface;
- aplicação da distribuição a rodadas pela interface;
- reabertura de manifestação;
- decisão final SETIC;
- integração automática com o SEI;
- Tipos de Documento × Assuntos;
- múltiplas instâncias do backend e persistência compartilhada de sessões/códigos;
- relatório consolidado de quantidade e último acesso;
- política de substituição/correção de referências imutáveis;
- referência dos códigos de grau de sigilo ainda não confirmados.

Não inferir significados para códigos sem referência oficial.

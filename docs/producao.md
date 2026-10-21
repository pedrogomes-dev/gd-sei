# Produção — GD-SEI

Este documento formaliza os requisitos mínimos para disponibilização do GD-SEI em produção. Não substitui os procedimentos corporativos de infraestrutura, banco de dados, segurança, backup ou mudança.

## 1. Premissas

- Backend Dart e frontend Flutter Web executados em containers separados.
- SQL Server externo ao cluster.
- Frontend publicado por HTTPS.
- API acessada pela mesma origem do frontend por meio do proxy reverso Nginx.
- SMTP institucional para envio dos códigos de acesso.
- Backend inicialmente com **uma única réplica**.
- O sistema não altera diretamente o SEI oficial.

A réplica única é obrigatória enquanto sessões e códigos de acesso permanecerem armazenados em memória. Reiniciar ou substituir o pod invalida sessões e códigos pendentes; o usuário deverá autenticar novamente.

## 2. Pendências que bloqueiam produção

Antes da disponibilização:

1. homologar a instalação completa em banco novo;
2. concluir o teste concorrente da distribuição com duas sessões administrativas e carga/procedure 006;
3. implantar backend/frontend no OpenShift e executar smoke test.

Esses itens não devem ser marcados como concluídos apenas pela existência dos scripts, Dockerfiles ou testes automatizados.

## 3. Variáveis de ambiente

### Aplicação

| Variável | Produção |
| --- | --- |
| `APP_ENV` | `production` |
| `DEV_AUTH_ENABLED` | `false` |
| `COOKIE_SECURE` | `true` |
| `HOST` | `0.0.0.0` |
| `PORT` | `8080` |
| `ALLOWED_ORIGIN` | URL HTTPS exata do frontend |

Não habilitar o acesso temporário fora de desenvolvimento.

### Banco

Configurar no backend:

- `DB_DRIVER`;
- `DB_HOST`;
- `DB_PORT`;
- `DB_NAME`;
- `DB_USER`;
- `DB_PASSWORD`;
- `DB_ENCRYPT=true`;
- `DB_TRUST_SERVER_CERTIFICATE=false`, salvo decisão formal da infraestrutura.

A imagem do backend instala o Microsoft ODBC Driver 18 para SQL Server. O build e a conexão real no OpenShift ainda precisam ser validados.

### SMTP

Configurar:

- `SMTP_HOST`;
- `SMTP_PORT`;
- `SMTP_USER`;
- `SMTP_PASSWORD`;
- `SMTP_FROM`;
- `SMTP_SSL`.

O fluxo SMTP real já foi homologado. Preservar TLS e validação de certificado. Não habilitar envio sem criptografia nem ignorar erro de certificado.

## 4. Secrets

Devem ser armazenados como Secret do OpenShift, nunca em Git, Dockerfile, ConfigMap público ou `--dart-define`:

- `DB_USER`;
- `DB_PASSWORD`;
- `SMTP_USER`, quando tratado como credencial;
- `SMTP_PASSWORD`.

Demais parâmetros operacionais podem ficar em ConfigMap quando não forem sigilosos.

O arquivo local `.env` é recurso de desenvolvimento e não deve ser incorporado à imagem nem utilizado como mecanismo de distribuição de segredos em produção.

## 5. HTTPS, origem e cookies

A Route pública deve expor somente o frontend por HTTPS.

O frontend encaminha `/api/` para o Service interno `gd-sei-backend:8080`. O backend deve receber `ALLOWED_ORIGIN` exatamente igual à origem pública do frontend.

Em produção:

```text
DEV_AUTH_ENABLED=false
COOKIE_SECURE=true
APP_ENV=production
```

A sessão utiliza cookie HttpOnly, Secure, SameSite=Lax e caminho `/api`.

Não publicar uma Route externa separada para o backend sem necessidade operacional aprovada.

## 6. OpenShift

### Backend

- Build context: `backend/`.
- Porta: 8080.
- Service interno: `gd-sei-backend`.
- Réplicas iniciais: **1**.
- Credenciais por Secret.
- Configurações não sigilosas por variáveis/ConfigMap.
- Não usar UID fixo; a imagem está preparada para UID arbitrário do OpenShift.

### Frontend

- Build context: `frontend/`.
- Porta: 8080.
- `API_BASE_URL` vazio no build de produção para usar `/api` na mesma origem.
- Route HTTPS apontando para o Service do frontend.

### Verificações mínimas no cluster

- pod backend inicia sem erro;
- pod frontend inicia sem erro;
- `GET /api/health` responde;
- frontend abre pela Route HTTPS;
- login por e-mail funciona;
- frontend alcança API pelo proxy;
- backend alcança SQL Server;
- backend alcança SMTP;
- cookie de sessão é criado como Secure;
- logout invalida a sessão;
- reinício do backend exige novo login, conforme desenho atual.

## 7. Permissões SQL

A credencial utilizada pela aplicação deve seguir privilégio mínimo.

Não conceder:

- `db_owner`;
- `sysadmin`;
- `CONTROL` no banco;
- `ALTER` genérico;
- `TRUNCATE`;
- permissão para executar a publicação das referências;
- UPDATE/DELETE nas tabelas `ref_*`;
- alteração direta dos snapshots versionados.

Conceder somente as leituras e escritas efetivamente necessárias ao backend e execução das procedures operacionais instaladas.

A distribuição administrativa exige, conforme o desenho atual, capacidade controlada de:

- consultar a distribuição;
- inserir/remover pares em `tipo_procedimento_restricao`;
- inserir eventos de auditoria;
- utilizar a trava de aplicação compartilhada com a carga 006.

A administração e manifestação devem preferir as procedures versionadas para gravação. As permissões efetivas da credencial de produção devem ser conferidas durante a homologação do banco e novamente antes da liberação.

## 8. Banco e referências

A instalação nova deve seguir `docs/instalacao_banco.md`.

Sequência:

```text
001 → 009 → 002 → carga/publicação → 004 → 005 → 006 → 007 → 008
```

As referências atuais foram conferidas e estão corretas. Em novas cargas:

- preservar IDs oficiais;
- carregar `id_assunto_pai` explicitamente;
- não inferir hierarquia por código;
- preservar a versão nas relações;
- não alterar referências imutáveis por atalhos administrativos.

## 9. Backup e restauração

### Antes da implantação ou migração

Executar backup do banco GD-SEI segundo o procedimento institucional do SQL Server e registrar:

- data/hora;
- banco;
- servidor;
- responsável;
- identificação do backup;
- local de armazenamento;
- resultado da verificação do backup.

Mudanças de esquema ou carga não devem ser iniciadas sem backup válido quando aplicável.

### Restauração

O procedimento de restauração deve ser testado em ambiente não produtivo antes da entrada em produção.

A validação deve confirmar:

- banco restaurado íntegro;
- objetos `001–009` esperados;
- referências e versões preservadas;
- usuários/órgãos/atribuições preservados;
- manifestações e auditorias preservadas;
- aplicação conectando ao banco restaurado.

Sessões e códigos de acesso não fazem parte do backup, pois são mantidos em memória.

## 10. Logs e diagnóstico

Em produção:

- não retornar detalhes internos de banco ao cliente;
- não registrar senha, token, código de acesso ou conteúdo de Secret;
- registrar falhas técnicas suficientes para diagnóstico no log do container;
- preservar auditoria funcional já existente no banco.

O endpoint `/api/health` pode ser utilizado para verificação básica de disponibilidade da API.

## 11. Checklist pré-produção

- [ ] Instalação completa homologada em banco novo.
- [ ] Teste concorrente da distribuição concluído.
- [ ] Imagens backend/frontend construídas no ambiente de destino.
- [ ] Driver ODBC validado no container backend.
- [ ] Secret de banco configurado.
- [ ] Secret SMTP configurado.
- [ ] `APP_ENV=production`.
- [ ] `DEV_AUTH_ENABLED=false`.
- [ ] `COOKIE_SECURE=true`.
- [ ] `ALLOWED_ORIGIN` igual à Route HTTPS.
- [ ] Credencial SQL com privilégios mínimos conferida.
- [ ] Backup válido realizado.
- [ ] Procedimento de restauração validado.
- [ ] Backend configurado com uma réplica.
- [ ] Service interno do backend criado.
- [ ] Service/Route HTTPS do frontend criados.
- [ ] Smoke test do cluster aprovado.

## 12. Checklist pós-implantação

- [ ] Home carrega normalmente.
- [ ] Login por e-mail recebe código e cria sessão.
- [ ] Usuário comum visualiza somente seu escopo.
- [ ] Administrador possui visão global, respeitando vínculo para avaliação/submissão.
- [ ] Catálogos carregam.
- [ ] Manifestação salva.
- [ ] Resumo carrega.
- [ ] Submissão funciona.
- [ ] Administração de usuários funciona.
- [ ] Distribuição administrativa abre e grava em cenário simples.
- [ ] Logout invalida a sessão.
- [ ] Logs não expõem credenciais ou códigos.
- [ ] Reinício controlado do backend apresenta o comportamento esperado de perda das sessões em memória.

## 13. Evolução futura

Múltiplas réplicas do backend exigirão persistência compartilhada de sessões e códigos de acesso ou outro mecanismo equivalente. Não adicionar Redis, sessão distribuída ou nova infraestrutura antes de existir esse requisito.

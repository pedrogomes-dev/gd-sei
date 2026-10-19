# Acesso por e-mail

O usuário informa seu e-mail cadastrado, recebe um código de seis dígitos e entra na aplicação. Somente usuários ativos recebem e-mail. A resposta da solicitação é a mesma para endereços cadastrados, inativos e desconhecidos.

## Regras

- Código entre 100000 e 999999 gerado com Random.secure().
- Validade de 10 minutos, cinco tentativas e uso único.
- Um novo pedido invalida o código anterior. Intervalo mínimo de 60 segundos entre pedidos para o mesmo e-mail.
- Armazenamento somente do HMAC-SHA256, com chave aleatória do processo. Código em texto permanece apenas durante o envio SMTP.
- Falha de envio cancela o código. O código só pode ser validado após o envio terminar com sucesso.
- Ao validar, o backend consulta novamente o usuário ativo e confere id_usuario e versao_sessao. Alteração de e-mail, perfil, vínculo ou situação invalida códigos e sessões anteriores, conforme a regra administrativa existente.
- Login por e-mail registra LOGIN em dbo.auditoria; acesso de teste continua registrando LOGIN_DEV. A sessão permanece com validade de oito horas e cookie HttpOnly, SameSite=Lax.
- Fora de desenvolvimento, COOKIE_SECURE deve ser true e a aplicação deve usar HTTPS.

Código e sessão ficam em memória. Usar uma única instância do backend. Reiniciar o serviço perde códigos e sessões, exigindo novo acesso. A limpeza dos códigos expirados ocorre nas solicitações e validações. Não há migração de banco.

O backend limita também 60 pedidos por minuto por IP direto, 20 envios simultâneos e 10000 entradas de controle. Esses limites incluem endereços desconhecidos. Atrás de um proxy, os clientes podem compartilhar esse limite de IP; não confiamos automaticamente em X-Forwarded-For.

## Configuração

Preencher apenas no backend/.env ou nas variáveis do servidor:

```env
SMTP_HOST=smtp.webmail.setic.ro.gov.br
SMTP_PORT=587
SMTP_USER=gd-sei@setic.ro.gov.br
SMTP_PASSWORD=
SMTP_FROM=gd-sei@setic.ro.gov.br
SMTP_SSL=false
```

A porta 587 ainda precisa ser confirmada. SMTP_SSL=false usa STARTTLS obrigatório. SMTP_SSL=true usa TLS direto, caso o servidor exija outra porta, normalmente 465. Não há opção para ignorar certificados ou permitir envio sem criptografia. SMTP_TLS, ACCESS_TOKEN_TTL_MINUTES e SESSION_TTL_HOURS eram campos sem implementação no exemplo anterior; o novo exemplo utiliza SMTP_SSL e os prazos fixos descritos acima.

Em produção:

```env
APP_ENV=production
DEV_AUTH_ENABLED=false
COOKIE_SECURE=true
```

Em desenvolvimento, preservar APP_ENV=development e DEV_AUTH_ENABLED=true para exibir o botão de acesso temporário do usuário de teste. O backend bloqueia esse acesso fora de desenvolvimento.

## Rotas

| Método e rota | Dados / retorno |
| --- | --- |
| GET /api/auth/config | Informa somente se o acesso temporário está habilitado. |
| POST /api/auth/codigo | Recebe email; responde com mensagem genérica, sem devolver código. |
| POST /api/auth/entrar | Recebe email e codigo; consome o código, audita o login e cria o cookie da sessão. |
| POST /api/auth/dev | Preserva o acesso temporário anterior, restrito ao desenvolvimento. |

As rotas POST mantêm a validação de Origin existente no servidor. ALLOWED_ORIGIN deve corresponder ao endereço do frontend.

## Verificação

O endereço raiz e rotas desconhecidas exibem o login. A tela provisória de
"Estrutura inicial" foi removida, inclusive sua consulta de health no frontend.

Em Início, Tipos atribuídos e Resumo e submissão, o botão **Tentar novamente**
abre o login quando a API responde HTTP 401. A navegação remove as telas
protegidas do histórico. Para outros erros, o botão repete o carregamento.
O frontend preserva o status HTTP em `ApiException`, sem comparar mensagens.
O teste `frontend/test/api_error_message_test.dart` cobre esses comportamentos
com navegação Flutter simulada; a homologação com sessão real continua pendente.

O endpoint de logout também aceita sessão ausente, desconhecida ou revogada:
limpa o cookie e retorna sucesso, permitindo que **Sair** abra o login. Sessões
válidas são invalidadas e continuam gerando LOGOUT na auditoria; repetir a
saída não duplica esse evento. Os testes HTTP de autenticação cobrem esses
casos com banco e SMTP simulados. As demais rotas continuam exigindo sessão.

No backend:

```sh
dart pub get
dart analyze
dart run test/codigos_acesso_test.dart
dart run test/autenticacao_email_test.dart
```

Os testes usam relógio controlado, banco e envio simulados; não acessam SQL Server nem enviam mensagens reais. Cobrem expiração, tentativas, reenvio, uso único, usuário ativo, alteração de permissões, auditoria, sessão e falha SMTP. Não foi possível executá-los neste ambiente, que não tem o SDK Dart/Flutter.

No frontend, executar flutter pub get, flutter analyze e flutter build web. Depois testar envio real com um usuário cadastrado, prazo de chegada, validade, reenvio, logout e revogação administrativa. Confirmar a porta e o certificado do SMTP. Não ativar o fluxo em produção antes dessa validação.

Dependências de apoio no backend: mailer para o SMTP e crypto para HMAC-SHA256. Referências: https://pub.dev/packages/mailer e https://pub.dev/packages/crypto.

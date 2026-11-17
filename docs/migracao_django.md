# Migração para Django — implementação e homologação

## Escopo

A branch `feat/migracao-django` substitui o runtime Dart/Flutter por Python 3.12,
Django 5.2 LTS e páginas renderizadas no servidor. O código anterior permanece
no histórico Git; não há dois backends ativos nem um frontend separado.
Não foi realizado merge ou deploy desta migração.

O trabalho usa a dev como origem e incorpora por fast-forward os commits mais
recentes já existentes na main. Alterações documentais locais do responsável
ficam fora dos commits da migração.

## Organização e decisões

- `config/`: settings, rotas e WSGI.
- `gdsei/views.py`: views de formulários/páginas, com POST/redirect/GET.
- `gdsei/autenticacao.py`: códigos, sessões e identificação/permissões.
- `gdsei/consultas.py`: avaliação, resumo, submissão e início.
- `gdsei/catalogo.py`: catálogos, propriedades e hierarquia explícita.
- `gdsei/administracao.py`: usuários, distribuição e pareceres SETIC.
- `gdsei/sql.py`: SQL existente portado, com parâmetros separados dos valores.
- `gdsei/db.py`: execução e tradução segura de erros de banco.
- `gdsei/templates/gdsei/componentes/` e `templatetags/componentes.py`: propriedades,
  etiquetas, pesquisa, paginação, progresso e parecer; `base.html` é o shell comum.
- `gdsei/static/gdsei/`: CSS, logo original e JavaScript nativo para interações.

Não há Django REST Framework, SPA, gerenciamento de estado, hierarquia de
repositories/services genéricos ou modelos artificiais para adaptar chaves
compostas ao ORM. O SQL existente é adequado ao esquema legado e às procedures.

## Regras preservadas

- Login por código de seis dígitos, uso único, validade de dez minutos, cinco
  tentativas, intervalo de reenvio e limite por IP. SMTP com TLS validado.
- Personificação somente de usuários ativos em desenvolvimento explícito;
  nunca pelo nome da branch. Órgãos e permissões reais do usuário são mantidos.
- Sessão expira em oito horas; ativo e `versao_sessao` são revalidados a cada
  requisição. CSRF obrigatório em POST; GET não altera dados.
- Autorização por órgão nas consultas e nas procedures, independentemente da tela.
  Admin sem vínculo pode consultar resumos, mas não manifestar/finalizar pelo órgão.
- Mesma versão nos relacionamentos existentes; hierarquia por `id_assunto_pai`.
  `sin_estrutural='S'` impede novas inclusões; propostas preexistentes preservadas.
- Manifestação/finalização e cadastro de usuários usam as procedures existentes,
  preservando revisão, concorrência e bloqueio depois da finalização.
- Distribuição individual permite incluir/remover; lote somente acrescenta,
  conserva vínculos e mantém contexto da versão e trava da carga existente.
- Parecer individual sobre Tipo e Assunto de manifestação finalizada. Qualquer
  recusa implica resultado parcial; conclusão exige todos os pareceres.
  Repetição do mesmo parecer é idempotente; edição/reabertura continua bloqueada.
- Catálogos, propriedades em modal, filtros, contadores e paginação renderizados
  em templates. A seleção em lote usa sessionStorage apenas para IDs; o servidor
  revalida tudo. Sem JavaScript funciona a seleção da página atual.
- Marcação de visualização ao escolher a decisão, com POST protegido; fallback
  ao salvar sem JavaScript. Barras de progresso em Tipos e Resumo.

## Banco e operação

Não foram executados INSERT/UPDATE/DELETE/DDL em tabelas persistentes. Não é
necessário novo script SQL para trocar o runtime. O esquema existente até 011
continua necessário. Não executar `manage.py migrate` no banco legado: não há
modelos gerenciados nem tabelas Django de usuários/sessões.

Sessões usam o backend de arquivos do Django, com cookie HttpOnly/SameSite=Lax.
`.runtime/sessions` deve ser privado ao processo e não servido por HTTP. Chave
`DJANGO_SECRET_KEY` própria e estável é obrigatória em produção. Login/códigos
ainda exigem **um processo/uma réplica**, como no legado: o controle de códigos
é em memória e protegido por lock. Persistência distribuída não foi adicionada.

O `.env` agora fica na raiz. A configuração local antiga foi copiada apenas se
não havia um arquivo novo, sem imprimir ou versionar credenciais. O arquivo de
exemplo tem apenas nomes de variáveis. Variáveis do ambiente prevalecem.

Produção: HTTPS, COOKIE_SECURE=true, DEV_AUTH_ENABLED=false e APP_ENV=production.
Terminação TLS/proxy requer configuração explícita conforme a infraestrutura;
não confiar automaticamente em headers encaminhados pelo cliente. Django
redireciona HTTP para HTTPS fora de desenvolvimento.

Waitress atende WSGI em um processo; WhiteNoise serve estáticos coletados. O
Dockerfile inclui Driver 18. Imagem/implantação em cluster ainda não executadas.
Para reverter a transição, usar um checkout/release anterior; não reverter banco,
pois a migração de runtime não mudou seu esquema nem seus registros.

## Dependências

Django fornece páginas, CSRF, templates, sessões e e-mail; mssql-django conecta ao
SQL Server por pyodbc; python-dotenv preserva a configuração .env; Waitress fornece
WSGI multiplataforma; WhiteNoise elimina servidor separado para estáticos.
Ruff é ferramenta de desenvolvimento para análise, formato e complexidade <=10.
Versões e transitivas ficam fixadas em requirements.lock; atualizar conscientemente.

## Verificações executadas

- `python -m pip check`: passou.
- `python -m ruff check gdsei config manage.py`: passou, incluindo complexidade.
- `python manage.py check`: sem apontamentos.
- `python manage.py test gdsei`: 36 testes passaram. Usam banco/sessões/SMTP
  simulados, sem criar banco temporário nem executar procedures reais.
- `python manage.py collectstatic --noinput`: passou.
- `node --check gdsei/static/gdsei/app.js`: passou (verifica sintaxe, não interação).
- `python manage.py check_database --pages`: integração de leitura passou no SQL
  Server: conexão/metadados, início, Tipos, dois catálogos, usuários, distribuição,
  processamento, detalhe de Tipo e resumo. O comando bloqueia SQL não SELECT/WITH.
  Não realiza login real, envio de e-mail ou gravação/auditoria no banco.

Os checks de CI conservam os nomes backend/frontend necessários à proteção das
branches. Não executam banco real nem deploy. Frontend executa testes de templates
e sintaxe JS; não usa Flutter e não equivale a navegador automatizado.

## Antes da substituição em produção

1. Homologar gravações/revisões/concorrência no SQL Server de testes e permissões
   da credencial (manifestação, finalização, usuários, distribuição e pareceres).
2. Homologar login SMTP, logout/revogação e personificação com sessões reais.
3. Conferir todas as telas no navegador, incluindo largura reduzida, seleção entre
   páginas/filtros, modais, confirmação de submissão e aviso de edição não salva.
4. Conferir rotas antigas/favoritos, integração externa eventualmente dependente
   da API anterior e necessidades de redirecionamento. A API antiga não foi mantida.
5. Executar Docker build, validar HTTPS/proxy, diretório de sessões e smoke test
   no ambiente de publicação. Sem alteração automática no SEI.

Essas homologações não estão aprovadas pelos testes simulados ou pelas consultas
de leitura. A migração permanece isolada na branch até revisão explícita.

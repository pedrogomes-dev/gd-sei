# Sistema de Validação de Tipos e Assuntos do SEI

Primeira etapa: backend Dart, frontend Flutter Web e base SQL versionada. Não altera o SEI oficial. Autenticação e manifestações ainda não implementadas; as telas são estruturas iniciais, sem acesso a dados.

## Organização

- `backend/lib`: config, routes, controllers, services, repositories e models.
- `frontend/lib`: screens e services; componentes Flutter padrão.
- `database`: instalação, publicação e roteiro de validação.
- `docs`: regras e próximas etapas.

## Executar

Instale Dart >=3.4 e Flutter estável compatível. No backend:

```bash
cd backend
dart pub get
dart analyze
dart run bin/server.dart
```

O processo lê variáveis do ambiente; `.env.example` é somente um modelo e não é carregado automaticamente. Configure pelo terminal ou serviço. Não versionar `.env`, senhas, certificados ou strings de conexão. Banco e SMTP estão reservados para a próxima etapa; ainda não existe driver SQL nem envio de e-mail.

Em outro terminal:

```bash
cd frontend
flutter pub get
flutter analyze
flutter run -d chrome --web-port 3000 --dart-define=API_BASE_URL=http://localhost:8080
```

`API_BASE_URL` é pública: nunca passar segredos com `--dart-define`. O backend aceita a origem exata definida em `ALLOWED_ORIGIN`. Em produção usar HTTPS e servir frontend/API na mesma origem por proxy.

## Banco

Crie um banco vazio no SQL Server 2016 SP1 ou posterior. Execute `database/001_base.sql` e `database/002_publicacao.sql`, nessa ordem, em ferramenta que interprete `GO`. Scripts de instalação não são migrações repetíveis. Carregue manualmente assuntos, tipos e vínculos nessa ordem e publique:

```sql
EXEC dbo.sp_publicar_versao_sei
 @usuario_carga=N'operador', @origem=N'Carga manual do SEI', @observacao=N'Carga inicial';
```

Primeira publicação = versão 0. Publicações seguintes preservam o histórico. A publicação bloqueia cargas simultâneas e é atômica. `versao_base` é inserida antes das cópias para satisfazer as chaves estrangeiras, na mesma transação.

Referências aceitam INSERT manual, mas UPDATE/DELETE são bloqueados. Não usar TRUNCATE: o operador de carga não deve ter ALTER nem privilégios de proprietário. Sem alteração/exclusão, os snapshots futuros representam a referência acumulada; substituição ou correção integral da fonte requer procedimento administrativo específico, fora desta etapa.

O usuário da aplicação não deve ter acesso às `ref_*`, executar publicação ou alterar snapshots. Consultas futuras devem usar a versão da consulta, nunca apenas `sin_ultima`. Permissões específicas serão adicionadas com as tabelas operacionais.

## Git

Repositório: https://github.com/pedrogomes-dev/gd-sei — branch `main`.

```bash
git clone https://github.com/pedrogomes-dev/gd-sei.git
cd gd-sei
```

## Validação

Veja `database/003_validacao.sql`. Compilação Dart/Flutter e execução SQL precisam ser feitas em ambiente com SDKs e SQL Server. Nenhuma dessas execuções foi realizada no ambiente de criação.

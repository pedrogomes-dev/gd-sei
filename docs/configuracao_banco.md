# Conexão SQL Server

O driver fica apenas no backend Dart; o navegador usa HTTP/JSON. Usamos `dart_odbc` 6.2.1 com Microsoft ODBC Driver 18 for SQL Server. Instale esse driver na máquina do backend; no Linux também instale unixODBC e disponibilize libodbc.so (em Debian/Ubuntu: unixodbc-dev).

Documentação: https://pub.dev/packages/dart_odbc e https://learn.microsoft.com/sql/connect/odbc/download-odbc-driver-for-sql-server

Execute na rede do banco, ou por VPN:

```bash
cd backend
cp .env.example .env
```

No Windows PowerShell use `Copy-Item .env.example .env`. Preencha DB_HOST, DB_NAME, DB_USER e DB_PASSWORD. A configuração local preparada na criação já contém host/banco/usuário informados; ela não é enviada ao GitHub. Preencha a senha na linha:

```dotenv
DB_PASSWORD="COLOQUE_A_SENHA_AQUI"
```

Use aspas para preservar uma senha com `#`. Não envie a senha por chat nem coloque no frontend. Variáveis do sistema têm precedência sobre `.env`. Execute sempre a partir de `backend`, onde o arquivo é carregado.

```bash
dart pub get
dart analyze
dart run bin/check_database.dart
```

O teste executa apenas `SELECT 1`; não instala tabelas e não modifica dados. Instalação dos scripts SQL é manual. `/api/health` continua verificando somente o processo HTTP, sem testar banco.

TLS fica ativo e a validação do certificado é obrigatória por padrão. Se conectar por IP, o certificado precisa validar esse endereço; preferir hostname que corresponda ao certificado. Não desativar validação automaticamente. Erros de driver são tratados sem imprimir strings de conexão ou credenciais.

A sessão deste ambiente não possui SDK Dart nem acesso configurado à rede interna. Conexão ainda não validada. Não considerar o banco instalado ou acessível até executar o teste no ambiente de destino.

## Parâmetros no Driver 18

O projeto usa uma cópia local do dart_odbc 6.2.1 com correção de ColumnSize em SQLBindParameter. Veja backend/vendor/dart_odbc/PATCH.md. Após atualizar: execute dart pub get e dart run bin/check_parameters.dart. O teste executa apenas SELECTs e verifica textos curtos, vazios, acentos, apóstrofos e inteiro. Nenhuma alteração de tabelas é necessária para esta correção.

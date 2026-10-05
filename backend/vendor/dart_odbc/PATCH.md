# Correção local para SQL Server ODBC Driver 18

Origem: https://github.com/SL-Pirate/dart_odbc
Versão 6.2.1, commit 190e5ab08ffc5f5a862b25a4c2de34a4d40c4d90.
Licença MIT original preservada em LICENSE.

Mudança restrita a lib/src/odbc_blocking/execute/execute.dart: SQLBindParameter recebia ColumnSize=0 para todos os parâmetros. O Driver 18 rejeitou a consulta parametrizada de login com HY104 (valor de precisão inválido). Agora texto usa tamanho em unidades UTF-16, mínimo 1 para vazio; inteiros usam 10, double 15, timestamp 26 e bool 1. Escala e buffers originais preservados. Não concatenar valores no SQL.

Copiado apenas código lib/, pubspec.yaml e LICENSE. Dependência local para manter a correção reproduzível em Git. Rever esta cópia quando o pacote publicar correção upstream. Não alterar o cache global do Dart.

Validação de integração: dart run bin/check_parameters.dart. Teste ainda deve ser executado na rede do banco; o ambiente de criação não possui SDK Dart/SQL Server.

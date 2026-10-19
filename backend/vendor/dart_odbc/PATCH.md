# Correção local para SQL Server ODBC Driver 18

Origem: https://github.com/SL-Pirate/dart_odbc
Versão 6.2.1, commit 190e5ab08ffc5f5a862b25a4c2de34a4d40c4d90.
Licença MIT original preservada em LICENSE.

Mudança restrita a lib/src/odbc_blocking/execute/execute.dart: SQLBindParameter recebia ColumnSize=0 para todos os parâmetros. O Driver 18 rejeitou a consulta parametrizada de login com HY104 (valor de precisão inválido). Agora texto usa tamanho em unidades UTF-16, mínimo 1 para vazio; inteiros usam 10, double 15, timestamp 26 e bool 1. Escala e buffers originais preservados. Não concatenar valores no SQL.

Copiado apenas código lib/, pubspec.yaml e LICENSE. Dependência local para manter a correção reproduzível em Git. Rever esta cópia quando o pacote publicar correção upstream. Não alterar o cache global do Dart.

Validação de integração: dart run bin/check_parameters.dart. Teste ainda deve ser executado na rede do banco; o ambiente de criação não possui SDK Dart/SQL Server.

## Patch 2 — tipos nativos no Windows x64

SQLLEN e SQLULEN eram definidos como ffi.Long/UnsignedLong, que têm 32 bits no Windows mesmo em processo x64. O ODBC x64 exige tipos de 64 bits. Definições alteradas para ffi.IntPtr/UintPtr; SQLSETPOSIROW também usa UintPtr. Lista de ponteiros de indicadores atualizada para Pointer<SQLLEN>. Correção abrange chamadas e buffers que utilizam esses typedefs, inclusive SQLBindParameter/SQLGetData.

Referência: https://learn.microsoft.com/en-us/sql/odbc/reference/odbc-64-bit-information

check_parameters imprime o marcador sei-odbc-2-pointer-width e valida os tamanhos antes dos SELECTs. Em Windows x64, ponteiro/SQLLEN/SQLULEN devem ter 8 bytes. A compilação falha se carregar a dependência original sem o marcador, evitando testar uma cópia antiga por engano.

## Suporte às manifestações

Textos acima de 4000 unidades UTF-16 usam SQL_WLONGVARCHAR (JSON de vínculos). Cursores com zero colunas retornam sem SQLFetch; erros de SQLFetch são propagados em vez de serem confundidos com fim dos dados. check_parameters inclui texto longo e caractere fora do BMP.

## Valores vazios

O leitor distingue NULL pelo indicador SQL_NULL_DATA, em vez de considerar
qualquer buffer vazio como NULL. Texto vazio retorna string vazia e binário
vazio retorna Uint8List vazia. check_parameters verifica esses casos e NULL
com SELECTs, sem modificar o banco.

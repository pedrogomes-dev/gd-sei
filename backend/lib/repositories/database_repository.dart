import 'dart:io';
import 'package:dart_odbc/dart_odbc.dart';
import '../config/database_config.dart';
import '../models/database_failure.dart';

class DatabaseRepository {
  final DatabaseConfig config;
  DatabaseRepository(this.config);

  DatabaseFailure failure(Object error,String stage) {
    String? state;
    int? code;
    // As versões do driver diferem em code/nativeError. Não registrar mensagens,
    // parâmetros SQL ou string de conexão, que podem conter credenciais.
    final dynamic detail=error;
    try { final value=detail.sqlState; if(value is String && RegExp(r'^[A-Z0-9]{5}$').hasMatch(value)) state=value; } catch(_) {}
    try { final value=detail.nativeError; if(value is int)code=value; } catch(_) {}
    if(code==null) { try { final value=detail.code; if(value is int)code=value; } catch(_) {} }
    return DatabaseFailure(stage:stage,kind:error.runtimeType.toString(),sqlState:state,code:code);
  }

  Future<List<Map<String, dynamic>>> query(String sql, {List<Object> params = const []}) async {
    DartOdbc? connection;
    var stage='inicializar_driver';
    var failed=false;
    try {
      final client=DartOdbc();
      connection=client;
      stage='conectar';
      await client.connectWithConnectionString(config.connectionString());
      stage='executar_consulta';
      return await client.execute(sql, params: params);
    } catch(error) {
      failed=true;
      throw failure(error,stage);
    } finally {
      final client=connection;
      if(client!=null) {
        try { await client.disconnect(); }
        catch(error) {
          final cleanup=failure(error,'desconectar');
          if(failed) { stderr.writeln(cleanup.diagnostic); }
          else { throw cleanup; }
        }
      }
    }
  }
}

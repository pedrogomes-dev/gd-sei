import 'dart:io';
import 'package:dart_odbc/dart_odbc.dart';
import '../config/database_config.dart';
import '../models/database_failure.dart';
import '../config/settings.dart';

class DatabaseRepository {
  final DatabaseConfig config;
  DatabaseRepository(this.config);

  DatabaseFailure failure(Object error,String stage,{String sql='', List<Object> params=const []}) {
    String? state;
    int? code;
    // As versões do driver diferem em code/nativeError. Não registrar mensagens,
    // parâmetros SQL ou string de conexão, que podem conter credenciais.
    final dynamic detail=error;
    try { final value=detail.sqlState; if(value is String && RegExp(r'^[A-Z0-9]{5}$').hasMatch(value)) state=value; } catch(_) {}
    try { final value=detail.nativeError; if(value is int)code=value; } catch(_) {}
    if(code==null) { try { final value=detail.code; if(value is int)code=value; } catch(_) {} }
    String? message;
    if(loadSettings()['APP_ENV']=='development') {
      message=error.toString();
      final secrets=[config.connectionString(),config.password,config.username,sql,
        ...params.whereType<String>().where((v)=>v.length>=4)];
      secrets.sort((a,b)=>b.length.compareTo(a.length));
      for(final value in secrets) {
        if(value.isNotEmpty)message=message!.replaceAll(value,'[removido]');
      }
      message=message!.replaceAll(RegExp(r'(?:PWD|PASSWORD|UID|USER ID|TOKEN)\s*=\s*(?:\{[^}]*\}|[^;\r\n]*)',caseSensitive:false),'[credencial removida]');
      message=message.replaceAll(RegExp(r'[\r\n]+'),' ');
      if(message.length>1500)message=message.substring(0,1500);
    }
    return DatabaseFailure(stage:stage,kind:error.runtimeType.toString(),sqlState:state,code:code,detail:message);
  }

  Future<List<Map<String, dynamic>>> query(String sql, {List<Object> params = const [], String operation = 'consulta'}) async {
    DartOdbc? connection;
    var stage='inicializar_driver';
    var failed=false;
    try {
      final client=DartOdbc();
      connection=client;
      stage='conectar';
      await client.connectWithConnectionString(config.connectionString());
      stage='executar_consulta/$operation';
      return await client.execute(sql, params: params);
    } catch(error) {
      failed=true;
      throw failure(error,stage,sql:sql,params:params);
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

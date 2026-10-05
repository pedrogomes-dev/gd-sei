class DatabaseFailure implements Exception {
  final String stage, kind;
  final String? detail;
  final String? sqlState;
  final int? code;
  DatabaseFailure({required this.stage,required this.kind,this.sqlState,this.code,this.detail});
  String get diagnostic {
    final hint=switch(code) {
      208=>'Tabela inexistente ou sem visibilidade. Verifique database/004_consultas.sql e DB_NAME.',
      229=>'Permissão SQL insuficiente para a operação.',
      18456=>'Falha de autenticação SQL Server.',
      4060=>'Banco indisponível para este usuário.',
      _=>'Verifique instalação das tabelas, permissões e driver.',
    };
    return 'Banco: etapa=$stage; tipo=$kind; SQLSTATE=${sqlState??"não informado"}; '
      'código=${code??"não informado"}. $hint${detail == null ? "" : " Detalhe: $detail"}';
  }
}

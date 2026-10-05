import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TiposScreen extends StatefulWidget {
  const TiposScreen({super.key});
  @override State<TiposScreen> createState()=>_TiposScreenState();
}
class _TiposScreenState extends State<TiposScreen> {
  late Future<List<dynamic>> future;
  @override void initState(){super.initState();future=ApiService().tipos();}
  Future<void> open(String id) async {
    await Navigator.pushNamed(context,'/tipos/$id');
    if(mounted)setState((){future=ApiService().tipos();});
  }
  Future<void> logout() async {
    try {
      await ApiService().logout();
      if(mounted)Navigator.pushNamedAndRemoveUntil(context,'/login',(_)=>false);
    } catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Tipos atribuídos aos seus órgãos'),actions:[
      TextButton(onPressed:logout,child:const Text('Sair'))]),
    body:FutureBuilder<List<dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[
        Text(snapshot.error.toString()),TextButton(onPressed:()=>Navigator.pushReplacementNamed(context,'/login'),child:const Text('Voltar ao login'))]));
      final rows=snapshot.data!;
      if(rows.isEmpty)return const Center(child:Text('Nenhum Tipo atribuído. Cadastre os vínculos no banco.'));
      return ListView(children:rows.map((r)=>Card(child:ListTile(
        title:Text(r['nome'].toString()),
        subtitle:Text('${r['sigla']} • ${r['consulta']} • ${r['status']}'),
        trailing:Text(r['visualizado']=='S'?'Visualizado':'Pendente de visualização'),
        onTap:()=>open(r['id_atribuicao'].toString()),))).toList());
    }));
}

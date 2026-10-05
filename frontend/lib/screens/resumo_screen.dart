import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ResumoScreen extends StatefulWidget {
  final String consulta,orgao;
  const ResumoScreen({super.key,required this.consulta,required this.orgao});
  @override State<ResumoScreen> createState()=>_ResumoScreenState();
}
class _ResumoScreenState extends State<ResumoScreen> {
  late Future<Map<String,dynamic>> future;
  bool busy=false;
  String? error;
  @override void initState(){super.initState();future=ApiService().summary(widget.consulta,widget.orgao);}
  void reload()=>setState((){error=null;future=ApiService().summary(widget.consulta,widget.orgao);});
  Future<void> finalize(Map<String,dynamic> data) async {
    final confirmed=await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Finalizar manifestação do órgão?'),
      content:const Text('A submissão abrangerá todos os Tipos desta consulta. Após finalizar, não será possível alterar ou reabrir.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Cancelar')),
        ElevatedButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Finalizar'))]));
    if(confirmed!=true||!mounted)return;
    setState((){busy=true;error=null;});
    try{
      final header=data['consulta_orgao'] as Map<String,dynamic>;
      await ApiService().finish(widget.consulta,widget.orgao,int.parse(header['revisao'].toString()));
      if(mounted)reload();
    }catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  Future<void> open(String id) async {
    await Navigator.pushNamed(context,'/tipos/$id');
    if(mounted)reload();
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Resumo da manifestação'),actions:[TextButton(onPressed:busy?null:reload,child:const Text('Atualizar'))]),
    body:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Text(snapshot.error.toString()));
      final data=snapshot.data!;final header=data['consulta_orgao'] as Map<String,dynamic>;
      final types=data['tipos'] as List<dynamic>;final decisions=data['decisoes'] as List<dynamic>;
      return ListView(padding:const EdgeInsets.all(24),children:[
        Text('${header['sigla']} — ${header['consulta']}',style:Theme.of(context).textTheme.headlineSmall),
        Text('Status: ${header['status']}'),
        if(header['data_finalizacao']!=null)Text('Finalização (UTC): ${header['data_finalizacao']}'),
        const Text('O resumo considera somente os preenchimentos salvos.'),
        ...types.map((t)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
          TextButton(onPressed:busy?null:()=>open(t['id_atribuicao'].toString()),child:Text(t['nome'].toString())),
          Text('Visualizado: ${t['visualizado']} • Vínculos sem decisão: ${t['pendentes']}'),
          if((t['observacao']??'').toString().isNotEmpty)Text('Observação: ${t['observacao']}'),
          ...decisions.where((d)=>d['id_atribuicao'].toString()==t['id_atribuicao'].toString()).map((d)=>ListTile(
            title:Text('${d['acao']}: ${d['codigo_estruturado']} — ${d['descricao']}'),
            subtitle:Text((d['justificativa']??'').toString()))),
        ])))),
        if(error!=null)Text(error!,style:TextStyle(color:Theme.of(context).colorScheme.error)),
        if(header['status']=='RASCUNHO')...[
          if(data['pode_finalizar']!=true)const Text('Para finalizar, visualize todos os Tipos e salve manter/remover em todos os vínculos existentes.'),
          ElevatedButton(onPressed:busy||data['pode_finalizar']!=true?null:()=>finalize(data),child:Text(busy?'Finalizando…':'Finalizar manifestação do órgão')),
        ],
      ]);
    }));
}

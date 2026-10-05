import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TipoScreen extends StatefulWidget {
  final String id;
  const TipoScreen({super.key,required this.id});
  @override State<TipoScreen> createState()=>_TipoScreenState();
}
class _TipoScreenState extends State<TipoScreen> {
  late Future<Map<String,dynamic>> future;
  String? error;
  bool busy=false,viewed=false;
  @override void initState(){super.initState();future=ApiService().tipo(widget.id);}
  Future<void> markViewed() async {
    setState((){busy=true;error=null;});
    try{await ApiService().visualizar(widget.id);if(mounted)setState((){viewed=true;});}
    catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Tipo de Processo')),
    body:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Text(snapshot.error.toString()));
      final data=snapshot.data!;
      final tipo=data['tipo'] as Map<String,dynamic>;
      final assuntos=data['assuntos'] as List<dynamic>;
      return ListView(padding:const EdgeInsets.all(24),children:[
        Text(tipo['nome'].toString(),style:Theme.of(context).textTheme.headlineSmall),
        ...tipo.entries.where((e)=>!['nome','id_atribuicao','id_consulta','id_orgao'].contains(e.key))
          .map((e)=>Text('${e.key}: ${e.value??'—'}')),
        const SizedBox(height:24),const Text('Assuntos atualmente vinculados'),
        if(assuntos.isEmpty)const Text('Nenhum Assunto vinculado.'),
        ...assuntos.map((a)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('${a['codigo_estruturado']} — ${a['descricao']}'),
          ...((a as Map<String,dynamic>).entries.where((e)=>!['codigo_estruturado','descricao'].contains(e.key)))
            .map((e)=>Text('${e.key}: ${e.value??'—'}')),
        ])))),
        const SizedBox(height:16),
        if(error!=null)Text(error!),
        ElevatedButton(onPressed:busy||viewed?null:markViewed,
          child:Text(viewed?'Visualização registrada':'Confirmar visualização deste Tipo')),
        const Text('Decisões sobre vínculos e submissão serão implementadas na próxima etapa.'),
      ]);
    }));
}

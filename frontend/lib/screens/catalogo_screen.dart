import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';

class CatalogoScreen extends StatefulWidget {
  final String kind;
  const CatalogoScreen({super.key,required this.kind});
  @override State<CatalogoScreen> createState()=>_CatalogoScreenState();
}
class _CatalogoScreenState extends State<CatalogoScreen> {
  final query=TextEditingController();
  int? version;
  @override void initState(){super.initState();search();}
  String searched='';
  int offset=0,generation=0;
  bool busy=false,more=false;
  List<dynamic> items=[];
  String? error;
  bool get subjects=>widget.kind=='assuntos';
  @override void dispose(){query.dispose();super.dispose();}
  Future<void> search({bool next=false,bool previous=false}) async {
    final request=++generation;
    final text=next||previous?searched:query.text.trim();final page=previous?offset-50:next?offset+50:0;
    setState((){busy=true;error=null;});
    try {
      final result=await ApiService().catalog(widget.kind,text,page,version:next||previous?version:null);
      if(mounted&&request==generation)setState((){items=result['itens'] as List<dynamic>;more=result['mais']==true;offset=page;searched=text;version=int.parse(result['versao'].toString());});
    }catch(e){if(mounted&&request==generation)setState((){error=e.toString();});}
    finally{if(mounted&&request==generation)setState((){busy=false;});}
  }
  void properties(Map<String,dynamic> row)=>showDialog<void>(context:context,builder:(context)=>AlertDialog(
    title:Text(subjects?'Propriedades do Assunto':'Propriedades do Tipo de Processo'),
    content:SizedBox(width:600,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:row.entries.where((e)=>!['versao','sin_ultima'].contains(e.key)).map(propertyTile).toList()))),
    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Fechar'))]));
  @override Widget build(BuildContext context)=>AppShell(title:subjects?'Catálogo de Assuntos':'Catálogo de Tipos de Processo',
    section:subjects?'assuntos':'catalogo-tipos',trail:['Catálogo',subjects?'Assuntos':'Tipos de Processo'],
    child:ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        const Text('Catálogo único da base publicada, incluindo registros ativos e inativos.',style:TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:12),Text(version==null?'':'Versão da base: $version',style:const TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:24),SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          TextField(controller:query,maxLength:250,
            decoration:InputDecoration(labelText:subjects?'Buscar por ID, código ou descrição':'Buscar por ID, nome ou descrição',prefixIcon:const Icon(Icons.search)),
            onSubmitted:(_){if(!busy)search();}),
          const SizedBox(height:8),FilledButton.icon(onPressed:busy?null:()=>search(),icon:const Icon(Icons.search),label:const Text('Pesquisar')),
        ])),
        if(error!=null)Padding(padding:const EdgeInsets.only(bottom:20),child:Text(error!)),
        if(busy)const LinearProgressIndicator(),
        if(version!=null&&!busy)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          if(items.isEmpty)const Text('Nenhum registro encontrado.')
          else SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(dataRowMinHeight:64,dataRowMaxHeight:88,columnSpacing:24,
            columns:[const DataColumn(label:Text('ID')),if(subjects)const DataColumn(label:Text('Código')),const DataColumn(label:Text('Descrição')),const DataColumn(label:Text('Estado')),const DataColumn(label:Text(''))],
            rows:items.map((row)=>DataRow(cells:[
              DataCell(Text(row[subjects?'id_assunto':'id_tipo_procedimento'].toString())),
              if(subjects)DataCell(Text((row['codigo_estruturado']??'—').toString())),
              DataCell(SizedBox(width:420,child:Text((row[subjects?'descricao':'nome']??'—').toString(),maxLines:3,overflow:TextOverflow.ellipsis))),
              DataCell(row['sin_ativo']=='S'?const StatusTag('ATIVO'):row['sin_ativo']=='N'?const StatusTag('INATIVO'):StatusTag('PENDENTE',label:'Estado não informado')),
              DataCell(TextButton(onPressed:()=>properties(Map<String,dynamic>.from(row as Map)),child:const Text('Propriedades'))),
            ])).toList())),
          const SizedBox(height:16),Row(children:[Text('Página ${offset~/50+1}'),const Spacer(),
            if(offset>0)TextButton(onPressed:()=>search(previous:true),child:const Text('Anterior')),
            if(more)TextButton(onPressed:()=>search(next:true),child:const Text('Próxima'))]),
        ])),
      ]));
}

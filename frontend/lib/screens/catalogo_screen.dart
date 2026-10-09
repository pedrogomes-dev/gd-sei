import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';
import '../widgets/propriedades_assunto.dart';

class CatalogoScreen extends StatefulWidget {
  final String kind;
  const CatalogoScreen({super.key,required this.kind});
  @override State<CatalogoScreen> createState()=>_CatalogoScreenState();
}
class _CatalogoScreenState extends State<CatalogoScreen> {
  final query=TextEditingController();
  int? version;
  @override void initState(){super.initState();search();}
  String searched='',state='TODOS';
  int total=0;
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
      final result=await ApiService().catalog(widget.kind,text,page,version:next||previous?version:null,state:state);
      if(mounted&&request==generation)setState((){items=result['itens'] as List<dynamic>;total=int.parse(result['total'].toString());more=result['mais']==true;offset=page;searched=text;version=int.parse(result['versao'].toString());});
    }catch(e){if(mounted&&request==generation)setState((){error=e.toString();});}
    finally{if(mounted&&request==generation)setState((){busy=false;});}
  }
  void properties(Map<String, dynamic> row) {
    showDialog<void>(
      context: context,
      builder: (context) => SelectionArea(
        child: AlertDialog(
          title: Text(subjects ? 'Propriedades do Assunto' : 'Propriedades do Tipo de Processo'),
          content: SizedBox(
            width: subjects ? 760 : 600,
            child: SingleChildScrollView(
              child: subjects
                  ? PropriedadesAssunto(assunto: row)
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: row.entries.where((campo) => !['versao', 'sin_ultima'].contains(campo.key)).map(propertyTile).toList(),
                    ),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
        ),
      ),
    );
  }
  Widget resultTable() {
    Widget cell(Widget child)=>Padding(padding:const EdgeInsets.symmetric(horizontal:12,vertical:16),child:child);
    final descriptionColumn=subjects?3:2;
    return Table(
      columnWidths:{
        0:const FixedColumnWidth(48),
        1:const FixedColumnWidth(120),
        if(subjects)2:const FixedColumnWidth(100),
        descriptionColumn:const FlexColumnWidth(),
        descriptionColumn+1:const FixedColumnWidth(120),
      },
      defaultVerticalAlignment:TableCellVerticalAlignment.middle,
      border:const TableBorder(horizontalInside:BorderSide(color:Color(0xffe2e8f0))),
      children:[
        TableRow(decoration:const BoxDecoration(color:Color(0xfff5f7fa)),children:[
          const SizedBox.shrink(),cell(const Text('ID')),if(subjects)cell(const Text('Código')),
          cell(const Text('Descrição')),cell(const Text('Estado')),
        ]),
        ...items.map((row)=>TableRow(children:[
          IconButton(tooltip:'Propriedades',icon:const Icon(Icons.info_outline),onPressed:()=>properties(Map<String,dynamic>.from(row as Map))),
          cell(Text(row[subjects?'id_assunto':'id_tipo_procedimento'].toString())),
          if(subjects)cell(Text((row['codigo_estruturado']??'—').toString())),
          cell(Text((row[subjects?'descricao':'nome']??'—').toString())),
          cell(Align(alignment:Alignment.centerLeft,child:row['sin_ativo']=='S'?const StatusTag('ATIVO'):row['sin_ativo']=='N'?const StatusTag('INATIVO'):const StatusTag('PENDENTE',label:'Não informado'))),
        ])),
      ]);
  }
  @override Widget build(BuildContext context)=>AppShell(title:subjects?'Catálogo de Assuntos':'Catálogo de Tipos de Processo',
    section:subjects?'assuntos':'catalogo-tipos',trail:[subjects?'Assuntos':'Tipos de Processo'],
    child:ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        const Text('Catálogo único da base publicada, incluindo registros ativos e inativos.',style:TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:12),Text(version==null?'':'Versão da base: $version',style:const TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:24),SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          TextField(controller:query,maxLength:250,
            decoration:InputDecoration(labelText:subjects?'Buscar por ID, código ou descrição':'Buscar por ID, nome ou descrição',prefixIcon:const Icon(Icons.search)),
            onSubmitted:(_){if(!busy)search();}),
          const SizedBox(height:16),Wrap(spacing:8,runSpacing:8,children:[
            for(final option in const {'TODOS':'Todos','S':'Ativos','N':'Inativos'}.entries)
              ChoiceChip(label:Text(option.value),selected:state==option.key,
                onSelected:busy?null:(_){setState((){state=option.key;});search();}),
          ]),
          const SizedBox(height:16),FilledButton.icon(onPressed:busy?null:()=>search(),icon:const Icon(Icons.search),label:const Text('Pesquisar')),
        ])),
        if(error!=null)Padding(padding:const EdgeInsets.only(bottom:20),child:Text(error!)),
        if(busy)const LinearProgressIndicator(),
        if(version!=null&&!busy)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('$total registros encontrados',style:const TextStyle(fontWeight:FontWeight.w600)),
          const SizedBox(height:16),
          if(items.isEmpty)const Text('Nenhum registro encontrado.')
          else LayoutBuilder(builder:(context,constraints){
            final minWidth=subjects?720.0:620.0;
            final width=constraints.maxWidth<minWidth?minWidth:constraints.maxWidth;
            return SingleChildScrollView(scrollDirection:Axis.horizontal,child:SizedBox(width:width,child:resultTable()));
          }),
          const SizedBox(height:16),Row(children:[Text('Página ${offset~/50+1} · Exibindo ${items.isEmpty?0:offset+1}–${offset+items.length} de $total'),const Spacer(),
            if(offset>0)TextButton(onPressed:()=>search(previous:true),child:const Text('Anterior')),
            if(more)TextButton(onPressed:()=>search(next:true),child:const Text('Próxima'))]),
        ])),
      ]));
}


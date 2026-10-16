import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/display_fields.dart';
import '../widgets/app_shell.dart';
import '../widgets/inicio/indicador_card.dart';

class TiposScreen extends StatefulWidget {
  final bool summaries;
  const TiposScreen({super.key,this.summaries=false});
  @override State<TiposScreen> createState()=>_TiposScreenState();
}
class _TiposScreenState extends State<TiposScreen> {
  late Future<List<dynamic>> future;
  String searchText='',filter='TODOS',organ='TODOS';
  int pending(dynamic row)=>int.parse(row['pendentes'].toString());
  @override void initState(){super.initState();future=ApiService().tipos();}
  void refresh()=>setState((){future=ApiService().tipos();});
  Future<void> open(String path) async {
    await Navigator.pushNamed(context,path);
    if(mounted)refresh();
  }
  bool matchesFilter(dynamic r,String option)=>switch(option){
    'PENDENTES'=>r['visualizado']!='S',
    'EM_AVALIACAO'=>r['visualizado']=='S'&&pending(r)>0,
    'AVALIADOS'=>r['visualizado']=='S'&&pending(r)==0,
    _=>true,
  };

  Widget filterCards(List<dynamic> rows) {
    final options=[
      ('TODOS','Todos',Icons.list_alt,Colors.blue.shade800),
      ('PENDENTES','Pendentes',Icons.pending_actions,Colors.red.shade800),
      ('EM_AVALIACAO','Em avaliação',Icons.edit_outlined,const Color(0xff9a4300)),
      ('AVALIADOS','Avaliados',Icons.fact_check_outlined,Colors.green.shade800),
    ];
    return LayoutBuilder(builder:(context,size){
      final columns=size.maxWidth>=900?4:size.maxWidth>=600?2:1;
      final width=(size.maxWidth-(columns-1)*16)/columns;
      return Wrap(
        spacing:16,runSpacing:16,
        children:[
          for(final option in options)
            SizedBox(
              width:width,
              child:IndicadorCard(
                titulo:option.$2,
                selecionado:filter==option.$1,
                quantidade:rows.where((r)=>matchesFilter(r,option.$1)).length,
                icone:option.$3,
                cor:option.$4,
                aoSelecionar:()=>setState((){
                  filter=filter==option.$1?'TODOS':option.$1;
                }),
              ),
            ),
        ],
      );
    });
  }

  @override Widget build(BuildContext context)=>AppShell(
    title:widget.summaries?'Resumo e submissão':'Tipos de Processo atribuídos',
    section:widget.summaries?'resumos':'tipos',trail:[widget.summaries?'Resumo e submissão':'Tipos de Processo atribuídos'],
    actions:[IconButton(onPressed:refresh,tooltip:'Atualizar',icon:const Icon(Icons.refresh))],
    child:FutureBuilder<List<dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(snapshot.error.toString()),TextButton(onPressed:refresh,child:const Text('Tentar novamente'))]));
      final rows=snapshot.data!;
      if(rows.isEmpty)return const Center(child:Text('Nenhum Tipo de Processo atribuído aos seus órgãos.'));
      final organs=<String,String>{for(final r in rows)r['id_orgao'].toString():r['sigla'].toString()};
      final scoped=rows.where((r)=>organ=='TODOS'||r['id_orgao'].toString()==organ).toList();
      final groups=<String,dynamic>{for(final r in scoped)'${r['id_consulta']}/${r['id_orgao']}':r};
      final visible=scoped.where((r){
        if(!'${r['nome']} ${r['id_tipo_procedimento']} ${r['sigla']} ${r['consulta']}'.toLowerCase().contains(searchText.trim().toLowerCase()))return false;
        return matchesFilter(r,filter);
      }).toList();
      return ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        const Text('Revise os Tipos de Processo e seus vínculos. A manifestação é compartilhada pelo órgão.',style:TextStyle(color:Colors.blueGrey)),
        const SizedBox(height:24),
        if(organs.length>1)Padding(padding:const EdgeInsets.only(bottom:24),child:DropdownButtonFormField<String>(
          value:organ,decoration:const InputDecoration(labelText:'Órgão'),
          items:[const DropdownMenuItem(value:'TODOS',child:Text('Todos os meus órgãos')),...organs.entries.map((e)=>DropdownMenuItem(value:e.key,child:Text(e.value)))],
          onChanged:(v)=>setState((){organ=v!;}))),
        ...groups.values.map((g){
          final items=scoped.where((r)=>r['id_consulta']==g['id_consulta']&&r['id_orgao']==g['id_orgao']).toList();
          final viewed=items.where((r)=>r['visualizado']=='S').length;
          final reviewed=items.where((r)=>r['visualizado']=='S'&&pending(r)==0).length;
          final finalized=g['status']=='FINALIZADA';
          return SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Row(children:[Expanded(child:Text(g['sigla'].toString(),style:Theme.of(context).textTheme.titleLarge)),StatusTag(g['status'].toString())]),
            const SizedBox(height:12),Text(g['consulta'].toString()),const SizedBox(height:20),
            Text('$viewed de ${items.length} Tipos de Processo visualizados · $reviewed de ${items.length} avaliados'),
            const SizedBox(height:10),LinearProgressIndicator(value:reviewed/items.length,minHeight:6,borderRadius:BorderRadius.circular(4)),
            const SizedBox(height:20),Align(alignment:Alignment.centerRight,child:OutlinedButton.icon(icon:Icon(finalized?Icons.assignment_outlined:Icons.send_outlined),
              onPressed:()=>open('/resumo?consulta=${g['id_consulta']}&orgao=${g['id_orgao']}'),
              label:Text(finalized?'Consultar resumo':'Resumo e submissão'))),
          ]));
        }),
        if(!widget.summaries)...[
          SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            TextField(decoration:const InputDecoration(labelText:'Buscar por nome ou ID do Tipo de Processo',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState((){searchText=v;})),
            const SizedBox(height:16),filterCards(scoped),
            const SizedBox(height:20),Text('${visible.length} de ${scoped.length} Tipos de Processo',style:const TextStyle(color:Colors.blueGrey)),
            const SizedBox(height:12),
            if(visible.isEmpty)const Text('Nenhum Tipo de Processo corresponde à busca e ao filtro.')
            else LayoutBuilder(builder:(context,constraints){
              const minWidth=900.0;
              final width=constraints.maxWidth<minWidth?minWidth:constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection:Axis.horizontal,
                child:SizedBox(width:width,child:DataTable(
                  headingRowColor:const WidgetStatePropertyAll(Color(0xfff5f7fa)),
                  dataRowMinHeight:68,dataRowMaxHeight:96,columnSpacing:24,
                  columns:const [
                    DataColumn(label:Text('ID')),
                    DataColumn(label:Text('Tipo de Processo')),
                    DataColumn(label:Text('Órgão')),
                    DataColumn(label:Text('Avaliação')),
                    DataColumn(label:Text('')),
                  ],
                  rows:visible.map((r)=>DataRow(cells:[
                    DataCell(Text(r['id_tipo_procedimento'].toString())),
                    DataCell(SizedBox(
                      width:constraints.maxWidth>=1100?520:400,
                      child:Text(r['nome'].toString(),maxLines:3,overflow:TextOverflow.ellipsis),
                    )),
                    DataCell(Text(r['sigla'].toString())),
                    DataCell(r['status']=='FINALIZADA'
                      ?const StatusTag('FINALIZADA')
                      :StatusTag(
                        r['visualizado']=='S'&&pending(r)==0?'MANTER':'PENDENTE',
                        label:r['visualizado']!='S'
                          ?'Não visualizado'
                          :r['decisao_tipo']==null
                            ?'Decisão sobre o Tipo pendente'
                            :r['decisao_tipo']=='DESCONTINUAR'
                              ?'Descontinuação proposta'
                              :pending(r)==0
                                ?'Revisão completa'
                                :'${pending(r)} vínculos pendentes',
                      )),
                    DataCell(Align(
                      alignment:Alignment.centerRight,
                      child:OutlinedButton(
                        onPressed:()=>open('/tipos/${r['id_atribuicao']}'),
                        child:const Text('Abrir'),
                      ),
                    )),
                  ])).toList(),
                )),
              );
            }),
          ])),
        ],
      ]);
    }));
}

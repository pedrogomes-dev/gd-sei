import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/display_fields.dart';
import '../widgets/app_shell.dart';

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
  @override Widget build(BuildContext context)=>AppShell(
    title:widget.summaries?'Resumo e submissão':'Meus Tipos',
    section:widget.summaries?'resumos':'tipos',trail:[widget.summaries?'Resumo e submissão':'Meus Tipos'],
    actions:[IconButton(onPressed:refresh,tooltip:'Atualizar',icon:const Icon(Icons.refresh))],
    child:FutureBuilder<List<dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Text(snapshot.error.toString()),TextButton(onPressed:refresh,child:const Text('Tentar novamente'))]));
      final rows=snapshot.data!;
      if(rows.isEmpty)return const Center(child:Text('Nenhum Tipo atribuído aos seus órgãos.'));
      final organs=<String,String>{for(final r in rows)r['id_orgao'].toString():r['sigla'].toString()};
      final scoped=rows.where((r)=>organ=='TODOS'||r['id_orgao'].toString()==organ).toList();
      final groups=<String,dynamic>{for(final r in scoped)'${r['id_consulta']}/${r['id_orgao']}':r};
      final visible=scoped.where((r){
        if(!'${r['nome']} ${r['id_tipo_procedimento']} ${r['sigla']} ${r['consulta']}'.toLowerCase().contains(searchText.trim().toLowerCase()))return false;
        return switch(filter){
          'PENDENTES'=>r['status']=='RASCUNHO'&&(r['visualizado']!='S'||pending(r)>0),
          'VISUALIZADOS'=>r['visualizado']=='S',
          'FINALIZADAS'=>r['status']=='FINALIZADA',_=>true};
      }).toList();
      return ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        const Text('Revise os Tipos e seus vínculos. A manifestação é compartilhada pelo órgão.',style:TextStyle(color:Colors.blueGrey)),
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
            Wrap(spacing:16,runSpacing:12,crossAxisAlignment:WrapCrossAlignment.center,children:[
              Text(g['sigla'].toString(),style:Theme.of(context).textTheme.titleLarge),StatusTag(g['status'].toString())]),
            const SizedBox(height:12),Text(g['consulta'].toString()),const SizedBox(height:20),
            Text('$viewed de ${items.length} Tipos visualizados · $reviewed de ${items.length} revisados'),
            const SizedBox(height:10),LinearProgressIndicator(value:reviewed/items.length,minHeight:6,borderRadius:BorderRadius.circular(4)),
            const SizedBox(height:20),OutlinedButton.icon(icon:Icon(finalized?Icons.assignment_outlined:Icons.send_outlined),
              onPressed:()=>open('/resumo?consulta=${g['id_consulta']}&orgao=${g['id_orgao']}'),
              label:Text(finalized?'Consultar resumo':'Resumo e submissão')),
          ]));
        }),
        if(!widget.summaries)...[
          SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            TextField(decoration:const InputDecoration(labelText:'Buscar por nome ou ID do Tipo',prefixIcon:Icon(Icons.search)),onChanged:(v)=>setState((){searchText=v;})),
            const SizedBox(height:16),Wrap(spacing:8,runSpacing:8,children:[
              for(final option in const {'TODOS':'Todos','PENDENTES':'Pendentes','VISUALIZADOS':'Visualizados','FINALIZADAS':'Finalizadas'}.entries)
                ChoiceChip(label:Text(option.value),selected:filter==option.key,onSelected:(_)=>setState((){filter=option.key;}))]),
            const SizedBox(height:20),Text('${visible.length} de ${scoped.length} Tipos',style:const TextStyle(color:Colors.blueGrey)),
            const SizedBox(height:12),
            if(visible.isEmpty)const Text('Nenhum Tipo corresponde à busca e ao filtro.')
            else SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(
              headingRowColor:const WidgetStatePropertyAll(Color(0xfff5f7fa)),dataRowMinHeight:68,dataRowMaxHeight:88,columnSpacing:24,
              columns:const [DataColumn(label:Text('ID')),DataColumn(label:Text('Tipo de Processo')),DataColumn(label:Text('Órgão')),DataColumn(label:Text('Revisão')),DataColumn(label:Text(''))],
              rows:visible.map((r)=>DataRow(cells:[
                DataCell(Text(r['id_tipo_procedimento'].toString())),
                DataCell(SizedBox(width:340,child:Text(r['nome'].toString(),maxLines:3,overflow:TextOverflow.ellipsis))),
                DataCell(Text(r['sigla'].toString())),
                DataCell(r['status']=='FINALIZADA'?const StatusTag('FINALIZADA'):StatusTag(r['visualizado']=='S'&&pending(r)==0?'MANTER':'PENDENTE',
                  label:r['visualizado']!='S'?'Não visualizado':pending(r)==0?'Revisão completa':'${pending(r)} vínculos pendentes')),
                DataCell(TextButton(onPressed:()=>open('/tipos/${r['id_atribuicao']}'),child:const Text('Abrir'))),
              ])).toList())),
          ])),
        ],
      ]);
    }));
}

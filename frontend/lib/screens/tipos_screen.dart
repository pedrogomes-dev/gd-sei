import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/display_fields.dart';

class TiposScreen extends StatefulWidget {
  const TiposScreen({super.key});
  @override State<TiposScreen> createState()=>_TiposScreenState();
}
class _TiposScreenState extends State<TiposScreen> {
  late Future<List<dynamic>> future;
  String searchText='',filter='TODOS';
  int pending(dynamic row)=>int.parse(row['pendentes'].toString());
  @override void initState(){super.initState();future=ApiService().tipos();}
  Future<void> open(String id) async {
    await Navigator.pushNamed(context,'/tipos/$id');
    if(mounted)setState((){future=ApiService().tipos();});
  }
  Future<void> openSummary(Map<String,dynamic> group) async {
    await Navigator.pushNamed(context,'/resumo?consulta=${group['id_consulta']}&orgao=${group['id_orgao']}');
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
      final groups=<String,Map<String,dynamic>>{};
      for(final r in rows){groups['${r['id_consulta']}/${r['id_orgao']}']=Map<String,dynamic>.from(r as Map);}
      final visible=rows.where((r){
        final text='${r['nome']} ${r['id_tipo_procedimento']} ${r['sigla']} ${r['consulta']}'.toLowerCase();
        if(!text.contains(searchText.trim().toLowerCase()))return false;
        return switch(filter){
          'PENDENTES'=>r['status']=='RASCUNHO' && (r['visualizado']!='S'||pending(r)>0),
          'VISUALIZADOS'=>r['visualizado']=='S',
          'FINALIZADAS'=>r['status']=='FINALIZADA',
          _=>true,
        };
      }).toList();
      return ListView(padding:const EdgeInsets.all(24),children:[
        ...groups.values.map((g){
          final groupRows=rows.where((r)=>r['id_consulta']==g['id_consulta']&&r['id_orgao']==g['id_orgao']).toList();
          final viewed=groupRows.where((r)=>r['visualizado']=='S').length;
          final outstanding=groupRows.fold<int>(0,(total,r)=>total+pending(r));
          return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
            crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('${g['sigla']} — ${g['consulta']}',style:Theme.of(context).textTheme.titleMedium),
            Wrap(spacing:8,children:[StatusTag(g['status'].toString()),
              StatusTag('VISUALIZADO',label:'$viewed/${groupRows.length} Tipos visualizados'),
              StatusTag(outstanding==0?'MANTER':'PENDENTE',label:'$outstanding vínculos sem decisão')]),
            LinearProgressIndicator(value:viewed/groupRows.length),
            const SizedBox(height:12),
            ElevatedButton(onPressed:()=>openSummary(g),child:const Text('Resumo e submissão')),
          ])));
        }),
        const SizedBox(height:16),
        TextField(decoration:const InputDecoration(labelText:'Buscar Tipo por nome ou ID, órgão ou consulta',prefixIcon:Icon(Icons.search)),
          onChanged:(value)=>setState((){searchText=value;})),
        const SizedBox(height:12),
        Wrap(spacing:8,children:[
          for(final option in const {'TODOS':'Todos','PENDENTES':'Pendentes','VISUALIZADOS':'Visualizados','FINALIZADAS':'Finalizadas'}.entries)
            ChoiceChip(label:Text(option.value),selected:filter==option.key,onSelected:(_)=>setState((){filter=option.key;})),
        ]),
        Text('${visible.length} de ${rows.length} Tipos'),
        if(visible.isEmpty)const Padding(padding:EdgeInsets.all(16),child:Text('Nenhum Tipo corresponde à busca e ao filtro.')),
        ...visible.map((r)=>Card(child:ListTile(
          title:Text('ID ${r['id_tipo_procedimento']} • ${r['nome']}'),
          subtitle:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text('${r['sigla']} • ${r['consulta']}'),
            Wrap(spacing:8,children:[StatusTag(r['status'].toString()),
              StatusTag(r['visualizado']=='S'?'VISUALIZADO':'PENDENTE',label:r['visualizado']=='S'?'Visualizado':'Visualização pendente'),
              StatusTag(pending(r)==0?'MANTER':'PENDENTE',label:'${pending(r)} vínculos sem decisão')]),
          ]),
          trailing:const Icon(Icons.chevron_right),
          onTap:()=>open(r['id_atribuicao'].toString()),
        ))),
      ]);
    }));
}

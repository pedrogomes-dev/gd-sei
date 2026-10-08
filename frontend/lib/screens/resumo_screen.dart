import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/display_fields.dart';
import '../widgets/app_shell.dart';

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
        FilledButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Finalizar'))]));
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
  String date(dynamic raw) {
    final text=raw.toString();
    final parsed=DateTime.tryParse(text.endsWith('Z')?text:'${text}Z');
    if(parsed==null)return 'Data indisponível';
    final d=parsed.toLocal();String pad(int n)=>n.toString().padLeft(2,'0');
    return '${pad(d.day)}/${pad(d.month)}/${d.year} às ${pad(d.hour)}:${pad(d.minute)} (horário local)';
  }
  @override Widget build(BuildContext context)=>AppShell(
    title:'Resumo da manifestação',section:'resumos',trail:['Resumo e submissão','Manifestação'],
    actions:[IconButton(onPressed:busy?null:reload,tooltip:'Atualizar',icon:const Icon(Icons.refresh))],
    child:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Text(snapshot.error.toString()));
      final data=snapshot.data!;final header=data['consulta_orgao'] as Map<String,dynamic>;
      final types=data['tipos'] as List<dynamic>;final decisions=data['decisoes'] as List<dynamic>;
      final finalized=header['status']=='FINALIZADA';
      return ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
        SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Wrap(spacing:16,runSpacing:12,crossAxisAlignment:WrapCrossAlignment.center,children:[
            Text(header['sigla'].toString(),style:Theme.of(context).textTheme.titleLarge),StatusTag(header['status'].toString())]),
          const SizedBox(height:12),Text(header['consulta'].toString()),
          if(header['data_finalizacao']!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text('Finalizada em ${date(header['data_finalizacao'])}',style:const TextStyle(color:Colors.blueGrey))),
          const SizedBox(height:24),Wrap(spacing:32,runSpacing:12,children:[
            for(final action in ['MANTER','REMOVER','ADICIONAR'])Text('${action=='ADICIONAR'?'Inclusões':action=='REMOVER'?'Remoções':'Manutenções'}: ${decisions.where((d)=>d['acao']==action).length}',style:const TextStyle(fontWeight:FontWeight.w600))]),
          const SizedBox(height:16),Text(finalized?'Manifestação finalizada. Os dados estão disponíveis para consulta.':'Confira as decisões salvas antes de submeter a manifestação.',style:const TextStyle(color:Colors.blueGrey)),
        ])),
        ...types.map((t){
          final links=decisions.where((d)=>d['id_atribuicao'].toString()==t['id_atribuicao'].toString()).toList();
          return SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(t['nome'].toString(),style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.w600)),
            const SizedBox(height:12),Wrap(spacing:16,runSpacing:8,children:[
              Text(t['visualizado']=='S'?'Visualização registrada':'Visualização pendente',style:const TextStyle(color:Colors.blueGrey)),
              Text(t['pendentes'].toString()=='0'?'Revisão completa':'${t['pendentes']} vínculos pendentes',style:const TextStyle(color:Colors.blueGrey))]),
            const SizedBox(height:20),
            if(links.isEmpty)const Text('Nenhuma decisão de vínculo salva.')
            else SingleChildScrollView(scrollDirection:Axis.horizontal,child:DataTable(
              headingRowColor:const WidgetStatePropertyAll(Color(0xfff5f7fa)),dataRowMinHeight:72,dataRowMaxHeight:120,columnSpacing:24,
              columns:const [DataColumn(label:Text('Assunto')),DataColumn(label:Text('Decisão')),DataColumn(label:Text('Justificativa'))],
              rows:links.map((d)=>DataRow(cells:[
                DataCell(SizedBox(width:390,child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Text('ID ${d['id_assunto']} · ${d['codigo_estruturado']}',style:const TextStyle(fontSize:12,color:Colors.blueGrey)),
                  const SizedBox(height:4),Text(d['descricao'].toString(),maxLines:3,overflow:TextOverflow.ellipsis)]))),
                DataCell(StatusTag(d['acao'].toString())),
                DataCell(SizedBox(width:260,child:Text((d['justificativa']??'').toString().isEmpty?'—':d['justificativa'].toString(),maxLines:4,overflow:TextOverflow.ellipsis)),
                  onTap:()=>showDialog<void>(context:context,builder:(context)=>AlertDialog(title:const Text('Justificativa'),
                    content:SingleChildScrollView(child:Text((d['justificativa']??'').toString().isEmpty?'Nenhuma justificativa informada.':d['justificativa'].toString())),
                    actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Fechar'))]))),
              ])).toList())),
            if((t['observacao']??'').toString().isNotEmpty)...[
              const SizedBox(height:20),const Divider(),const SizedBox(height:12),
              const Text('Observação sobre o Tipo',style:TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:8),Text(t['observacao'].toString())],
            const SizedBox(height:16),TextButton.icon(onPressed:busy?null:()=>open(t['id_atribuicao'].toString()),icon:const Icon(Icons.open_in_new,size:18),label:Text(finalized?'Consultar Tipo':'Revisar Tipo')),
          ]));
        }),
        if(error!=null)Padding(padding:const EdgeInsets.only(bottom:16),child:Text(error!)),
        if(!finalized)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Submissão do órgão',style:TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:12),
          Text(data['pode_finalizar']==true?'Todos os Tipos estão revisados. Você pode finalizar a manifestação.':'Visualize todos os Tipos e salve uma decisão para cada vínculo existente.'),
          const SizedBox(height:20),FilledButton.icon(onPressed:busy||data['pode_finalizar']!=true?null:()=>finalize(data),icon:const Icon(Icons.send_outlined),label:Text(busy?'Finalizando…':'Finalizar manifestação')),
        ])),
      ]);
    }));
}

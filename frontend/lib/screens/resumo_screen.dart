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
      content:const Text('A submissão abrangerá todos os Tipos de Processo desta consulta. Após finalizar, não será possível alterar ou reabrir.'),
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
  Future<Map<String,dynamic>> loadSubject(Map<String,dynamic> row) async {
    final detail=await ApiService().tipo(row['id_atribuicao'].toString());
    final candidates=[...(detail['assuntos'] as List<dynamic>),...(detail['decisoes'] as List<dynamic>)];
    for(final subject in candidates) {
      if(subject['id_assunto'].toString()==row['id_assunto'].toString())return Map<String,dynamic>.from(subject as Map);
    }
    throw Exception('Assunto não encontrado na versão da consulta.');
  }
  void subjectInfo(Map<String,dynamic> subject) {
    var detail=loadSubject(subject);
    showDialog<void>(context:context,builder:(context)=>StatefulBuilder(builder:(context,setDialogState)=>AlertDialog(
      title:Text('Informações do Assunto ${subject['id_assunto']}'),
      content:SizedBox(width:600,child:FutureBuilder<Map<String,dynamic>>(future:detail,builder:(context,snapshot){
        if(snapshot.connectionState!=ConnectionState.done)return const SizedBox(height:120,child:Center(child:CircularProgressIndicator()));
        if(snapshot.hasError)return Column(mainAxisSize:MainAxisSize.min,children:[Text(snapshot.error.toString()),
          TextButton(onPressed:()=>setDialogState((){detail=loadSubject(subject);}),child:const Text('Tentar novamente'))]);
        final value=snapshot.data!;
        return SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
          for(final key in ['id_assunto','codigo_estruturado','descricao'])propertyTile(MapEntry(key,value[key])),
          const Divider(),
          const ListTile(title:Text('Prazos de guarda',style:TextStyle(fontWeight:FontWeight.w600))),
          ListTile(leading:const Icon(Icons.schedule_outlined),title:const Text('Prazo corrente'),subtitle:Text(value['prazo_corrente']?.toString()??'Não informado')),
          ListTile(leading:const Icon(Icons.schedule_outlined),title:const Text('Prazo intermediário'),subtitle:Text(value['prazo_intermediario']?.toString()??'Não informado')),
          destinationTile(value['sta_destinacao']),const Divider(),
          for(final entry in value.entries.where((e)=>propertyLabels.containsKey(e.key)&&!['id_assunto','codigo_estruturado','descricao','prazo_corrente','prazo_intermediario','sta_destinacao'].contains(e.key)))propertyTile(entry),
        ]));
      })),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Fechar'))])));
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
          Row(children:[Expanded(child:Text(header['sigla'].toString(),style:Theme.of(context).textTheme.titleLarge)),StatusTag(header['status'].toString())]),
          const SizedBox(height:12),Text(header['consulta'].toString()),
          if(header['data_finalizacao']!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text('Finalizada em ${date(header['data_finalizacao'])}',style:const TextStyle(color:Colors.blueGrey))),
          const SizedBox(height:24),Wrap(spacing:32,runSpacing:12,children:[
            for(final action in ['MANTER','REMOVER','ADICIONAR'])Row(mainAxisSize:MainAxisSize.min,children:[Icon(action=='ADICIONAR'?Icons.add_circle_outline:action=='REMOVER'?Icons.remove_circle_outline:Icons.check_circle_outline,size:20,color:action=='ADICIONAR'?Colors.green:action=='REMOVER'?Colors.red:Colors.blue),const SizedBox(width:8),Text('${action=='ADICIONAR'?'Inclusões':action=='REMOVER'?'Remoções':'Manutenções'}: ${decisions.where((d)=>d['acao']==action).length}',style:const TextStyle(fontWeight:FontWeight.w600))])]),
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
            else SubjectTableViewport(child:Table(
              columnWidths:const {0:FixedColumnWidth(52),1:FlexColumnWidth(3),2:FixedColumnWidth(140),3:FlexColumnWidth(2)},
              defaultVerticalAlignment:TableCellVerticalAlignment.middle,
              border:const TableBorder(horizontalInside:BorderSide(color:Color(0xffe2e8f0))),
              children:[
                const TableRow(decoration:BoxDecoration(color:Color(0xfff5f7fa)),children:[
                  SizedBox.shrink(),Padding(padding:EdgeInsets.all(16),child:Text('Assunto')),
                  Padding(padding:EdgeInsets.all(16),child:Text('Decisão')),
                  Padding(padding:EdgeInsets.all(16),child:Text('Justificativa'))]),
                ...links.map((d)=>TableRow(children:[
                  IconButton(tooltip:'Informações do Assunto',icon:const Icon(Icons.info_outline),onPressed:()=>subjectInfo(Map<String,dynamic>.from(d as Map))),
                  Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Text('ID ${d['id_assunto']} · ${d['codigo_estruturado']}',style:const TextStyle(fontSize:12,color:Colors.blueGrey)),
                    const SizedBox(height:6),Text(d['descricao'].toString())])),
                  Padding(padding:const EdgeInsets.symmetric(horizontal:8,vertical:16),child:Align(alignment:Alignment.centerLeft,child:StatusTag(d['acao'].toString()))),
                  Padding(padding:const EdgeInsets.all(16),child:Text((d['justificativa']??'').toString().isEmpty?'—':d['justificativa'].toString())),
                ])),
              ])),
            if((t['observacao']??'').toString().isNotEmpty)...[
              const SizedBox(height:20),const Divider(),const SizedBox(height:12),
              const Text('Observação sobre o Tipo de Processo',style:TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:8),Text(t['observacao'].toString())],
            const SizedBox(height:16),Align(alignment:Alignment.centerRight,child:TextButton.icon(onPressed:busy?null:()=>open(t['id_atribuicao'].toString()),icon:const Icon(Icons.open_in_new,size:18),label:Text(finalized?'Consultar Tipo de Processo':'Revisar Tipo de Processo'))),
          ]));
        }),
        if(error!=null)Padding(padding:const EdgeInsets.only(bottom:16),child:Text(error!)),
        if(!finalized)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Submissão do órgão',style:TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:12),
          Text(data['pode_finalizar']==true?'Todos os Tipos de Processo estão revisados. Você pode finalizar a manifestação.':'Visualize todos os Tipos de Processo e salve uma decisão para cada vínculo existente.'),
          const SizedBox(height:20),Align(alignment:Alignment.centerRight,child:FilledButton.icon(onPressed:busy||data['pode_finalizar']!=true?null:()=>finalize(data),icon:const Icon(Icons.send_outlined),label:Text(busy?'Finalizando…':'Finalizar manifestação'))),
        ])),
      ]);
    }));
}

// Separate controllers keep table scrolling independent from the page.
class SubjectTableViewport extends StatefulWidget {
  final Widget child;
  const SubjectTableViewport({super.key,required this.child});
  @override State<SubjectTableViewport> createState()=>_SubjectTableViewportState();
}
class _SubjectTableViewportState extends State<SubjectTableViewport> {
  final vertical=ScrollController();
  final horizontal=ScrollController();
  @override void dispose(){vertical.dispose();horizontal.dispose();super.dispose();}
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,constraints){
    final width=constraints.maxWidth<640?640.0:constraints.maxWidth;
    final height=(MediaQuery.sizeOf(context).height*.4).clamp(180.0,440.0).toDouble();
    return SizedBox(height:height,child:Scrollbar(controller:vertical,thumbVisibility:true,notificationPredicate:(n)=>n.metrics.axis==Axis.vertical,
      child:SingleChildScrollView(controller:vertical,primary:false,
        child:Scrollbar(controller:horizontal,thumbVisibility:constraints.maxWidth<640,notificationPredicate:(n)=>n.metrics.axis==Axis.horizontal,
          child:SingleChildScrollView(controller:horizontal,primary:false,scrollDirection:Axis.horizontal,
            child:SizedBox(width:width,child:widget.child))))));
  });
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TipoScreen extends StatefulWidget {
  final String id;
  const TipoScreen({super.key,required this.id});
  @override State<TipoScreen> createState()=>_TipoScreenState();
}
class _TipoScreenState extends State<TipoScreen> {
  final api=ApiService();
  final observation=TextEditingController();
  final query=TextEditingController();
  final reasons=<int,TextEditingController>{};
  final actions=<int,String>{};
  final additions=<int,Map<String,dynamic>>{};
  late Future<Map<String,dynamic>> future;
  Map<String,dynamic>? data;
  List<dynamic> results=[];
  bool busy=false,searching=false,dirty=false,viewed=false,more=false;
  String? error,searchError;
  String searchText='';
  int offset=0,revision=0;
  bool get locked => data?['tipo']['status']=='FINALIZADA';
  int id(dynamic value)=>int.parse(value.toString());
  @override void initState(){super.initState();future=load();}
  Future<Map<String,dynamic>> load() async {
    final value=await api.tipo(widget.id);
    if(!mounted)return value;
    for(final controller in reasons.values){controller.dispose();}
    reasons.clear();actions.clear();additions.clear();
    data=value;
    final manifest=value['manifestacao'] as Map<String,dynamic>;
    revision=id(manifest['revisao']);observation.text=(manifest['observacao']??'').toString();
    for(final subject in value['assuntos'] as List<dynamic>) {
      reasons[id(subject['id_assunto'])]=TextEditingController();
    }
    for(final item in value['decisoes'] as List<dynamic>) {
      final key=id(item['id_assunto']);actions[key]=item['acao'].toString();
      reasons.putIfAbsent(key,()=>TextEditingController()).text=(item['justificativa']??'').toString();
      if(item['acao']=='ADICIONAR')additions[key]=Map<String,dynamic>.from(item as Map);
    }
    dirty=false;return value;
  }
  @override void dispose(){observation.dispose();query.dispose();for(final c in reasons.values){c.dispose();}super.dispose();}
  Future<bool> confirmDiscard() async {
    if(!dirty)return true;
    return await showDialog<bool>(context:context,builder:(context)=>AlertDialog(
      title:const Text('Descartar alterações não salvas?'),
      content:const Text('O preenchimento desde o último salvamento será perdido.'),
      actions:[TextButton(onPressed:()=>Navigator.pop(context,false),child:const Text('Continuar editando')),
        ElevatedButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Descartar'))]))??false;
  }
  Future<void> reload() async {
    if(!await confirmDiscard() || !mounted)return;
    setState((){error=null;future=load();});
  }
  Future<void> save() async {
    final items=actions.entries.map((e)=>{'id_assunto':e.key,'acao':e.value,
      'justificativa':reasons[e.key]!.text.trim()}).toList();
    if(items.any((e)=>e['acao']!='MANTER' && (e['justificativa'] as String).isEmpty)) {
      setState((){error='Preencha a justificativa de todas as remoções e inclusões.';});return;
    }
    setState((){busy=true;error=null;});
    try {
      final result=await api.save(widget.id,{'revisao':revision,'observacao':observation.text,'vinculos':items});
      if(!mounted)return;
      setState((){revision=id(result['revisao']);dirty=false;});
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Rascunho salvo.')));
    } catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  Future<void> markViewed() async {
    setState((){busy=true;error=null;});
    try{await api.visualizar(widget.id);if(mounted)setState((){viewed=true;});}
    catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  Future<void> search({bool next=false}) async {
    setState((){searching=true;searchError=null;});
    final requestedText=next?searchText:query.text.trim();
    final requestedOffset=next?offset+50:0;
    try {
      final result=await api.search(widget.id,requestedText,requestedOffset);
      if(mounted)setState((){results=result['itens'] as List<dynamic>;more=result['mais']==true;
        searchText=requestedText;offset=requestedOffset;});
    } catch(e){if(mounted)setState((){searchError=e.toString();});}
    finally{if(mounted)setState((){searching=false;});}
  }
  void choose(int key,String? action) {
    setState((){if(action==null){actions.remove(key);}else{actions[key]=action;}dirty=true;});
  }
  Widget reason(int key) => TextField(controller:reasons[key],enabled:!locked&&!busy,
    maxLength:2000,maxLines:2,onChanged:(_)=>setState((){dirty=true;}),
    decoration:InputDecoration(labelText:actions[key]=='MANTER'?'Justificativa (opcional)':'Justificativa (obrigatória)'));
  Widget subjectCard(Map<String,dynamic> subject) {
    final key=id(subject['id_assunto']);
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('${subject['codigo_estruturado']} — ${subject['descricao']}',style:Theme.of(context).textTheme.titleMedium),
      ExpansionTile(title:const Text('Propriedades do Assunto'),children:
        subject.entries.where((e)=>!['versao','sin_ultima'].contains(e.key)).map((e)=>ListTile(dense:true,title:Text(e.key),subtitle:Text('${e.value??'—'}'))).toList()),
      RadioListTile<String>(title:const Text('Manter'),value:'MANTER',groupValue:actions[key],
        onChanged:locked||busy?null:(value)=>choose(key,value)),
      RadioListTile<String>(title:const Text('Remover'),value:'REMOVER',groupValue:actions[key],
        onChanged:locked||busy?null:(value)=>choose(key,value)),
      if(actions.containsKey(key))reason(key),
      if(!locked)TextButton(onPressed:busy?null:()=>choose(key,null),child:const Text('Deixar pendente')),
    ])));
  }
  @override Widget build(BuildContext context)=>PopScope<Object?>(
    canPop:!dirty&&!busy,
    onPopInvokedWithResult:(didPop,result) async {
      if(didPop||busy)return;
      if(await confirmDiscard() && mounted) {
        setState((){dirty=false;});
        WidgetsBinding.instance.addPostFrameCallback((_){if(mounted)Navigator.pop(context);});
      }
    },
    child:Scaffold(appBar:AppBar(title:const Text('Tipo de Processo'),actions:[
      TextButton(onPressed:busy?null:reload,child:const Text('Recarregar'))]),
    body:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,snapshot){
      if(snapshot.connectionState!=ConnectionState.done)return const Center(child:CircularProgressIndicator());
      if(snapshot.hasError)return Center(child:Text(snapshot.error.toString()));
      final tipo=snapshot.data!['tipo'] as Map<String,dynamic>;
      final subjects=snapshot.data!['assuntos'] as List<dynamic>;
      return ListView(padding:const EdgeInsets.all(24),children:[
        Text(tipo['nome'].toString(),style:Theme.of(context).textTheme.headlineSmall),
        Text(locked?'Manifestação finalizada — somente leitura.':'Rascunho compartilhado pelo órgão.'),
        ExpansionTile(title:const Text('Propriedades do Tipo'),children:tipo.entries
          .where((e)=>!['id_atribuicao','id_consulta','id_orgao','status','versao','sin_ultima'].contains(e.key))
          .map((e)=>ListTile(dense:true,title:Text(e.key),subtitle:Text('${e.value??'—'}'))).toList()),
        const SizedBox(height:16),const Text('Assuntos atualmente vinculados'),
        if(subjects.isEmpty)const Text('Nenhum vínculo existente.'),
        ...subjects.map((s)=>subjectCard(Map<String,dynamic>.from(s as Map))),
        const SizedBox(height:24),const Text('Inclusões propostas'),
        ...additions.entries.map((e)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(
          crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('${e.value['codigo_estruturado']} — ${e.value['descricao']}'),reason(e.key),
          if(!locked)TextButton(onPressed:busy?null:()=>setState((){actions.remove(e.key);additions.remove(e.key);dirty=true;}),
            child:const Text('Retirar proposta de inclusão')),
        ])))),
        if(!locked)...[
          TextField(controller:query,maxLength:250,decoration:const InputDecoration(labelText:'Pesquisar código, descrição, observação ou índice'),
            onSubmitted:(_){if(!searching&&!busy)search();}),
          ElevatedButton(onPressed:searching||busy?null:()=>search(),child:Text(searching?'Pesquisando…':'Pesquisar Assuntos ativos')),
          if(searchError!=null)Text(searchError!),
          ...results.map((s)=>Card(child:Column(children:[
            ListTile(title:Text('${s['codigo_estruturado']} — ${s['descricao']}'),
              subtitle:Text('${s['observacao']??''}'),trailing:ElevatedButton(
                onPressed:busy||additions.containsKey(id(s['id_assunto']))?null:()=>setState((){
                  final key=id(s['id_assunto']);additions[key]=Map<String,dynamic>.from(s as Map);
                  actions[key]='ADICIONAR';reasons.putIfAbsent(key,()=>TextEditingController());dirty=true;
                }),child:const Text('Propor inclusão'))),
            ExpansionTile(title:const Text('Propriedades do Assunto'),children:
              (s as Map<String,dynamic>).entries.where((e)=>!['versao','sin_ultima'].contains(e.key))
                .map((e)=>ListTile(dense:true,title:Text(e.key),subtitle:Text('${e.value??'—'}'))).toList()),
          ]))),
          if(more)TextButton(onPressed:searching||busy?null:()=>search(next:true),child:const Text('Próxima página')),
          if(results.isEmpty && searchText.isNotEmpty && !searching)const Text('Nenhum Assunto encontrado.'),
        ],
        const SizedBox(height:24),
        TextField(controller:observation,maxLength:5000,maxLines:4,enabled:!locked&&!busy,
          onChanged:(_)=>setState((){dirty=true;}),decoration:const InputDecoration(labelText:'Observação geral sobre o Tipo')),
        if(error!=null)Text(error!,style:TextStyle(color:Theme.of(context).colorScheme.error)),
        if(!locked)Row(children:[
          ElevatedButton(onPressed:busy?null:save,child:Text(busy?'Aguarde…':'Salvar rascunho')),
          const SizedBox(width:16),Text(dirty?'Alterações não salvas':'Sem alterações pendentes'),
        ]),
        const SizedBox(height:16),
        ElevatedButton(onPressed:busy||viewed||locked?null:markViewed,
          child:Text(viewed?'Visualização registrada':'Confirmar visualização deste Tipo')),
      ]);
    })));
}

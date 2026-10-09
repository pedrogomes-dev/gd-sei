import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';

class AdminHistoryScreen extends StatefulWidget {
  final int id;
  const AdminHistoryScreen({super.key,required this.id});
  @override State<AdminHistoryScreen> createState()=>_AdminHistoryScreenState();
}
class _AdminHistoryScreenState extends State<AdminHistoryScreen> {
  List<dynamic> events=[];
  Map<int,String> organs={};
  String title='Histórico administrativo';
  String? error;
  int offset=0;
  bool busy=true,more=false;
  @override void initState(){super.initState();initialize();}
  Future<void> initialize() async {
    try {
      final user=await ApiService().adminUser(widget.id);
      final data=await ApiService().adminOrgans();
      if(!mounted)return;
      setState((){title='Histórico de ${user['nome']??user['email']}';organs={for(final o in data)int.parse(o['id_orgao'].toString()):o['sigla'].toString()};});
      await load(0);
    }catch(e){if(mounted)setState((){busy=false;error=e.toString();});}
  }
  Future<void> load(int page) async {
    setState((){busy=true;error=null;});
    try {
      final data=await ApiService().adminHistory(widget.id,page);
      if(mounted)setState((){events=data['itens'] as List;more=data['mais']==true;offset=page;});
    }catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  String date(dynamic value) {
    final date=DateTime.tryParse(value.toString())?.toLocal();
    if(date==null)return value.toString();
    String two(int n)=>n.toString().padLeft(2,'0');
    return '${two(date.day)}/${two(date.month)}/${date.year} ${two(date.hour)}:${two(date.minute)}:${two(date.second)}';
  }
  Map<String,String> fields(dynamic data) {
    if(data==null)return {};
    return {'Nome':data['nome']?.toString()??'Não informado','E-mail':data['email'].toString(),
      'Acesso':data['sin_ativo']=='S'?'Ativo':'Inativo','Perfil':data['sin_admin']=='S'?'Administrador':'Avaliador',
      'Órgãos':(data['orgaos'] as List).isEmpty?'Sem vínculo':(data['orgaos'] as List).map((o){final id=int.parse(o['id_orgao'].toString());return organs[id]??'Órgão $id';}).join(' · ')};
  }
  Widget event(dynamic row) {
    final before=fields(row['antes']),after=fields(row['depois']);
    final changed=after.keys.where((key)=>before[key]!=after[key]).toList();
    final label=switch(row['evento']){'USUARIO_CRIADO'=>'Usuário cadastrado','ADMINISTRADOR_INICIAL'=>'Administrador inicial definido',_=>'Cadastro atualizado'};
    return SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text(label,style:const TextStyle(fontWeight:FontWeight.w600)),const SizedBox(height:8),
      Text('${date(row['data_evento'])} · ${row['responsavel_nome']??row['responsavel_email']} (${row['responsavel_email']})'),
      const SizedBox(height:16),
      if(changed.isEmpty)const Text('Cadastro salvo sem alteração dos campos.'),
      for(final key in changed)Padding(padding:const EdgeInsets.only(bottom:12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(key,style:const TextStyle(fontWeight:FontWeight.w600)),
        if(row['antes']!=null)SelectableText('Antes: ${before[key]??'Não informado'}'),
        SelectableText('Depois: ${after[key]}'),
      ])),
    ]));
  }
  @override Widget build(BuildContext context)=>AppShell(title:title,section:'admin-usuarios',trail:const ['Usuários','Histórico'],
    actions:[TextButton.icon(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.arrow_back),label:const Text('Voltar'))],
    child:ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
      const Text('Alterações de cadastro, acesso, perfil e vínculos. As datas usam o fuso do navegador.'),const SizedBox(height:24),
      if(busy)const LinearProgressIndicator(),
      if(error!=null)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(error!),TextButton(onPressed:busy?null:initialize,child:const Text('Tentar novamente'))])),
      if(!busy && error==null)...[
        if(events.isEmpty)const SectionCard(child:Text('Nenhum evento registrado.')),
        ...events.map(event),
        Wrap(spacing:16,crossAxisAlignment:WrapCrossAlignment.center,children:[Text('Página ${offset~/50+1}'),
          if(offset>0)TextButton(onPressed:()=>load(offset-50),child:const Text('Anterior')),
          if(more)TextButton(onPressed:()=>load(offset+50),child:const Text('Próxima')),
        ]),
      ],
    ]));
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_shell.dart';
import '../widgets/display_fields.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override State<AdminUsersScreen> createState()=>_AdminUsersScreenState();
}
class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final api=ApiService(),query=TextEditingController();
  List<dynamic> organs=[],users=[];
  int? organ;
  int currentUser=0,offset=0,total=0,generation=0;
  String state='TODOS',searched='';
  bool busy=true,ready=false,more=false;
  String? error;
  @override void initState(){super.initState();initialize();}
  @override void dispose(){query.dispose();super.dispose();}
  Future<void> initialize() async {
    setState((){busy=true;error=null;});
    try {
      final profile=await api.profile();
      if(profile['sin_admin']!='S')throw Exception('Acesso restrito à administração.');
      final result=await api.adminOrgans();
      if(!mounted)return;
      setState((){currentUser=int.parse(profile['id_usuario'].toString());organs=result;ready=true;});
      await search();
    }catch(e){if(mounted)setState((){error=e.toString();busy=false;});}
  }
  Future<void> search({int page=0,bool paging=false}) async {
    final request=++generation;
    final text=paging?searched:query.text.trim();
    setState((){busy=true;error=null;});
    try {
      final data=await api.adminUsers(text,state,organ,page);
      if(mounted&&request==generation)setState((){
        users=data['itens'] as List;total=int.parse(data['total'].toString());more=data['mais']==true;offset=page;searched=text;
      });
    }catch(e){if(mounted&&request==generation)setState((){error=e.toString();});}
    finally{if(mounted&&request==generation)setState((){busy=false;});}
  }
  Future<void> edit(int? id) async {
    setState((){busy=true;error=null;});
    Map<String,dynamic>? user;
    try {if(id!=null)user=await api.adminUser(id);}
    catch(e){if(mounted)setState((){error=e.toString();busy=false;});return;}
    if(!mounted)return;
    final result=await showDialog<Map<String,dynamic>>(context:context,barrierDismissible:false,
      builder:(_)=>UserEditor(user:user,organs:organs,currentUser:currentUser));
    if(!mounted)return;
    setState((){busy=false;});
    if(result==null)return;
    if(int.parse(result['id_usuario'].toString())==currentUser && result['sessoes_revogadas'].toString()=='1') {
      Navigator.pushNamedAndRemoveUntil(context,'/login',(_)=>false);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Cadastro salvo.')));
    await search();
  }
  Widget table() {
    Widget cell(Widget child)=>Padding(padding:const EdgeInsets.all(12),child:child);
    return Table(columnWidths:const {0:FlexColumnWidth(2),1:FlexColumnWidth(2),2:FlexColumnWidth(2),3:FixedColumnWidth(110),4:FixedColumnWidth(130),5:FixedColumnWidth(140)},
      defaultVerticalAlignment:TableCellVerticalAlignment.middle,
      border:const TableBorder(horizontalInside:BorderSide(color:Color(0xffe2e8f0))),children:[
        TableRow(decoration:const BoxDecoration(color:Color(0xfff5f7fa)),children:[for(final label in ['Nome','E-mail','Órgãos','Acesso','Perfil','Ações'])cell(Text(label,style:const TextStyle(fontWeight:FontWeight.w600)))]),
        ...users.map((row)=>TableRow(children:[
          cell(Text(row['nome']?.toString()??'Nome não informado')),cell(Text(row['email'].toString())),
          cell(Text((row['orgaos'] as List).isEmpty?'Sem vínculo':(row['orgaos'] as List).map((o)=>o['sigla']).join(' · '))),
          cell(StatusTag(row['sin_ativo']=='S'?'ATIVO':'INATIVO')),
          cell(Text(row['sin_admin']=='S'?'Administrador':'Avaliador')),
          cell(Row(children:[
            IconButton(tooltip:'Editar usuário',onPressed:busy?null:()=>edit(int.parse(row['id_usuario'].toString())),icon:const Icon(Icons.edit_outlined)),
            IconButton(tooltip:'Histórico administrativo',onPressed:busy?null:()=>Navigator.pushNamed(context,'/admin/usuarios/${row['id_usuario']}/historico'),icon:const Icon(Icons.history)),
          ])),
        ])),
      ]);
  }
  @override Widget build(BuildContext context)=>AppShell(title:'Administração de usuários',section:'admin-usuarios',trail:const ['Usuários'],
    actions:[FilledButton.icon(onPressed:busy||!ready?null:()=>edit(null),icon:const Icon(Icons.person_add_outlined),label:const Text('Cadastrar usuário'))],
    child:ListView(padding:const EdgeInsets.fromLTRB(32,0,32,32),children:[
      if(error!=null)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(error!),const SizedBox(height:12),TextButton(onPressed:busy?null:()=>ready?search():initialize(),child:const Text('Tentar novamente'))])),
      if(busy)const LinearProgressIndicator(),
      if(ready)...[
        SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          TextField(controller:query,maxLength:250,enabled:!busy,decoration:const InputDecoration(labelText:'Buscar por nome ou e-mail',prefixIcon:Icon(Icons.search)),onSubmitted:(_)=>search()),
          const SizedBox(height:16),DropdownButtonFormField<int>(value:organ,isExpanded:true,
            decoration:const InputDecoration(labelText:'Órgão'),items:[
              const DropdownMenuItem<int>(value:null,child:Text('Todos os órgãos')),
              ...organs.map((o)=>DropdownMenuItem<int>(value:int.parse(o['id_orgao'].toString()),child:Text(o['sigla'].toString()))),
            ],onChanged:busy?null:(value){setState((){organ=value;});search();}),
          const SizedBox(height:16),Wrap(spacing:8,runSpacing:8,children:[
            for(final option in const {'TODOS':'Todos','S':'Ativos','N':'Inativos'}.entries)
              ChoiceChip(label:Text(option.value),selected:state==option.key,onSelected:busy?null:(_){setState((){state=option.key;});search();}),
            FilledButton.icon(onPressed:busy?null:()=>search(),icon:const Icon(Icons.search),label:const Text('Pesquisar')),
          ]),
        ])),
        if(!busy && error==null)SectionCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('$total usuários encontrados'),const SizedBox(height:16),
          if(users.isEmpty)const Text('Nenhum usuário encontrado.') else LayoutBuilder(builder:(context,c){
            final width=c.maxWidth<1000?1000.0:c.maxWidth;
            return SingleChildScrollView(scrollDirection:Axis.horizontal,child:SizedBox(width:width,child:table()));
          }),
          const SizedBox(height:16),Wrap(spacing:16,crossAxisAlignment:WrapCrossAlignment.center,children:[
            Text('Exibindo ${users.isEmpty?0:offset+1}–${offset+users.length} de $total'),
            if(offset>0)TextButton(onPressed:()=>search(page:offset-50,paging:true),child:const Text('Anterior')),
            if(more)TextButton(onPressed:()=>search(page:offset+50,paging:true),child:const Text('Próxima')),
          ]),
        ])),
      ],
    ]));
}

class UserEditor extends StatefulWidget {
  final Map<String,dynamic>? user;
  final List<dynamic> organs;
  final int currentUser;
  const UserEditor({super.key,required this.user,required this.organs,required this.currentUser});
  @override State<UserEditor> createState()=>_UserEditorState();
}
class _UserEditorState extends State<UserEditor> {
  final form=GlobalKey<FormState>();
  late final name=TextEditingController(text:widget.user?['nome']?.toString()??'');
  late final email=TextEditingController(text:widget.user?['email']?.toString()??'');
  late final Set<int> organs=(widget.user?['orgaos'] as List? ?? []).map((o)=>int.parse(o.toString())).toSet();
  late bool active=widget.user?['sin_ativo']!='N',admin=widget.user?['sin_admin']=='S';
  bool busy=false;
  String? error;
  @override void dispose(){name.dispose();email.dispose();super.dispose();}
  Future<void> save() async {
    if(!form.currentState!.validate())return;
    setState((){busy=true;error=null;});
    try {
      final result=await ApiService().saveUser(widget.user==null?null:int.parse(widget.user!['id_usuario'].toString()),{
        'nome':name.text.trim(),'email':email.text.trim(),'sin_ativo':active?'S':'N','sin_admin':admin?'S':'N',
        'revisao':widget.user==null?0:int.parse(widget.user!['revisao'].toString()),'orgaos':organs.toList()..sort(),
      });
      if(mounted){setState((){busy=false;});Navigator.pop(context,result);}
    }catch(e){if(mounted)setState((){error=e.toString();busy=false;});}
  }
  @override Widget build(BuildContext context)=>PopScope(canPop:!busy,child:AlertDialog(
    title:Text(widget.user==null?'Cadastrar usuário':'Editar usuário'),
    content:SizedBox(width:640,child:SingleChildScrollView(child:IgnorePointer(ignoring:busy,child:Form(key:form,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[
      TextFormField(controller:name,maxLength:150,decoration:const InputDecoration(labelText:'Nome'),validator:(v)=>v==null||v.trim().isEmpty?'Informe o nome.':null),
      const SizedBox(height:16),TextFormField(controller:email,maxLength:250,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'E-mail'),
        validator:(v)=>v==null||!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())?'Informe um e-mail válido.':null),
      const SizedBox(height:12),SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Acesso ativo'),value:active,onChanged:(v)=>setState((){active=v;})),
      SwitchListTile(contentPadding:EdgeInsets.zero,title:const Text('Administrador'),subtitle:const Text('Permite gerenciar todos os usuários e seus vínculos.'),value:admin,onChanged:(v)=>setState((){admin=v;})),
      const SizedBox(height:16),const Text('Órgãos vinculados',style:TextStyle(fontWeight:FontWeight.w600)),
      const Text('O usuário poderá avaliar os processos atribuídos a esses órgãos.'),
      if(widget.organs.isEmpty)const Text('Nenhum órgão cadastrado.'),
      ...widget.organs.map((o){final id=int.parse(o['id_orgao'].toString());return CheckboxListTile(contentPadding:EdgeInsets.zero,controlAffinity:ListTileControlAffinity.leading,title:Text(o['sigla'].toString()),value:organs.contains(id),onChanged:(v)=>setState((){if(v==true)organs.add(id);else organs.remove(id);}));}),
      const SizedBox(height:16),const Text('Alterações de e-mail, acesso, perfil ou órgãos encerram as sessões do usuário.'),
      if(widget.user?['id_usuario'].toString()==widget.currentUser.toString())const Padding(padding:EdgeInsets.only(top:8),child:Text('Você está editando seu próprio cadastro. Se alterar essas permissões, precisará entrar novamente.')),
      if(error!=null)Padding(padding:const EdgeInsets.only(top:16),child:Text(error!,style:const TextStyle(color:Colors.red))),
      if(busy)const LinearProgressIndicator(),
    ]))))),
    actions:[TextButton(onPressed:busy?null:()=>Navigator.pop(context),child:const Text('Cancelar')),
      FilledButton(onPressed:busy?null:save,child:const Text('Salvar'))],
  ));
}

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppShell extends StatefulWidget {
  final String title, section;
  final List<String> trail;
  final Widget child;
  final List<Widget> actions;
  final Widget? footer;
  final Future<bool> Function()? beforeLogout;
  const AppShell({super.key, required this.title, required this.child,
    this.section='tipos', this.trail=const [], this.actions=const [], this.footer, this.beforeLogout});
  @override State<AppShell> createState()=>_AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final Future<Map<String,dynamic>> profile=ApiService().profile();
  Future<void> logout() async {
    if(widget.beforeLogout!=null && !await widget.beforeLogout!())return;
    try {
      await ApiService().logout();
      if(mounted) Navigator.pushNamedAndRemoveUntil(context,'/login',(_)=>false);
    } catch(e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));
    }
  }
  void go(String path) {
    if(ModalRoute.of(context)?.settings.name==path)return;
    // Pushing preserves the detail screen's PopScope and unsaved edits.
    Navigator.pushNamed(context,path);
  }
  Widget menu()=>SizedBox(width:230,child:ColoredBox(color:Colors.white,child:ListView(
    padding:const EdgeInsets.symmetric(horizontal:16,vertical:24),children:[
      const Padding(padding:EdgeInsets.all(12),child:Text('VALIDAÇÃO',style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:Colors.blueGrey))),
      item('Tipos de Processo atribuídos',Icons.fact_check_outlined,'tipos','/tipos'),
      item('Resumo e submissão',Icons.assignment_outlined,'resumos','/resumos'),
      const SizedBox(height:24),
      const Padding(padding:EdgeInsets.all(12),child:Text('CATÁLOGO',style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:Colors.blueGrey))),
      item('Assuntos',Icons.topic_outlined,'assuntos','/catalogo/assuntos'),
      item('Tipos de Processo',Icons.folder_outlined,'catalogo-tipos','/catalogo/tipos'),
      FutureBuilder<Map<String,dynamic>>(future:profile,builder:(context,snapshot)=>
        snapshot.data?['sin_admin']=='S'?Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const SizedBox(height:24),
          const Padding(padding:EdgeInsets.all(12),child:Text('ADMINISTRAÇÃO',style:TextStyle(fontSize:12,fontWeight:FontWeight.w600,color:Colors.blueGrey))),
          item('Usuários',Icons.manage_accounts_outlined,'admin-usuarios','/admin/usuarios'),
        ]):const SizedBox.shrink()),
    ])));
  Widget item(String label,IconData icon,String section,String path)=>Padding(
    padding:const EdgeInsets.only(bottom:6),child:ListTile(
      shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
      selected:widget.section==section,selectedTileColor:const Color(0xffeaf2fc),
      leading:Icon(icon,size:20),title:Text(label,style:const TextStyle(fontSize:14)),
      onTap:()=>go(path)));
  @override Widget build(BuildContext context)=>LayoutBuilder(builder:(context,size){
    final wide=size.maxWidth>=1000;
    return Scaffold(
      appBar:AppBar(title:const Text('GD-SEI',style:TextStyle(fontWeight:FontWeight.w700)),
        automaticallyImplyLeading:!wide,backgroundColor:Colors.white,surfaceTintColor:Colors.transparent,
        shape:const Border(bottom:BorderSide(color:Color(0xffe2e8f0))),
        actions:[FutureBuilder<Map<String,dynamic>>(future:profile,builder:(context,snapshot){
          final user=snapshot.data;
          return PopupMenuButton<String>(onSelected:(value){if(value=='sair')logout();},
            tooltip:'Conta do usuário',itemBuilder:(_)=>[
              PopupMenuItem(enabled:false,child:Text(user?['email']?.toString()??'Identificação indisponível')),
              const PopupMenuItem(value:'sair',child:Text('Sair'))],
            child:Padding(padding:const EdgeInsets.symmetric(horizontal:24),child:Row(children:[
              const Icon(Icons.account_circle_outlined),const SizedBox(width:10),
              if(size.maxWidth>=650)Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text(user?['nome']?.toString()??user?['email']?.toString()??(snapshot.hasError?'Identificação indisponível':'Carregando usuário…'),style:const TextStyle(fontSize:14)),
                if(user!=null)Text((user['orgaos'] as List).map((o)=>o['sigla']).join(' · '),style:const TextStyle(fontSize:12,color:Colors.blueGrey)),
              ]),const SizedBox(width:8),const Icon(Icons.expand_more,size:18),
            ])));
        })]),
      drawer:wide?null:Drawer(child:SafeArea(child:menu())),
      body:Row(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        if(wide)...[menu(),const VerticalDivider(width:1,color:Color(0xffe2e8f0))],
        Expanded(child:Column(children:[
          Padding(padding:EdgeInsets.fromLTRB(wide?32:20,24,wide?32:20,20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Wrap(crossAxisAlignment:WrapCrossAlignment.center,children:[
              TextButton(onPressed:()=>go(widget.section=='admin-usuarios'?'/admin/usuarios':widget.section=='assuntos'||widget.section=='catalogo-tipos'?'/catalogo/assuntos':'/tipos'),child:Text(widget.section=='admin-usuarios'?'Administração':widget.section=='assuntos'||widget.section=='catalogo-tipos'?'Catálogo':'Validação')),
              for(final label in widget.trail)...[const Icon(Icons.chevron_right,size:16,color:Colors.blueGrey),if(label=='Tipos de Processo atribuídos'||label=='Resumo e submissão')TextButton(onPressed:()=>go(label=='Tipos de Processo atribuídos'?'/tipos':'/resumos'),child:Text(label))else Text(label,style:const TextStyle(fontSize:13,color:Colors.blueGrey))],
            ]),const SizedBox(height:8),
            Row(children:[Expanded(child:Text(widget.title,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w600))),...widget.actions]),
          ])),
          Expanded(child:widget.child),
          if(widget.footer!=null)Container(padding:const EdgeInsets.symmetric(horizontal:24,vertical:14),
            decoration:const BoxDecoration(color:Colors.white,border:Border(top:BorderSide(color:Color(0xffe2e8f0)))),child:widget.footer),
        ])),
      ]),
    );
  });
}

class SectionCard extends StatelessWidget {
  final Widget child;
  const SectionCard({super.key,required this.child});
  @override Widget build(BuildContext context)=>Container(
    margin:const EdgeInsets.only(bottom:24),padding:const EdgeInsets.all(24),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:const Color(0xffe2e8f0))),child:child);
}


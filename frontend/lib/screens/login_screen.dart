import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final email=TextEditingController(text:'pg@setic.ro.gov.br');
  final token=TextEditingController(text:'123456');
  bool busy=false;
  String? error;
  @override void dispose(){email.dispose();token.dispose();super.dispose();}
  Future<void> login() async {
    setState((){busy=true;error=null;});
    try {
      await ApiService().login(email.text.trim(),token.text.trim());
      if(mounted) Navigator.pushReplacementNamed(context,'/tipos');
    } catch(e){if(mounted)setState((){error=e.toString();});}
    finally{if(mounted)setState((){busy=false;});}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Validação SEI')),
    body:Center(child:SizedBox(width:450,child:Card(child:Padding(
      padding:const EdgeInsets.all(24),child:Column(mainAxisSize:MainAxisSize.min,children:[
        const Text('Acesso temporário de desenvolvimento'),
        TextField(controller:email,decoration:const InputDecoration(labelText:'E-mail')),
        TextField(controller:token,decoration:const InputDecoration(labelText:'Token')),
        if(error!=null)Text(error!),
        const SizedBox(height:16),
        ElevatedButton(onPressed:busy?null:login,child:Text(busy?'Entrando…':'Entrar')),
      ]))))));
}

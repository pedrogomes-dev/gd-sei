import 'package:flutter/material.dart';
import 'screens/initial_screen.dart';
import 'screens/login_screen.dart';
import 'screens/inicio_screen.dart';
import 'screens/tipos_screen.dart';
import 'screens/tipo_screen.dart';
import 'screens/resumo_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/admin_users_screen.dart';
import 'screens/admin_history_screen.dart';

void main() => runApp(const SeiApp());

class SeiApp extends StatelessWidget {
  const SeiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Validação SEI',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true,
      scaffoldBackgroundColor:const Color(0xfff5f7fa),
      inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder(),filled:true,fillColor:Colors.white,
        contentPadding:EdgeInsets.symmetric(horizontal:16,vertical:16)),
      dividerColor:const Color(0xffe2e8f0)),
    initialRoute: '/login',
    onGenerateRoute: (settings) {
      final name = settings.name ?? '/login';
      Widget screen;
      if(name=='/login' || name=='/verificar-token') { screen=const LoginScreen(); }
      else if(name=='/inicio') { screen=const InicioScreen(); }
      else if(name=='/tipos') { screen=const TiposScreen(); }
      else if(name=='/resumos') { screen=const TiposScreen(summaries:true); }
      else if(name=='/admin/usuarios') { screen=const AdminUsersScreen(); }
      else if(RegExp(r'^/admin/usuarios/\d+/historico$').hasMatch(name)) { screen=AdminHistoryScreen(id:int.parse(name.split('/')[3])); }
      else if(name=='/catalogo/assuntos' || name=='/catalogo/tipos') { screen=CatalogoScreen(kind:name.split('/').last); }
      else if(RegExp(r'^/tipos/\d+$').hasMatch(name)) { screen=TipoScreen(id:name.split('/').last); }
      else if(Uri.parse(name).path=='/resumo' &&
          RegExp(r'^\d+$').hasMatch(Uri.parse(name).queryParameters['consulta']??'') &&
          RegExp(r'^\d+$').hasMatch(Uri.parse(name).queryParameters['orgao']??'')) {
        final params=Uri.parse(name).queryParameters;
        screen=ResumoScreen(consulta:params['consulta']!,orgao:params['orgao']!);
      }
      else { screen=InitialScreen(route:name); }
      return MaterialPageRoute<void>(settings: settings,
        builder: (_) => screen);
    },
  );
}




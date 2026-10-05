import 'package:flutter/material.dart';
import 'screens/initial_screen.dart';
import 'screens/login_screen.dart';
import 'screens/tipos_screen.dart';
import 'screens/tipo_screen.dart';
import 'screens/resumo_screen.dart';

void main() => runApp(const SeiApp());

class SeiApp extends StatelessWidget {
  const SeiApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Validação SEI',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
    initialRoute: '/login',
    onGenerateRoute: (settings) {
      final name = settings.name ?? '/login';
      Widget screen;
      if(name=='/login' || name=='/verificar-token') { screen=const LoginScreen(); }
      else if(name=='/tipos' || name=='/inicio') { screen=const TiposScreen(); }
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

import 'package:flutter/material.dart';
import 'screens/initial_screen.dart';

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
      final known = {'/login', '/verificar-token', '/inicio', '/tipos', '/resumo'};
      final isType = RegExp(r'^/tipos/\d+$').hasMatch(name);
      return MaterialPageRoute<void>(settings: settings,
        builder: (_) => InitialScreen(route: known.contains(name) || isType ? name : '/404'));
    },
  );
}

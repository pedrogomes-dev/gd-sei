import 'package:flutter/material.dart';
import '../services/api_service.dart';

class InitialScreen extends StatefulWidget {
  final String route;
  const InitialScreen({super.key, required this.route});
  @override
  State<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  late Future<String> _health;
  @override
  void initState() { super.initState(); _health = ApiService().health(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Validação dos Assuntos Vinculados aos Tipos de Processos')),
    body: Center(child: SizedBox(width: 720, child: Card(
      child: Padding(padding: const EdgeInsets.all(24), child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Estrutura inicial — ${widget.route}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          const Text('Autenticação, consultas e manifestações serão implementadas na próxima etapa.'),
          const SizedBox(height: 16),
          FutureBuilder<String>(future: _health, builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const Text('Verificando API…');
            return Text(snapshot.hasError ? 'API indisponível. Confira a configuração.' : 'API: ${snapshot.data}');
          }),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () => setState(() { _health = ApiService().health(); }),
            child: const Text('Verificar novamente')),
        ],
      )),
    ))),
  );
}

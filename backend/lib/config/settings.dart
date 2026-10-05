import 'dart:io';
import 'package:dotenv/dotenv.dart';

Map<String, String> loadSettings() {
  final file = DotEnv();
  if (File('.env').existsSync()) file.load(['.env']);
  return {...file.map, ...Platform.environment};
}

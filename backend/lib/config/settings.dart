import 'dart:io';
import 'package:dotenv/dotenv.dart';

DotEnv loadSettings() {
  final file = DotEnv();
  if (File('.env').existsSync()) file.load(['.env']);
  file.addAll(Platform.environment);
  return file;
}

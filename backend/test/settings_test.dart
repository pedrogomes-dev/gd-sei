import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

void main() {
  Future<Map<String, dynamic>> lerConfiguracao(
      {required bool comArquivo}) async {
    final pasta = await Directory.systemTemp.createTemp('gd_sei_settings_');
    addTearDown(() => pasta.delete(recursive: true));
    if (comArquivo) {
      await File('${pasta.path}/.env').writeAsString(r'''
GD_SEI_TEST_OVERRIDE=arquivo
GD_SEI_TEST_EMPTY=arquivo
export GD_SEI_TEST_QUOTED="olá mundo"
GD_SEI_TEST_BASE=base
GD_SEI_TEST_INTERPOLATED=${GD_SEI_TEST_BASE}/valor
''');
    }
    final ambiente = Map<String, String>.from(Platform.environment)
      ..removeWhere((key, _) => key.startsWith('GD_SEI_TEST_'))
      ..addAll({'GD_SEI_TEST_OVERRIDE': 'ambiente', 'GD_SEI_TEST_EMPTY': ''});
    final resultado = await Process.run(
      Platform.resolvedExecutable,
      [
        '--packages=${File('.dart_tool/package_config.json').absolute.path}',
        File('test/fixtures/read_settings.dart').absolute.path,
      ],
      workingDirectory: pasta.path,
      environment: ambiente,
      includeParentEnvironment: false,
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );
    expect(resultado.exitCode, 0, reason: resultado.stderr.toString());
    return jsonDecode(resultado.stdout.toString()) as Map<String, dynamic>;
  }

  test(
      'ambiente prevalece, inclusive vazio; dotenv preserva aspas e interpolação',
      () async {
    final settings = await lerConfiguracao(comArquivo: true);
    expect(settings, {
      'GD_SEI_TEST_OVERRIDE': 'ambiente',
      'GD_SEI_TEST_EMPTY': '',
      'GD_SEI_TEST_QUOTED': 'olá mundo',
      'GD_SEI_TEST_BASE': 'base',
      'GD_SEI_TEST_INTERPOLATED': 'base/valor',
      'GD_SEI_TEST_ABSENT': null,
    });
  });

  test('sem .env usa o ambiente e retorna null para chave ausente', () async {
    final settings = await lerConfiguracao(comArquivo: false);
    expect(settings['GD_SEI_TEST_OVERRIDE'], 'ambiente');
    expect(settings['GD_SEI_TEST_EMPTY'], '');
    expect(settings['GD_SEI_TEST_QUOTED'], isNull);
    expect(settings['GD_SEI_TEST_ABSENT'], isNull);
  });
}

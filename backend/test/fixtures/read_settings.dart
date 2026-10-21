import 'dart:convert';

import '../../lib/config/settings.dart';

void main() {
  final settings = loadSettings();
  print(jsonEncode({
    for (final key in [
      'GD_SEI_TEST_OVERRIDE',
      'GD_SEI_TEST_EMPTY',
      'GD_SEI_TEST_QUOTED',
      'GD_SEI_TEST_BASE',
      'GD_SEI_TEST_INTERPOLATED',
      'GD_SEI_TEST_ABSENT',
    ])
      key: settings[key],
  }));
}

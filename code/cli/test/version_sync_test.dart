import 'dart:io';

import 'package:ape_cli/commands/version.dart';
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('version.dart matches pubspec.yaml', () {
    final pubspecFile = File('pubspec.yaml');
    expect(pubspecFile.existsSync(), isTrue,
        reason: 'pubspec.yaml must exist — run tests from code/cli/');
    final pubspec = loadYaml(pubspecFile.readAsStringSync()) as Map;
    final yamlVersion = pubspec['version'].toString();
    expect(apeVersion, equals(yamlVersion),
        reason:
            'version.dart ($apeVersion) must match pubspec.yaml ($yamlVersion)');
  });
}

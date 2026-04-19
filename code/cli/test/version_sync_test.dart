import 'dart:io';

import 'package:ape_cli/modules/global/commands/version.dart';
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

  test('site index.html badge matches pubspec.yaml version', () {
    final indexFile = File('../../code/site/index.html');
    expect(indexFile.existsSync(), isTrue,
        reason: 'code/site/index.html must exist');
    final html = indexFile.readAsStringSync();
    final match = RegExp(r'class="badge">v(\d+\.\d+\.\d+)').firstMatch(html);
    expect(match, isNotNull, reason: 'index.html must contain a version badge');
    final webVersion = match!.group(1)!;
    expect(apeVersion, equals(webVersion),
        reason:
            'index.html badge (v$webVersion) must match version.dart ($apeVersion)');
  });
}

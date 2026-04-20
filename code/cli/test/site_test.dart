import 'dart:io';

import 'package:test/test.dart';

/// Validates the structure and integrity of the code/site/ directory.
/// These tests ensure the site stays deployable and well-formed.
void main() {
  final siteDir = Directory('../../code/site');

  group('site directory structure', () {
    test('site directory exists', () {
      expect(siteDir.existsSync(), isTrue,
          reason: 'code/site/ must exist');
    });

    test('index.html exists', () {
      expect(File('${siteDir.path}/index.html').existsSync(), isTrue);
    });

    test('install.ps1 exists and is non-empty', () {
      final file = File('${siteDir.path}/install.ps1');
      expect(file.existsSync(), isTrue,
          reason: 'install.ps1 must exist for Windows install');
      expect(file.lengthSync(), greaterThan(0),
          reason: 'install.ps1 must not be empty');
    });

    test('install.sh exists and is non-empty', () {
      final file = File('${siteDir.path}/install.sh');
      expect(file.existsSync(), isTrue,
          reason: 'install.sh must exist for Linux install');
      expect(file.lengthSync(), greaterThan(0),
          reason: 'install.sh must not be empty');
    });
  });

  group('index.html structure', () {
    late String html;

    setUpAll(() {
      html = File('${siteDir.path}/index.html').readAsStringSync();
    });

    test('has DOCTYPE declaration', () {
      expect(html.trimLeft().startsWith('<!DOCTYPE html>'), isTrue,
          reason: 'index.html must start with <!DOCTYPE html>');
    });

    test('has lang attribute', () {
      expect(html, contains('lang="en"'),
          reason: 'html tag must have lang attribute');
    });

    test('has meta charset', () {
      expect(html, contains('charset="UTF-8"'));
    });

    test('has meta viewport', () {
      expect(html, contains('name="viewport"'));
    });

    test('has title', () {
      expect(RegExp(r'<title>.+</title>').hasMatch(html), isTrue,
          reason: 'index.html must have a non-empty <title>');
    });

    test('has meta description', () {
      expect(html, contains('name="description"'));
    });

    test('has Open Graph meta tags', () {
      expect(html, contains('property="og:title"'));
      expect(html, contains('property="og:description"'));
    });

    test('has version badge', () {
      expect(
          RegExp(r'class="badge">v\d+\.\d+\.\d+').hasMatch(html), isTrue,
          reason:
              'index.html must have a version badge matching '
              'pattern: <span class="badge">vX.Y.Z</span>');
    });

    test('references shared CSS', () {
      expect(html, contains('css/shared.css'));
    });

    test('has install commands for Windows and Linux', () {
      expect(html, contains('install.ps1'),
          reason: 'Must reference PowerShell install script');
      expect(html, contains('install.sh'),
          reason: 'Must reference Bash install script');
    });
  });

  group('secondary pages exist', () {
    for (final page in ['methodology.html', 'agents.html', 'evolution.html']) {
      test('$page exists', () {
        expect(File('${siteDir.path}/$page').existsSync(), isTrue,
            reason: '$page must exist in code/site/');
      });
    }
  });
}

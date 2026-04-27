import 'dart:io';

import 'package:inquiry_cli/modules/ape/inquiry_state.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmpDir;

  setUp(() {
    tmpDir = Directory.systemTemp.createTempSync('inquiry_state_test_');
    Directory('${tmpDir.path}/.inquiry').createSync(recursive: true);
  });

  tearDown(() {
    tmpDir.deleteSync(recursive: true);
  });

  group('InquiryState.load', () {
    test('returns IDLE when state.yaml is missing', () {
      final state = InquiryState.load(tmpDir.path);
      expect(state.state, equals('IDLE'));
      expect(state.issue, isNull);
      expect(state.apeName, isNull);
      expect(state.apeState, isNull);
    });

    test('reads basic state and issue', () {
      File('${tmpDir.path}/.inquiry/state.yaml')
          .writeAsStringSync('state: ANALYZE\nissue: "145"\nape: null\n');

      final state = InquiryState.load(tmpDir.path);
      expect(state.state, equals('ANALYZE'));
      expect(state.issue, equals('145'));
      expect(state.apeName, isNull);
    });

    test('reads state with ape field', () {
      File('${tmpDir.path}/.inquiry/state.yaml').writeAsStringSync(
        'state: ANALYZE\n'
        'issue: "145"\n'
        'ape:\n'
        '  name: socrates\n'
        '  state: clarification\n',
      );

      final state = InquiryState.load(tmpDir.path);
      expect(state.state, equals('ANALYZE'));
      expect(state.issue, equals('145'));
      expect(state.apeName, equals('socrates'));
      expect(state.apeState, equals('clarification'));
    });

    test('reads integer issue as string', () {
      File('${tmpDir.path}/.inquiry/state.yaml')
          .writeAsStringSync('state: PLAN\nissue: 99\nape: null\n');

      final state = InquiryState.load(tmpDir.path);
      expect(state.issue, equals('99'));
    });

    test('handles null issue', () {
      File('${tmpDir.path}/.inquiry/state.yaml')
          .writeAsStringSync('state: IDLE\nissue: null\nape: null\n');

      final state = InquiryState.load(tmpDir.path);
      expect(state.issue, isNull);
    });

    test('backward compat: reads old format without ape field', () {
      File('${tmpDir.path}/.inquiry/state.yaml')
          .writeAsStringSync('state: PLAN\nissue: "42"\n');

      final state = InquiryState.load(tmpDir.path);
      expect(state.state, equals('PLAN'));
      expect(state.issue, equals('42'));
      expect(state.apeName, isNull);
      expect(state.apeState, isNull);
    });
  });

  group('InquiryState.save', () {
    test('writes full format with ape field', () {
      const state = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      state.save(tmpDir.path);

      final content =
          File('${tmpDir.path}/.inquiry/state.yaml').readAsStringSync();
      expect(content, contains('state: ANALYZE'));
      expect(content, contains('issue: "145"'));
      expect(content, contains('ape:'));
      expect(content, contains('  name: socrates'));
      expect(content, contains('  state: clarification'));
    });

    test('writes ape: null when no APE', () {
      const state = InquiryState(state: 'IDLE');
      state.save(tmpDir.path);

      final content =
          File('${tmpDir.path}/.inquiry/state.yaml').readAsStringSync();
      expect(content, contains('state: IDLE'));
      expect(content, contains('issue: null'));
      expect(content, contains('ape: null'));
    });

    test('roundtrips correctly', () {
      const original = InquiryState(
        state: 'EXECUTE',
        issue: '200',
        apeName: 'basho',
        apeState: 'implement',
      );
      original.save(tmpDir.path);

      final loaded = InquiryState.load(tmpDir.path);
      expect(loaded.state, equals('EXECUTE'));
      expect(loaded.issue, equals('200'));
      expect(loaded.apeName, equals('basho'));
      expect(loaded.apeState, equals('implement'));
    });
  });

  group('InquiryState.copyWith', () {
    test('copies with new state', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(state: 'PLAN');

      expect(copy.state, equals('PLAN'));
      expect(copy.issue, equals('145'));
      expect(copy.apeName, equals('socrates'));
      expect(copy.apeState, equals('clarification'));
    });

    test('copies with new apeState', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(apeState: 'assumptions');

      expect(copy.apeState, equals('assumptions'));
      expect(copy.apeName, equals('socrates'));
    });

    test('clearApe removes ape fields', () {
      const original = InquiryState(
        state: 'ANALYZE',
        issue: '145',
        apeName: 'socrates',
        apeState: 'clarification',
      );
      final copy = original.copyWith(clearApe: true);

      expect(copy.state, equals('ANALYZE'));
      expect(copy.issue, equals('145'));
      expect(copy.apeName, isNull);
      expect(copy.apeState, isNull);
    });
  });
}

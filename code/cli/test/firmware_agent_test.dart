import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('inquiry.agent.md firmware', () {
    late String content;

    setUpAll(() {
      content = File('assets/agents/inquiry.agent.md').readAsStringSync();
    });

    test('references iq fsm state', () {
      expect(content, contains('iq fsm state'));
    });

    test('references iq ape state', () {
      expect(content, contains('iq ape state'));
    });

    test('references iq ape prompt', () {
      expect(content, contains('iq ape prompt'));
    });

    test('references iq ape transition', () {
      expect(content, contains('iq ape transition'));
    });

    test('references iq fsm transition', () {
      expect(content, contains('iq fsm transition'));
    });

    test('is thin: under 60 lines (excluding frontmatter)', () {
      final lines = content.split('\n');
      // Skip YAML frontmatter (between --- markers)
      var bodyStart = 0;
      if (lines.isNotEmpty && lines[0].trim() == '---') {
        for (var i = 1; i < lines.length; i++) {
          if (lines[i].trim() == '---') {
            bodyStart = i + 1;
            break;
          }
        }
      }
      final bodyLines = lines.sublist(bodyStart);
      expect(bodyLines.length, lessThan(60),
          reason: 'Firmware body should be under 60 lines, got ${bodyLines.length}');
    });

    test('does NOT contain sub-agent prompts (no monolith leakage)', () {
      // These are sub-agent-specific content that should NOT be in firmware
      expect(content, isNot(contains('epistemic humility')),
          reason: 'Firmware should not contain SOCRATES prompt details');
      expect(content, isNot(contains('用の美')),
          reason: 'Firmware should not contain BASHŌ prompt details');
      expect(content, isNot(contains('Socratic method')),
          reason: 'Firmware should not contain SOCRATES methodology');
      expect(content, isNot(contains('natural selection')),
          reason: 'Firmware should not contain DARWIN methodology');
    });

    test('contains dual FSM structure (outer + inner loop)', () {
      expect(content, contains('Outer Loop'));
      expect(content, contains('Inner Loop'));
    });

    test('mentions _DONE sentinel', () {
      expect(content, contains('_DONE'));
    });

    test('forbids direct writes to .inquiry/', () {
      expect(content, contains('NEVER'));
      expect(content, contains('.inquiry/'));
    });
  });
}

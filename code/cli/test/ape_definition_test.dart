import 'dart:io';

import 'package:inquiry_cli/modules/ape/ape_definition.dart';
import 'package:test/test.dart';

void main() {
  group('ApeDefinition', () {
    group('schema validation', () {
      for (final apeName in ['socrates', 'descartes', 'basho', 'darwin']) {
        test('$apeName.yaml parses into valid ApeDefinition', () {
          final yaml = File('assets/apes/$apeName.yaml').readAsStringSync();
          final def = ApeDefinition.parse(yaml);

          expect(def.name, equals(apeName));
          expect(def.version, equals('0.2.0'));
          expect(def.description, isNotEmpty);
          expect(def.basePrompt, isNotEmpty);
          expect(def.initialState, isNotEmpty);
          expect(def.states, isNotEmpty);

          // initial_state must reference a defined state
          expect(def.findState(def.initialState), isNotNull,
              reason: '$apeName.initial_state "${def.initialState}" not found in states');

          for (final state in def.states) {
            expect(state.name, isNotEmpty, reason: '$apeName has empty state name');
            expect(state.description, isNotEmpty, reason: '$apeName.${state.name} has empty description');
            expect(state.prompt, isNotEmpty, reason: '$apeName.${state.name} has empty prompt');
            expect(state.transitions, isNotEmpty, reason: '$apeName.${state.name} has no transitions');

            // All transition targets must be defined states or _DONE
            for (final t in state.transitions) {
              expect(
                t.to == '_DONE' || def.findState(t.to) != null,
                isTrue,
                reason: '$apeName.${state.name} transition "${t.event}" targets unknown state "${t.to}"',
              );
            }
          }
        });
      }
    });

    group('state counts', () {
      test('socrates has 6 states', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        expect(def.states.length, equals(6));
        final names = def.states.map((s) => s.name).toList();
        expect(names, containsAll([
          'clarification', 'assumptions', 'evidence',
          'perspectives', 'implications', 'meta_reflection',
        ]));
      });

      test('descartes has 4 states', () {
        final def = ApeDefinition.parse(
          File('assets/apes/descartes.yaml').readAsStringSync(),
        );
        expect(def.states.length, equals(4));
        final names = def.states.map((s) => s.name).toList();
        expect(names, containsAll([
          'decomposition', 'ordering', 'verification', 'enumeration',
        ]));
      });

      test('basho has 3 states', () {
        final def = ApeDefinition.parse(
          File('assets/apes/basho.yaml').readAsStringSync(),
        );
        expect(def.states.length, equals(3));
        final names = def.states.map((s) => s.name).toList();
        expect(names, containsAll(['implement', 'test', 'commit']));
      });

      test('darwin has 4 states', () {
        final def = ApeDefinition.parse(
          File('assets/apes/darwin.yaml').readAsStringSync(),
        );
        expect(def.states.length, equals(4));
        final names = def.states.map((s) => s.name).toList();
        expect(names, containsAll(['observe', 'compare', 'select', 'report']));
      });
    });

    group('assemblePrompt', () {
      test('returns base_prompt when no state specified', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        final prompt = def.assemblePrompt();
        expect(prompt, equals(def.basePrompt));
      });

      test('returns base_prompt + state prompt for given state', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        final prompt = def.assemblePrompt(stateName: 'clarification');
        expect(prompt, startsWith(def.basePrompt));
        expect(prompt, contains('Clarification questions'));
      });

      test('throws for unknown state', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        expect(
          () => def.assemblePrompt(stateName: 'nonexistent'),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('prompt fidelity', () {
      test('socrates base_prompt contains Socratic method keywords', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        expect(def.basePrompt, contains('SOCRATES'));
        expect(def.basePrompt, contains('Socratic method'));
        expect(def.basePrompt, contains('EPISTEMIC HUMILITY'));
        expect(def.basePrompt, contains('diagnosis.md'));
      });

      test('descartes base_prompt contains Cartesian method keywords', () {
        final def = ApeDefinition.parse(
          File('assets/apes/descartes.yaml').readAsStringSync(),
        );
        expect(def.basePrompt, contains('DESCARTES'));
        expect(def.basePrompt, contains('scientific method'));
        expect(def.basePrompt, contains('EVIDENCE'));
        expect(def.basePrompt, contains('plan.md'));
      });

      test('basho base_prompt contains implementation keywords', () {
        final def = ApeDefinition.parse(
          File('assets/apes/basho.yaml').readAsStringSync(),
        );
        expect(def.basePrompt, contains('BASHŌ'));
        expect(def.basePrompt, contains('用の美'));
        expect(def.basePrompt, contains('NOTHING WASTED'));
        expect(def.basePrompt, contains('retrospective.md'));
      });

      test('darwin base_prompt contains evolution keywords', () {
        final def = ApeDefinition.parse(
          File('assets/apes/darwin.yaml').readAsStringSync(),
        );
        expect(def.basePrompt, contains('DARWIN'));
        expect(def.basePrompt, contains('natural selection'));
        expect(def.basePrompt, contains('mutations.md'));
        expect(def.basePrompt, contains('metrics.yaml'));
      });
    });

    group('initial_state', () {
      test('socrates starts at clarification', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        expect(def.initialState, equals('clarification'));
      });

      test('descartes starts at decomposition', () {
        final def = ApeDefinition.parse(
          File('assets/apes/descartes.yaml').readAsStringSync(),
        );
        expect(def.initialState, equals('decomposition'));
      });

      test('basho starts at implement', () {
        final def = ApeDefinition.parse(
          File('assets/apes/basho.yaml').readAsStringSync(),
        );
        expect(def.initialState, equals('implement'));
      });

      test('darwin starts at observe', () {
        final def = ApeDefinition.parse(
          File('assets/apes/darwin.yaml').readAsStringSync(),
        );
        expect(def.initialState, equals('observe'));
      });
    });

    group('transitions', () {
      test('_DONE is reachable from every APE', () {
        for (final apeName in ['socrates', 'descartes', 'basho', 'darwin']) {
          final def = ApeDefinition.parse(
            File('assets/apes/$apeName.yaml').readAsStringSync(),
          );
          final hasDone = def.states.any(
            (s) => s.transitions.any((t) => t.to == '_DONE'),
          );
          expect(hasDone, isTrue, reason: '$apeName has no transition to _DONE');
        }
      });

      test('socrates has linear next chain ending at _DONE', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        // Walk the chain: clarification → assumptions → ... → meta_reflection → _DONE
        var current = def.initialState;
        final visited = <String>{};
        while (current != '_DONE') {
          expect(visited.add(current), isTrue, reason: 'cycle detected at $current');
          final state = def.findState(current)!;
          final next = state.transitions.firstWhere((t) => t.event == 'next' || t.event == 'complete');
          current = next.to;
        }
        expect(visited.length, equals(6)); // all 6 states visited
      });

      test('basho has fail loop from test back to implement', () {
        final def = ApeDefinition.parse(
          File('assets/apes/basho.yaml').readAsStringSync(),
        );
        final testState = def.findState('test')!;
        final failTransition = testState.transitions.firstWhere((t) => t.event == 'fail');
        expect(failTransition.to, equals('implement'));
      });

      test('findState returns null for unknown state', () {
        final def = ApeDefinition.parse(
          File('assets/apes/socrates.yaml').readAsStringSync(),
        );
        expect(def.findState('nonexistent'), isNull);
      });
    });
  });
}

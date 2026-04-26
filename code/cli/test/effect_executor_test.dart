import 'dart:io';

import 'package:inquiry_cli/modules/fsm/effect_executor.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('effect_executor_test_');
    Directory('${tempDir.path}/.inquiry').createSync(recursive: true);
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  group('EffectExecutor', () {
    group('update_state', () {
      test('writes new state and issue to state.yaml', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: IDLE\nissue: null\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('ANALYZE', issue: '145');

        final content =
            File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('issue: "145"'));
      });

      test('preserves issue when not provided', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: ANALYZE\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('PLAN');

        final content =
            File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
        expect(content, contains('state: PLAN'));
        expect(content, contains('issue: "145"'));
      });

      test('clears issue when transitioning to IDLE', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.updateState('IDLE');

        final content =
            File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
        expect(content, contains('state: IDLE'));
        expect(content, contains('issue: null'));
      });
    });

    group('reset_mutations', () {
      test('resets mutations.md to empty template', () {
        File('${tempDir.path}/.inquiry/mutations.md').writeAsStringSync(
          '# Mutations\n\nNotes for DARWIN.\n- old observation\n- another one\n',
        );

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.resetMutations();

        final content =
            File('${tempDir.path}/.inquiry/mutations.md').readAsStringSync();
        expect(content, contains('# Mutations'));
        expect(content, contains('Notes for DARWIN'));
        expect(content, isNot(contains('old observation')));
      });

      test('creates mutations.md if missing', () {
        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.resetMutations();

        expect(
          File('${tempDir.path}/.inquiry/mutations.md').existsSync(),
          isTrue,
        );
      });
    });

    group('snapshot_metrics', () {
      test('creates metrics_snapshot.yaml with timestamp', () {
        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.snapshotMetrics();

        final file = File('${tempDir.path}/.inquiry/metrics_snapshot.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(content, contains('snapshot_at:'));
        expect(content, contains('state: IDLE'));
      });

      test('captures current state in snapshot', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: ANALYZE\nissue: "99"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.snapshotMetrics();

        final content =
            File('${tempDir.path}/.inquiry/metrics_snapshot.yaml')
                .readAsStringSync();
        expect(content, contains('state: ANALYZE'));
        expect(content, contains('issue: "99"'));
      });
    });

    group('close_cycle', () {
      test('resets state to IDLE and clears issue', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.closeCycle();

        final content =
            File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
        expect(content, contains('state: IDLE'));
        expect(content, contains('issue: null'));
      });
    });

    group('collect_metrics', () {
      test('appends cycle entry to metrics.yaml', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.collectMetrics();

        final file = File('${tempDir.path}/.inquiry/metrics.yaml');
        expect(file.existsSync(), isTrue);

        final content = file.readAsStringSync();
        expect(content, contains('issue: "145"'));
        expect(content, contains('completed_at:'));
      });

      test('appends to existing metrics.yaml', () {
        File('${tempDir.path}/.inquiry/metrics.yaml')
            .writeAsStringSync('cycles:\n  - issue: "100"\n');
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: EVOLUTION\nissue: "145"\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        executor.collectMetrics();

        final content =
            File('${tempDir.path}/.inquiry/metrics.yaml').readAsStringSync();
        expect(content, contains('issue: "100"'));
        expect(content, contains('issue: "145"'));
      });
    });

    group('executeAll', () {
      test('executes multiple effects in order', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: IDLE\nissue: null\n');
        File('${tempDir.path}/.inquiry/mutations.md')
            .writeAsStringSync('# Mutations\n- old stuff\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        final executed = executor.executeAll(
          effects: ['reset_mutations', 'snapshot_metrics'],
          newState: 'ANALYZE',
          issue: '145',
        );

        expect(executed, containsAll(['update_state', 'reset_mutations', 'snapshot_metrics']));

        // State updated
        final stateContent =
            File('${tempDir.path}/.inquiry/state.yaml').readAsStringSync();
        expect(stateContent, contains('state: ANALYZE'));

        // Mutations reset
        final mutContent =
            File('${tempDir.path}/.inquiry/mutations.md').readAsStringSync();
        expect(mutContent, isNot(contains('old stuff')));
      });

      test('skips unknown effects gracefully', () {
        File('${tempDir.path}/.inquiry/state.yaml')
            .writeAsStringSync('state: IDLE\nissue: null\n');

        final executor = EffectExecutor(workingDirectory: tempDir.path);
        final executed = executor.executeAll(
          effects: ['open_analysis_context', 'noop', 'push_branch'],
          newState: 'ANALYZE',
        );

        // Only update_state is a CLI effect; the rest are skill-side
        expect(executed, contains('update_state'));
        expect(executed, isNot(contains('open_analysis_context')));
      });
    });
  });
}

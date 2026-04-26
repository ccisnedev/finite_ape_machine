/// Reads and writes `.inquiry/state.yaml` including the `ape:` field.
library;

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Represents the full contents of `.inquiry/state.yaml`.
class InquiryState {
  final String state;
  final String? issue;
  final String? apeName;
  final String? apeState;

  const InquiryState({
    required this.state,
    this.issue,
    this.apeName,
    this.apeState,
  });

  /// Read from `.inquiry/state.yaml` in [workingDirectory].
  static InquiryState load(String workingDirectory) {
    final file = File(p.join(workingDirectory, '.inquiry', 'state.yaml'));
    if (!file.existsSync()) {
      return const InquiryState(state: 'IDLE');
    }

    final yaml = loadYaml(file.readAsStringSync());
    if (yaml is! YamlMap) {
      return const InquiryState(state: 'IDLE');
    }

    final state = (yaml['state'] as String?) ?? 'IDLE';
    final rawIssue = yaml['issue'];
    final issue = (rawIssue is String && rawIssue.isNotEmpty) ? rawIssue
        : (rawIssue is int) ? rawIssue.toString()
        : null;

    String? apeName;
    String? apeState;
    final apeMap = yaml['ape'];
    if (apeMap is YamlMap) {
      apeName = apeMap['name'] as String?;
      apeState = apeMap['state'] as String?;
    }

    return InquiryState(
      state: state,
      issue: issue,
      apeName: apeName,
      apeState: apeState,
    );
  }

  /// Write to `.inquiry/state.yaml` in [workingDirectory].
  void save(String workingDirectory) {
    final file = File(p.join(workingDirectory, '.inquiry', 'state.yaml'));
    final buf = StringBuffer();
    buf.writeln('state: $state');
    buf.writeln(issue != null ? 'issue: "$issue"' : 'issue: null');
    if (apeName != null) {
      buf.writeln('ape:');
      buf.writeln('  name: $apeName');
      buf.writeln('  state: ${apeState ?? "null"}');
    } else {
      buf.writeln('ape: null');
    }
    file.writeAsStringSync(buf.toString());
  }

  InquiryState copyWith({
    String? state,
    String? issue,
    String? apeName,
    String? apeState,
    bool clearApe = false,
  }) {
    return InquiryState(
      state: state ?? this.state,
      issue: issue ?? this.issue,
      apeName: clearApe ? null : (apeName ?? this.apeName),
      apeState: clearApe ? null : (apeState ?? this.apeState),
    );
  }
}

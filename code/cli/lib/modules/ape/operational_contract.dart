library;

import 'dart:io';

import 'package:cli_router/cli_router.dart';
import 'package:modular_cli_sdk/modular_cli_sdk.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import '../../assets.dart';
import '../../fsm_contract.dart';

class OperationalContract {
  final FsmState state;
  final String instructions;
  final List<String> constraints;
  final List<String> allowedActions;

  const OperationalContract({
    required this.state,
    required this.instructions,
    required this.constraints,
    required this.allowedActions,
  });

  Map<String, dynamic> toJson() => {
    'state': state.value,
    'instructions': instructions,
    'constraints': constraints,
    'allowed_actions': allowedActions,
  };

  String render() {
    final buffer = StringBuffer()
      ..writeln('## Phase-Owned Operational Contract')
      ..writeln('State: ${state.value}')
      ..writeln()
      ..writeln('Mission:')
      ..writeln(instructions.trim());

    if (constraints.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Constraints:');
      for (final constraint in constraints) {
        buffer.writeln('- $constraint');
      }
    }

    if (allowedActions.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Allowed actions:');
      for (final action in allowedActions) {
        buffer.writeln('- $action');
      }
    }

    return buffer.toString().trimRight();
  }
}

class OperationalContractLoader {
  final String workingDirectory;
  final Assets? assets;

  const OperationalContractLoader({
    required this.workingDirectory,
    this.assets,
  });

  OperationalContract load(FsmState state) {
    final stateName = state.value.toLowerCase();
    final yamlPath = assets != null
        ? assets!.path('fsm/states/$stateName.yaml')
        : p.join(workingDirectory, 'assets', 'fsm', 'states', '$stateName.yaml');

    final yaml = _readYamlMap(yamlPath, stateName);
    final instructions = _readStringField(
      yaml,
      fieldName: 'instructions',
      stateName: stateName,
    );
    final constraints = _readStringListField(
      yaml,
      fieldName: 'constraints',
      stateName: stateName,
    );
    final allowedActions = _readStringListField(
      yaml,
      fieldName: 'allowed_actions',
      stateName: stateName,
    );

    return OperationalContract(
      state: state,
      instructions: instructions.trim(),
      constraints: constraints,
      allowedActions: allowedActions,
    );
  }

  YamlMap _readYamlMap(String yamlPath, String stateName) {
    try {
      final yaml = loadYaml(File(yamlPath).readAsStringSync());
      if (yaml is YamlMap) {
        return yaml;
      }
      throw _malformedStateYaml(stateName, 'root mapping');
    } on PathNotFoundException {
      throw _missingStateYaml(stateName);
    } on FileSystemException {
      throw _missingStateYaml(stateName);
    }
  }

  String _readStringField(
    YamlMap yaml, {
    required String fieldName,
    required String stateName,
  }) {
    final value = yaml[fieldName];
    if (value is String && value.trim().isNotEmpty) {
      return value;
    }
    throw _malformedStateYaml(stateName, fieldName);
  }

  List<String> _readStringListField(
    YamlMap yaml, {
    required String fieldName,
    required String stateName,
  }) {
    final value = yaml[fieldName];
    if (value is YamlList) {
      return value.cast<String>().toList(growable: false);
    }
    throw _malformedStateYaml(stateName, fieldName);
  }

  CommandException _missingStateYaml(String stateName) {
    return CommandException(
      code: 'MISSING_STATE_YAML',
      message: "State instructions missing for '$stateName'. Run 'iq doctor --fix' to repair.",
      exitCode: ExitCode.genericError,
    );
  }

  CommandException _malformedStateYaml(String stateName, String fieldName) {
    return CommandException(
      code: 'MALFORMED_STATE_YAML',
      message: "State file for '$stateName' is missing '$fieldName' field. Run 'iq doctor --fix' to repair.",
      exitCode: ExitCode.genericError,
    );
  }
}
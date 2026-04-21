/// Entry point for the `inquiry` CLI.
///
/// Delegates immediately to [runInquiry] to keep the binary thin and testable.
library;

import 'dart:io';

import 'package:inquiry_cli/inquiry_cli.dart';

Future<void> main(List<String> args) async {
  final code = await runInquiry(args);
  exit(code);
}

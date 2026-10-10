import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:typr/src/interpreter/interpreter.dart';
import 'package:typr/src/parser/parser.dart';
import 'package:typr/src/scanner/scanner.dart';

class RunCommand extends Command {
  @override
  String get name => 'run';
  @override
  String get description => 'Runs a Typr application.';

  @override
  String get usage => 'typr run <typr-file>';

  @override
  void run() {
    final typrFileArg = argResults?.rest ?? [];
    if (typrFileArg.isEmpty) {
      throw UsageException('No Typr file specified.', usage);
    }
    final typrFile = File(typrFileArg.first);
    final source = typrFile.readAsStringSync();

    final scanner = Scanner(source);
    final tokens = scanner.scanTokens();

    final parser = Parser(tokens);
    final statements = parser.parse();

    final interpreter = Interpreter();
    interpreter.interpret(statements);
  }
}

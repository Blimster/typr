import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:typr/src/error_handling/error_handling.dart';
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

  RunCommand() {
    argParser.addFlag(
      'time',
      abbr: 't',
      negatable: false,
      help: 'Displays the execution time of the Typr application.',
    );
  }

  @override
  void run() {
    final timeArg = argResults?['time'] ?? false;
    final typrFileArg = argResults?.rest ?? [];

    if (typrFileArg.isEmpty) {
      throw UsageException('No Typr file specified.', usage);
    }

    final typrFile = File(typrFileArg.first);
    final source = typrFile.readAsStringSync();

    final errorHandler = ConsoleErrorHandler();

    final sw = Stopwatch()..start();

    try {
      final scanner = Scanner(source, errorHandler);
      final tokens = scanner.scanTokens();

      if (errorHandler.hadError) {
        return;
      }

      final parser = Parser(tokens, errorHandler);
      final statements = parser.parse();

      if (errorHandler.hadError) {
        return;
      }

      final interpreter = Interpreter(errorHandler);
      interpreter.interpret(statements);
    } finally {
      sw.stop();

      if (timeArg) {
        stdout.writeln();
        print('Execution time: ${sw.elapsedMicroseconds / 1000.0} ms');
      }

      if (errorHandler.hadError) {
        exit(70);
      }
    }
  }
}

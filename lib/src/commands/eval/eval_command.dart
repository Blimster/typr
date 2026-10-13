import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:typr/src/error_handling/error_handling.dart';
import 'package:typr/src/interpreter/interpreter.dart';
import 'package:typr/src/model/statement.dart';
import 'package:typr/src/parser/parser.dart';
import 'package:typr/src/scanner/scanner.dart';

class EvalCommand extends Command {
  @override
  String get name => 'eval';
  @override
  String get description => 'Evaluates Typr expressions.';

  @override
  void run() {
    while (true) {
      stdout.write('Enter a single expression to evaluate: ');
      final source = stdin.readLineSync();
      if (source != null && source.isNotEmpty) {
        final errorHandler = ConsoleErrorHandler();
        final scanner = Scanner(source, errorHandler);
        final tokens = scanner.scanTokens();

        if (errorHandler.hadError) {
          continue;
        }

        final parser = Parser(tokens, errorHandler);
        final statements = parser.parse();

        if (errorHandler.hadError) {
          continue;
        }

        if (statements.isNotEmpty) {
          final firstStatement = statements.first;
          if (firstStatement is ExpressionStatement) {
            final expression = firstStatement.expression;
            final interpreter = Interpreter();
            final result = expression.accept(interpreter);
            print('Expression result: $result');
          } else {
            print('Error: Input is not a single expression.');
          }
        } else {
          print('Error: Input is not a single expression.');
        }
      } else {
        break;
      }
    }
  }
}

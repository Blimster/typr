import 'dart:io';

import 'package:args/command_runner.dart';
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
        final scanner = Scanner(source);
        final tokens = scanner.scanTokens();

        final parser = Parser(tokens);
        final statements = parser.parse();

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

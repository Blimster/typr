import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:typr/src/commands/parse/ast_printer.dart';
import 'package:typr/src/parser/parser.dart';
import 'package:typr/src/scanner/scanner.dart';

class ParseCommand extends Command {
  @override
  String get name => 'parse';

  @override
  String get description => 'Parses the input into an abstract syntax tree.';

  @override
  void run() {
    while (true) {
      stdout.write('Enter source code to parse: ');
      final source = stdin.readLineSync();
      if (source != null && source.isNotEmpty) {
        final scanner = Scanner(source);
        final tokens = scanner.scanTokens();

        final parser = Parser(tokens);
        final expression = parser.parse();

        final ast = expression.accept(AstPrinter());
        print('AST parsed: $ast');
      } else {
        break;
      }
    }
  }
}

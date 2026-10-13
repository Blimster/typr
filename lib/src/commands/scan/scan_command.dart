import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:typr/src/error_handling/error_handling.dart';
import 'package:typr/src/scanner/scanner.dart';

class ScanCommand extends Command {
  @override
  String get name => 'scan';

  @override
  String get description => 'Scans the given input and prints the resulting tokens.';

  @override
  void run() {
    while (true) {
      stdout.write('Enter source code to scan: ');
      final source = stdin.readLineSync();
      if (source != null && source.isNotEmpty) {
        final errorHandler = ConsoleErrorHandler();
        final scanner = Scanner(source, errorHandler);
        final tokens = scanner.scanTokens();
        if (!errorHandler.hadError) {
          print('Tokens scanned: $tokens');
        }
      } else {
        break;
      }
    }
  }
}

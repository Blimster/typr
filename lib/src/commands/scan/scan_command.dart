import 'dart:io';

import 'package:args/command_runner.dart';
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
        final scanner = Scanner(source);
        final tokens = scanner.scanTokens();
        print('Tokens scanned: $tokens');
      } else {
        break;
      }
    }
  }
}

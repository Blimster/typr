import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:typr/src/commands/parse/parse_command.dart';
import 'package:typr/src/commands/scan/scan_command.dart';

CommandRunner buildCommandRunner() {
  final runner = CommandRunner(
    'typr',
    'A command-line utility for Typr development.',
  );
  runner.addCommand(ScanCommand());
  runner.addCommand(ParseCommand());
  return runner;
}

void printUsage(ArgParser argParser) {
  print('Usage: typr <flags> [arguments]');
  print(argParser.usage);
}

void typr(List<String> args) async {
  final runner = buildCommandRunner();
  await runner.run(args);
}

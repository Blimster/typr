import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:typr/src/commands/eval/eval_command.dart';
import 'package:typr/src/commands/run/run_command.dart';
import 'package:typr/src/commands/scan/scan_command.dart';

CommandRunner buildCommandRunner() {
  final runner = CommandRunner(
    'typr',
    'A command-line utility for Typr development.',
  );
  runner.addCommand(ScanCommand());
  runner.addCommand(EvalCommand());
  runner.addCommand(RunCommand());
  return runner;
}

void printUsage(ArgParser argParser) {
  print('Usage: typr <flags> [arguments]');
  print(argParser.usage);
}

void typr(List<String> args) async {
  try {
    final runner = buildCommandRunner();
    await runner.run(args);
  } on UsageException catch (e) {
    print(e.message);
    print('');
    print('Usage: ${e.usage}');
  }
}

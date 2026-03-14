import 'package:args/args.dart';

abstract class AppCommand {
  const AppCommand();

  String get name;

  void execute(ArgResults command, bool verbose);

  ArgParser buildParser();
}

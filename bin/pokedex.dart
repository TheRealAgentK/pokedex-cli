import 'package:args/args.dart';

const String version = '0.1.0';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.');
}

void printUsage(ArgParser argParser) {
  print('Pokédex CLI: $version');
  print('');
  print('Usage: pokedex <command> <arguments>');
  print(argParser.usage);
  print('');
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    if (results.wasParsed('help') || arguments.isEmpty) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('pokedex version: $version');
      return;
    }

    throw FormatException('Unknown or missing command.');
  } on FormatException catch (e) {
    print('Error: ${e.message}');
    print('');
    printUsage(argParser);
  }
}

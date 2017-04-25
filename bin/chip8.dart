import 'dart:io';
import 'package:args/args.dart';
import 'package:chip8/io.dart';

final ArgParser ARG_PARSER = new ArgParser(allowTrailingOptions: true)
  ..addFlag('help',
      abbr: 'h',
      help: 'Print this help information.',
      defaultsTo: false,
      negatable: false);

main(List<String> args) async {
  try {
    var result = ARG_PARSER.parse(args);

    if (result['help']) {
      stdout
        ..writeln('usage: chip8 [options] <input file>')
        ..writeln(ARG_PARSER.usage);
      return;
    } else if (result.rest.isEmpty) {
      throw new ArgParserException('no input file');
    } else {
      var file = new File(result.rest.first);
      var program = await file.readAsBytes();
      var vm = createVm();
      await vm.execute(program);
    }
  } on ArgParserException catch (e) {
    stderr
      ..writeln('fatal error: ${e.message}')
      ..writeln('usage: chip8 [options] <input file>')
      ..writeln(ARG_PARSER.usage);
    exit(1);
  } catch (e) {
    stderr.writeln(e);
    exit(1);
  }
}

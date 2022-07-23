import 'dart:io';
import 'package:mfcc_bee/options/create.dart';
import 'package:mfcc_bee/tests/execute/execute.dart';

void main(List<String> args) async {
  String pathTests = '${Directory.current.path}/stack_tests',
      pathCSVs = '${Directory.current.path}/CSVs';

  if (args.isNotEmpty) {
    if (args[0] == '--help' || args[0] == '-h') {
      if (File('${Directory.current.path}/lib/tests/utils/helper')
          .existsSync()) {
        print(
          File('${Directory.current.path}/lib/tests/utils/helper')
              .readAsStringSync(),
        );
      } else {
        try {
          print(
            File('${Directory.current.path}/helper').readAsStringSync(),
          );
        } catch (e) {
          print("No helper");
        }
      }
    }

    if (args[0] == '--create' || args[0] == '-c') {
      createTest(pathTests);
    }

    if (args[0] == 'execute') {
      if (true) {
        Directory testsDirectory = Directory(pathTests);

        if (!testsDirectory.existsSync()) {
          throw Error.safeToString(
              "Error: No tests! Please run 'zumbeedo -c' for create!");
        }

        Execute(
          pathCSVs: pathCSVs,
          pathTests: pathTests,
        ).run();
      }
    }
  } else {
    print("Run 'zumbeedo -h'");
  }
}

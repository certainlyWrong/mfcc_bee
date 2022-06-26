import 'dart:io';

import 'package:mfcc_bee/options/create.dart';

void main(List<String> args) async {
  String pathTests = '${Directory.current.path}/stack_tests';

  if (args[0] == '--help' || args[0] == '-h') {
    print(
      File('${Directory.current.path}/lib/tests/utils/helper')
          .readAsStringSync(),
    );
  }

  if (args[0] == '--create' || args[0] == '-c') {
    createTest(pathTests);
  }
}

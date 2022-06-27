import 'dart:io';
import 'dart:convert';

void createTest(String pathTests) async {
  Directory tests = Directory(pathTests);

  if (!tests.existsSync()) {
    tests.createSync();
  }

  List<String> args = [
    "version",
    "quant",
    "hopSize",
    "dctFilterNum",
    "fftSize",
    "melFilterNum",
    "fftVersion",
    "hannVersion",
    "beePath",
    "noBeePath",
  ];

  Map<String, dynamic> jsonAux = {};

  if (!tests.existsSync()) {
    tests.create();
  }

  print("::::New test::::");
  for (var i = 0; i < args.length; i++) {
    stdout.write('||| ${args[i]}: ');
    if (i < 8) {
      jsonAux.addAll(
        {
          args[i]: int.parse(
              stdin.readLineSync(encoding: utf8, retainNewlines: false) ?? '0')
        },
      );
    } else {
      jsonAux.addAll(
        {args[i]: stdin.readLineSync(encoding: utf8, retainNewlines: false)},
      );
    }
  }

  jsonAux.addAll(
    {
      "name": "bee_${DateTime.now().toIso8601String()}",
      "time_run": null,
      "time_total_run": null,
      "date": DateTime.now().toIso8601String(),
      "date_run": null,
    },
  );

  File("$pathTests/${jsonAux['name']}.json")
    ..createSync()
    ..writeAsStringSync(jsonEncode(jsonAux));
}

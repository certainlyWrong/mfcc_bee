import 'dart:io';
import 'dart:convert';

void createTest(String pathTests) {
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

  print(!tests.existsSync());
  if (!tests.existsSync()) {
    tests.create();
  }

  print("::::New test::::");
  for (var i = 0; i < args.length; i++) {
    print('$i - ${args[i]}: ');
    if (i < 7) {
      int aux = 0;
      while (aux != 0) {
        try {
          aux = int.parse(stdin.readLineSync() ?? '0');
        } catch (e) {
          print("Error: not number!");
        }
      }
      jsonAux.addAll({args[i]: aux});
    } else {
      jsonAux.addAll({args[i]: stdin.readLineSync()});
    }
  }
  File("$pathTests/${jsonAux['version']}.json")
    ..createSync()
    ..writeAsStringSync("aaaaaaaaa");
}

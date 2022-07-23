import 'dart:io';
import 'dart:convert';
import 'dart:isolate';
import 'package:mfcc_bee/tests/tests_type/test_local.dart';

class Execute {
  List<Future> awaits = [];
  final String pathCSVs, pathTests;
  Map<ReceivePort, Isolate> process = {};
  List<ReceivePort> processComunicate = [];
  List<Map<String, dynamic>> executeProcess = [];

  Execute({
    required this.pathCSVs,
    required this.pathTests,
  });

  Future<List<String>> _processPaths() async {
    return (await Directory(pathTests).list(recursive: true).toList())
        .map((e) => e.path)
        .toList();
  }

  Future<List<Map>> _processExecuteSelection() async {
    List<String> paths = await _processPaths();

    for (var i = 0; i < paths.length; i++) {
      File jsonFile = File(paths[i]);
      Map<String, dynamic> processAux =
          jsonDecode((await jsonFile.readAsString()));

      if (processAux['date_run'] == null) {
        executeProcess.add(processAux);
      }
    }

    return executeProcess;
  }

  void run() async {
    await _processExecuteSelection();

    Directory csvs = Directory(pathCSVs);
    if (!csvs.existsSync()) {
      csvs.createSync();
    }

    for (var i = 0; i < executeProcess.length; i++) {
      TestLocal test = TestLocal(
        testPath: pathTests,
        executeProcess: executeProcess[i],
        csvPath: pathCSVs,
        version: executeProcess[i]['version']!,
        quant: executeProcess[i]['quant']!,
        hopSize: executeProcess[i]['hopSize']!,
        dctFilterNum: executeProcess[i]['dctFilterNum']!,
        fftSize: executeProcess[i]['fftSize']!,
        melFilterNum: executeProcess[i]['melFilterNum']!,
        fftVersion: executeProcess[i]['fftVersion']!,
        hannVersion: executeProcess[i]['hannVersion']!,
        name: executeProcess[i]['name']!,
        beePath: executeProcess[i]['beePath']!,
        noBeePath: executeProcess[i]['noBeePath']!,
      );

      ReceivePort receivePort = ReceivePort();

      processComunicate.add(receivePort);
      process.addAll(
          {receivePort: (await Isolate.spawn(test.run, receivePort.sendPort))});

      awaits.add(receivePort.first);
    }

    Future.wait(awaits);
  }
}

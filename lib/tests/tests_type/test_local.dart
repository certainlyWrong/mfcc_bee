import 'dart:io';
import 'dart:isolate';
import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:mfcc_bee/mfcc_bee/mfcc.dart';
import 'package:mfcc_bee/tests/models/test_model.dart';
import 'package:mfcc_bee/mfcc_bee/functions/load_wav_buffer.dart';

class TestLocal extends TestsModel {
  TestLocal(
      {required super.testPath,
      required super.executeProcess,
      required super.csvPath,
      required super.version,
      required super.quant,
      required super.hopSize,
      required super.dctFilterNum,
      required super.fftSize,
      required super.melFilterNum,
      required super.fftVersion,
      required super.hannVersion,
      required super.name,
      required super.beePath,
      required super.noBeePath});

  @override
  void run(SendPort message) async {
    List<FileSystemEntity> beeWavePaths =
            (await Directory(beePath).list(recursive: true).toList())
                .where((element) => element.path.contains('wav'))
                .toList(),
        noBeeWavePaths =
            (await Directory(noBeePath).list(recursive: true).toList())
                .where((element) => element.path.contains('wav'))
                .toList();

    List<List> header = [
          [
            'name',
            'label',
            ...List<int>.generate(dctFilterNum, (index) => index)
          ]
        ],
        mfcc_beeBeeResults = [],
        mfcc_beeNoBeeResults = [];

    stdout.write("::::::::Init: version = ${super.version}::::::::\n");

    Stopwatch total = Stopwatch()..start();

    for (var i = 0; i < quant; i++) {
      stdout.write("run version:$version bee:$quant/${i + 1}\n");
      await loadBuffer(beeWavePaths[i].path).then(
        (value) async {
          if (value != null) {
            mfcc_beeBeeResults.add(
              [
                'element$i',
                'bee',
                ...(await mfcc_bee(
                  value,
                  verbose: false,
                  hopSize: hopSize,
                  fftSize: fftSize,
                  dctFilterNum: dctFilterNum,
                  melFilterNum: melFilterNum,
                  fftVersion: fftVersion,
                  hannVersion: hannVersion,
                )),
              ],
            );
          }
        },
      );
    }

    for (var i = 0; i < quant; i++) {
      stdout.write("run version:$version no_bee:$quant/${i + 1}\n");

      await loadBuffer(noBeeWavePaths[i].path).then(
        (value) async {
          if (value != null) {
            mfcc_beeNoBeeResults.add(
              [
                'element$i',
                'noBee',
                ...(await mfcc_bee(
                  value,
                  verbose: false,
                  hopSize: hopSize,
                  fftSize: fftSize,
                  dctFilterNum: dctFilterNum,
                  melFilterNum: melFilterNum,
                  fftVersion: fftVersion,
                  hannVersion: hannVersion,
                )),
              ],
            );
          }
        },
      );
    }
    total.stop();

    File("${super.csvPath}/${super.name}.csv")
      ..createSync()
      ..openWrite()
      ..writeAsStringSync(ListToCsvConverter().convert([
        ...header,
        ...mfcc_beeBeeResults,
        ...mfcc_beeNoBeeResults,
      ]))
      ..existsSync();

    executeProcess['time_run'] = total.elapsed.inMinutes.toString();
    executeProcess['time_total_run'] =
        "${total.elapsed.inMilliseconds / (executeProcess['quant'] as int) / 2}";
    executeProcess['date_run'] = DateTime.now().toIso8601String();

    File("$testPath/${executeProcess['name']}.json")
        .writeAsStringSync(jsonEncode(executeProcess));
    print('Finish');
    message.send('finish');
  }
}

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:mfcc_bee/mfcc/mfcc.dart';
import 'package:mfcc_bee/tests/model/test_model.dart';
import 'package:mfcc_bee/mfcc/functions/load_wav_buffer.dart';

class TestLocal extends TestsModel {
  TestLocal(
      {required super.version,
      required super.quant,
      required super.hopSize,
      required super.dctFilterNum,
      required super.fftSize,
      required super.melFilterNum,
      required super.fftVersion,
      required super.hannVersion,
      required super.beePath,
      required super.noBeePath});

  @override
  void run() async {
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
        mfccBeeResults = [],
        mfccNoBeeResults = [];

    stdout.write(
        "::::::::Init: ${super.version} - version=${super.fftVersion}::::::::\n");

    for (var i = 0; i < quant; i++) {
      stdout.write("run: $quant/${i + 1}\r");
      await loadBuffer(beeWavePaths[i].path).then(
        (value) async {
          if (value != null) {
            mfccBeeResults.add(
              [
                'element$i',
                'bee',
                ...(await mfcc(
                  value,
                  verbose: true,
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
      stdout.write("run: $quant/${i + 1}\r");
      await loadBuffer(noBeeWavePaths[i].path).then(
        (value) async {
          if (value != null) {
            mfccNoBeeResults.add(
              [
                'element$i',
                'noBee',
                ...(await mfcc(
                  value,
                  verbose: true,
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

    File(
        "./test_hop=${super.hopSize}coeff=${super.dctFilterNum}_melFilter=${fftSize}_fftSize=${fftSize}_FFT_v${fftVersion}_hann_v${hannVersion}_${super.version}.csv")
      ..createSync()
      ..openWrite()
      ..writeAsStringSync(ListToCsvConverter().convert([
        ...header,
        ...mfccBeeResults,
        ...mfccNoBeeResults,
      ]))
      ..existsSync();

    stdout.close();
  }
}

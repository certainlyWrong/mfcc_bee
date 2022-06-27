import 'dart:isolate';

abstract class TestsModel {
  final String beePath, noBeePath, csvPath, name;
  final int quant,
      hopSize,
      dctFilterNum,
      fftSize,
      melFilterNum,
      fftVersion,
      version,
      hannVersion;

  TestsModel({
    required this.csvPath,
    required this.version,
    required this.quant,
    required this.hopSize,
    required this.dctFilterNum,
    required this.fftSize,
    required this.melFilterNum,
    required this.fftVersion,
    required this.hannVersion,
    required this.name,
    required this.beePath,
    required this.noBeePath,
  });

  void run(SendPort message);
}

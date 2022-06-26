abstract class TestsModel {
  final String beePath, noBeePath, version;
  final int quant,
      hopSize,
      dctFilterNum,
      fftSize,
      melFilterNum,
      fftVersion,
      hannVersion;

  TestsModel({
    required this.version,
    required this.quant,
    required this.hopSize,
    required this.dctFilterNum,
    required this.fftSize,
    required this.melFilterNum,
    required this.fftVersion,
    required this.hannVersion,
    required this.beePath,
    required this.noBeePath,
  });

  void run();
}

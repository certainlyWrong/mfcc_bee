import 'dart:io';
import 'mfcc.dart';
import 'dart:convert';
import 'functions/loadWavBuffer.dart';

String pathFromFileName(String path) =>
    path.substring(path.lastIndexOf('/'), path.length);

void run(String path, String fileName) async {
  final wave = Directory(path),
      paths = wave.list(recursive: true, followLinks: false);

  Map<String, List<double>> mfccResults = {};

  List<FileSystemEntity> allPaths = await paths.toList();
  int size = allPaths.length;

  for (var i = 0; i < 1100; i++) {
    if (allPaths[i].toString().contains('wav')) {
      print("${i} - " + pathFromFileName(allPaths[i].toString()));
      await loadBuffer(allPaths[i].path).then((value) async {
        if (value != null) {
          mfccResults.addEntries({
            pathFromFileName(allPaths[i].toString()):
                await mfcc(value, verbose: true),
          }.entries);
        }
      });
    }
  }

  File("./" + fileName + ".json")
    ..createSync()
    ..openWrite()
    ..writeAsStringSync(jsonEncode(mfccResults))
    ..existsSync();
}

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

void main(List<String> args) async {
  // List a = json.decode(File("buffer.json").readAsStringSync())["signal"]["0"];
  // List<double> b = [];

  // for (var i = 0; i < a.length; i++) {
  //   b.add(checkDouble(a[i]));
  // }

  // BufferWav bufferOrigin = BufferWav(
  //   22050,
  //   Array(b),
  // );
  // await loadBuffer('/home/adriano/Documentos/mfcc_dart/audio/audio2.wav')
  //     .then((value) async {
  //   if (value != null) {
  //     await mfcc(value, verbose: true);
  //   }
  // });

  // print(await mfcc(bufferOrigin, normalize: true, verbose: true));

  run(args[0], args[1]);

  // ArrayComplex a = ArrayComplex.empty();
  // for (var i = 0; i < 16; i++) {
  //   a.add(Complex(real: i + 1));
  // }

  // print(Array([2, 3, 2]) * Array([2, 3, 2]));
}

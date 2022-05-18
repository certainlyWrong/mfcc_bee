import 'dart:io';
import 'mfcc.dart';
import 'package:csv/csv.dart';
import 'functions/loadWavBuffer.dart';

String pathFromFileName(String path) =>
    path.substring(path.lastIndexOf('/') + 1, path.length);

void run(
  String path,
  String fileName,
  int quant,
) async {
  final wave = Directory(path),
      paths = wave.list(recursive: true, followLinks: false);

  List<List> mfccResults = [
    ['nome', ...List<int>.generate(20, (index) => index)]
  ];

  List<FileSystemEntity> allPaths = (await paths.toList())
      .where((element) => element.path.contains('wav'))
      .toList();

  for (var i = 0; i < quant; i++) {
    print("$i - " + pathFromFileName(allPaths[i].toString()));
    await loadBuffer(allPaths[i].path).then((value) async {
      if (value != null) {
        mfccResults.add(['element$i', ...(await mfcc(value, verbose: true))]);
      }
    });
  }

  File("./" + fileName + ".csv")
    ..createSync()
    ..openWrite()
    ..writeAsStringSync(ListToCsvConverter().convert(mfccResults))
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

  run(args[0], args[1], int.parse(args[2]));

  // final a = ListToCsvConverter().convert([
  //   ['aaaa', 'bbbb', 'cccc', 1],
  //   [1, 2, 3, 4],
  //   [1, 2, 3, 4],
  //   [1, 2, 3, 4]
  // ]);

  // ArrayComplex a = ArrayComplex.empty();
  // for (var i = 0; i < 16; i++) {
  //   a.add(Complex(real: i + 1));
  // }

  // print(Array([2, 3, 2]) * Array([2, 3, 2]));
}

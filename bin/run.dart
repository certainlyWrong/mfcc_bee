import 'dart:io';
import 'mfcc.dart';
import 'package:csv/csv.dart';
import 'functions/load_wav_buffer.dart';

String pathFromFileName(String path) =>
    path.substring(path.lastIndexOf('/') + 1, path.length);

void run(
  String path,
  int quant,
  String fileName,
  int hopSize,
  int dctFilterNum,
  int fftSize,
  int melFilterNum,
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
        mfccResults.add([
          'element$i',
          ...(await mfcc(
            value,
            verbose: true,
            hopSize: hopSize,
            fftSize: fftSize,
            dctFilterNum: dctFilterNum,
            melFilterNum: melFilterNum,
          ))
        ]);
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

  // List a = [];

  // a.add('/home/adrianords/Downloads/original/bee1');
  // a.add('bee');
  // a.add('550');

  // run(a[0], a[1], int.parse(a[2]));
  // run(
  //   args[0],
  //   int.parse(args[1]),
  //   args[2],
  //   int.parse(args[3]),
  //   int.parse(args[4]),
  //   int.parse(args[5]),
  //   int.parse(args[6]),
  // );

  run(
    // "/home/adriano/Downloads/original/bee_5s",
    // "/home/adriano/Downloads/original/6",
    // "/home/adriano/Downloads/original/7",
    // "/home/adriano/Downloads/original/10",
    "/home/adriano/Downloads/original/bee_15s",
    1,
    "bee",
    512,
    20,
    2048,
    48,
  );

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

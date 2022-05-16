import 'dart:io';
import 'mfcc.dart';
import 'dart:convert';
import 'functions/loadWavBuffer.dart';
import 'package:scidart/numdart.dart';
import 'functions/utils/bufferWav.dart';

Future<List<double>> run() async {
  final wave = Directory("/home/adriano/Downloads/original"),
      paths = wave.list(recursive: true, followLinks: false);

  List<double> a = [];

  paths.listen(
    (event) async {
      if (event.toString().contains('wav')) {
        print(event.toString());
        await loadBuffer(event.path).then((value) async {
          if (value != null) {
            print(await mfcc(value, verbose: true));
          }
        });
      }
    },
  );

  return a;
}

double checkDouble(dynamic value) {
  if (value is String) {
    return double.parse(value);
  } else {
    return value.toDouble();
  }
}

void main(List<String> args) async {
  List a = json.decode(File("buffer.json").readAsStringSync())["signal"]["0"];
  List<double> b = [];

  for (var i = 0; i < a.length; i++) {
    b.add(checkDouble(a[i]));
  }

  BufferWav bufferOrigin = BufferWav(
    22050,
    Array(b),
  );
  // await loadBuffer('/home/adriano/Documentos/mfcc_dart/audio/audio2.wav')
  //     .then((value) async {
  //   if (value != null) {
  //     await mfcc(value, verbose: true);
  //   }
  // });

  print(await mfcc(bufferOrigin, normalize: true, verbose: true));

  // await run();

  // ArrayComplex a = ArrayComplex.empty();
  // for (var i = 0; i < 16; i++) {
  //   a.add(Complex(real: i + 1));
  // }

  // print(Array([2, 3, 2]) * Array([2, 3, 2]));
}

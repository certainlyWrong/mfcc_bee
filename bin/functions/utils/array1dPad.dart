// ignore_for_file: file_names

import 'package:scidart/numdart.dart';

Future<Array> array1dPad(Array array, int pad, {bool reflect = false}) async {
  if (pad > array.length / 2) return Array([]);

  if (!reflect) return arrayConcat([zeros(pad), array, zeros(pad)]);

  return arrayConcat([
    arrayReverse(Array(array.sublist(1, pad + 1))),
    array,
    arrayReverse(
        Array(array.sublist(array.length - pad - 1, array.length - 1))),
  ]);
}

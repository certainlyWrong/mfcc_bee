// ignore_for_file: file_names

import 'package:scidart/numdart.dart';

Future<Array2d> dctTypeThree(int dctFilterNum, int filterLen) async {
  List<Array> basic = [];
  basic.add(Array(List.filled(10, (1 / sqrt(filterLen)))));

  Array samples = arrayMultiplyToScalar(
    // FIXME Não gera o elemento final como a função do numpy, implementar a propria função. Por enquanto está na gambiarra
    createArrayRange(start: 1, stop: (2 * filterLen) + 1, step: 2),
    pi / (2 * filterLen),
  );

  double sqrtFilterLen = sqrt(2 / filterLen);

  for (var i = 1; i < dctFilterNum; i++) {
    basic.add(Array.empty());
    for (var j = 0; j < filterLen; j++) {
      basic[i].add(cos(i * samples.elementAt(j)) * sqrtFilterLen);
    }
  }

  return Array2d(basic);
}

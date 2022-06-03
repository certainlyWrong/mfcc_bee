// ignore_for_file: file_names

import 'package:scidart/numdart.dart';

List<List<Complex>> matrixComplexTranspose(List<List<Complex>> matrix) {
  List<List<Complex>> aux = [];
  int size1 = matrix.length, size2 = matrix[0].length;

  for (var i = 0; i < size2; i++) {
    aux.add([]);
    for (var j = 0; j < size1; j++) {
      aux[i].add(matrix[j][i]);
    }
  }

  return aux;
}

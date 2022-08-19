import 'package:scidart/numdart.dart';

Array hannWindow(int fftSize) {
  List<double> aux = List.filled(fftSize, 0);

  for (var i = 0; i < fftSize; i++) {
    aux[i] = 0.5 - 0.5 * cos((2 * pi * i) / (fftSize));
  }
  return Array(aux);
}

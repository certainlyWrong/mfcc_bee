import 'package:scidart/numdart.dart';

Future<Array> normilize(Array signal) async {
  double maxValue = 0;
  int size = signal.length;

  for (var i = 0; i < size; i++) {
    final aux = signal[i].abs();
    if (maxValue < aux) maxValue = aux;
  }

  return Array(signal.toList().map((e) => e / maxValue).toList());
}

import 'utils/logarithm.dart';
import 'package:scidart/numdart.dart';

ArrayComplex myfft(ArrayComplex buffer) {
  int N = buffer.length;

  if (log2(N) % 1 > 0) {
    throw Exception("size of x must be a power of 2");
  }

  int nmin = N > 32 ? 32 : N;
  Array n = createArrayRange(stop: nmin);

  Array2d k =
      Array2d(List.generate(n.length, (index) => Array([n.elementAt(index)])));

  List<List<Complex>> M = [];
  for (var i = 0; i < nmin; i++) {
    M.add([]);
    for (var j = 0; j < nmin; j++) {
      M[i].add(
        complexExp(
          Complex(imaginary: -2) *
              Complex(
                real: pi * n[j] * k.l[i]!.elementAt(0) / nmin.toDouble(),
              ),
        ),
      );
    }
  }

  return ArrayComplex.empty();
}

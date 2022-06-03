import 'package:scidart/numdart.dart';
import 'functions/hann_window.dart';
import 'functions/myfft.dart';

void main(List<String> args) {
  // List<double> a = [5, 6, 4, 9, 8, 7, 5, 8, 9, 4, 7, 4, 6, 1, 9, 1];

  // ArrayComplex b =
  //     ArrayComplex(List.generate(a.length, (index) => Complex(real: a[index])));

  // print(myfft(b));

  print(hannWindow(2048));
}

import 'logarithm.dart';
import 'package:scidart/numdart.dart';

double freqToMel(num freq) => (2595.0 * log10(1.0 + freq / 700.0));

double melToFreq(num mel) => (700.0 * (pow(10.0, (mel / 2595.0)) - 1.0));

import 'dart:math' as math;

double logBase(num x, num base) => math.log(x) / math.log(base);
double log10(num x) => math.log(x) / math.ln10;
double log2(num x) => logBase(x, 2);

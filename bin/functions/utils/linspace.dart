List<double> linSpace(double min, double max, int quant) {
  bool init = min < max ? true : false;

  double space = (max - min).abs() / (quant - 1), sum = min;
  List<double> result = [];

  for (var i = 0; i < quant; i++) {
    result.add(sum);
    if (init) {
      sum += space;
    } else {
      sum -= space;
    }
  }

  return result;
}

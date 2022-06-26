// ignore_for_file: unused_import, non_constant_identifier_names

import 'utils/convert.dart';
import 'utils/linspace.dart';
import 'package:scidart/numdart.dart';

void alter_list(List<Array> list, int i, int n, List filter_points) {
  late List<double> aux;

  if (n == 1) {
    aux = linSpace(0, 1, filter_points[i + 1] - filter_points[i]);

    int max = filter_points[i + 1];
    for (int j = filter_points[i], k = 0; j < max; j++, k++) {
      list[i].l[j] = aux[k];
    }
  } else {
    aux = linSpace(1, 0, filter_points[i + 2] - filter_points[i + 1]);

    int max = filter_points[i + 2];
    for (int j = filter_points[i + 1], k = 0; j < max; j++, k++) {
      list[i].l[j] = aux[k];
    }
  }
}

List get_filter_points(
  double fmin,
  double fmax,
  int mel_filter_num,
  int fft_size, {
  int sample_rate = 44100,
}) {
  final fmin_mel = freqToMel(fmin), fmax_mel = freqToMel(fmax);

  List<double> mel_freqs = linSpace(fmin_mel, fmax_mel, mel_filter_num + 2);
  List<int> filter_points = [];

  mel_freqs = mel_freqs.map((e) => melToFreq(e)).toList();

  for (var i = 0; i < mel_freqs.length; i++) {
    filter_points.add(((fft_size + 1) / sample_rate * mel_freqs[i]).toInt());
  }

  return [filter_points, mel_freqs];
}

List<Array> get_filters(List filter_points, int fft_size) {
  int size = filter_points.length - 2;
  List<Array> filters = [];

  for (var i = 0; i < size; i++) {
    filters.add(zeros(fft_size ~/ 2 + 1));
  }

  for (var i = 0; i < size; i++) {
    alter_list(filters, i, 1, filter_points);
    alter_list(filters, i, 2, filter_points);
  }

  return filters;
}

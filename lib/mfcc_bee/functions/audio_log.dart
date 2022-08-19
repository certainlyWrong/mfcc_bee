// ignore_for_file: file_names, non_constant_identifier_names

import 'utils/logarithm.dart';
import 'package:scidart/numdart.dart';

Future<Array2d> audioLog(Array2d audio_filtered) async {
  Array2d audioLog = Array2d.empty();

  for (var i = 0; i < audio_filtered.row; i++) {
    audioLog.add(Array.empty());
    for (var j = 0; j < audio_filtered.column; j++) {
      double? aux = audio_filtered.l[i]?.elementAt(j);
      if (aux != null) {
        audioLog.l[i]?.l.add(10.0 * log10(aux));
      }
    }
  }

  return audioLog;
}

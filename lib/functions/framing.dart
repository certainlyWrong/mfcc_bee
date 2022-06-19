// ignore_for_file: non_constant_identifier_names

import 'utils/array1d_pad.dart';
import 'package:scidart/numdart.dart';

/// # framing
/// Fatia o sinal em uma lista de fragmentos.
/// ## Definições de atributos
/// O atributo **fft_size** precisa ser uma potencia de 2
Future<List<Array>> framing(
  Array signal, {
  int fft_size = 2048,
  int hop_size = 10,
  int sample_rate = 44100,
}) async {
  signal = await array1dPad(signal, (fft_size ~/ 2), reflect: true);
  int frame_len = (sample_rate * hop_size / 1000).round(),
      frame_num = (signal.length - fft_size) ~/ frame_len + 1;
  List<Array> frames = [];
  for (var i = 0; i < frame_num; i++) {
    frames.add(
      Array(
        signal.sublist(i * frame_len, i * frame_len + fft_size),
      ),
    );
  }

  return frames;
}

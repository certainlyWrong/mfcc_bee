// ignore_for_file: file_names

import 'utils/bufferWav.dart';
import 'package:wav/wav.dart';
import 'package:scidart/numdart.dart';

Future<BufferWav?> loadBuffer(String path) async {
  try {
    final buffer = await Wav.readFile(path);
    return BufferWav(buffer.samplesPerSecond, Array(buffer.channels[0].sublist(0, 55000)));
  } catch (e) {
    print("loadBuffer: ${e.toString()}");
    return null;
  }
}

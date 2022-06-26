// ignore_for_file: file_names

import 'package:scidart/numdart.dart';

class BufferWav {
  int simplesRate;
  Array signal;

  BufferWav(this.simplesRate, this.signal);

  BufferWav copy() {
    return BufferWav(simplesRate, signal);
  }
}

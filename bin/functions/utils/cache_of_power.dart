class CacheOfPower {
  late int _fft_size;
  CacheOfPower(this._fft_size);

  @override
  String toString() {
    return _fft_size.toString();
  }
}

void main(List<String> args) {
  var a = CacheOfPower(2048)._fft_size = 100;
  print(a.toString());
}

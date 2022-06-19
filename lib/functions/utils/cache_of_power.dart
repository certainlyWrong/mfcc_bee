class CacheOfPower {
  late int _fftSize;
  CacheOfPower(this._fftSize);

  @override
  String toString() {
    return _fftSize.toString();
  }
}

void main(List<String> args) {
  var a = CacheOfPower(2048)._fftSize = 100;
  print(a.toString());
}

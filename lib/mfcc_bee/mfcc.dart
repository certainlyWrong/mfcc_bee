import 'dart:typed_data';
import 'functions/framing.dart';
import 'functions/audio_log.dart';
import 'functions/normalize.dart';
import 'package:fftea/fftea.dart';
import 'functions/filterbank.dart';
import 'functions/hann_window.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'functions/dct_type_three.dart';
import 'functions/utils/buffer_wav.dart';
import 'package:fftea/stft.dart' as util;

Future<List<double>> mfcc_bee(
  BufferWav buffer, {
  int hopSize = 15,
  int fftSize = 4096,
  int dctFilterNum = 40,
  bool verbose = false,
  int melFilterNum = 48,
  bool normilizeActivate = false,
  int fftVersion = 2,
  int hannVersion = 1,
}) async {
  /*
   * Timer usado para medir o tempo de execução
   * de cada processo, caso o parametro "verbose" == True
  */
  Stopwatch? time = verbose ? Stopwatch() : null;

  if (normilizeActivate) {
    /*
	! Passo 1
	* Iniciando processo de normalização do buffer.
	* Esse processo transmite a proporção da frenquencia do audio
	* para valores entre 1 e -1.
  */
    if (verbose) time?.start();
    buffer.signal = await normilize(buffer.signal);
    if (verbose) {
      time?.stop();
      print("normilize - ${time?.elapsedMilliseconds}ms");
    }
  }

  /*
   ! Passo 2
   * Fragmenta o buffer em vários quadros 
   * para facilitar o processamento posterior
  */
  if (verbose) {
    time?.reset();
    time?.start();
  }

  List<Array> audioFramed = await framing(
    buffer.signal,
    fft_size: fftSize,
    hop_size: hopSize,
    sample_rate: buffer.simplesRate,
  );

  double freqMin = 0, freqHigh = buffer.simplesRate / 2;

  // TODO testando se realmente é necessario transpor a matriz duas vezes para ter bons resultados
  // TODO testing if it is really necessary to transpose the matrix twice to have good results
  // Array2d audio_frame_T = matrixTranspose(
  //   matrixMultiplyColumns(
  //     Array2d(await audio_framed),
  //     hann(fft_size),
  //   ),
  // );

  Array windowHann = Array.empty();
  switch (hannVersion) {
    case 1:
      windowHann = hann(fftSize);
      break;
    case 2:
      windowHann = hannWindow(fftSize);
      break;

    case 3:
      windowHann = Array(util.Window.hanning(fftSize).toList());
      break;

    default:
  }

  List<Array> audioWin =
      Array2d(audioFramed).map((element) => element * windowHann).toList();

  if (verbose) {
    time?.stop();
    print("framing - ${time?.elapsedMilliseconds}ms");
  }

  /*
   ! Passo 3
   * Convertendo para o dominio da frequencia
   * Processando a FFT e transpondo a matrix complexa
  */
  if (verbose) {
    time?.reset();
    time?.start();
  }

  int size = audioWin.length, cut = (1 + audioWin[0].length ~/ 2);

  List<ArrayComplex> audioFft = [];

  switch (fftVersion) {
    case 2:
      for (var i = 0; i < size; i++) {
        Float64x2List aux = Float64x2List.fromList(
          audioWin
              .elementAt(i)
              .map((element) => Float64x2(element, 0))
              .toList(),
        );

        FFT(fftSize).inPlaceFft(
          aux,
        );

        audioFft.add(
          ArrayComplex(
            aux
                .map((e) => Complex(real: e.x, imaginary: e.y))
                .toList()
                .sublist(0, cut),
          ),
        );
      }
      break;
    default:
      for (var i = 0; i < size; i++) {
        List<Complex> aux = audioWin
            .elementAt(i)
            .map((element) => Complex(real: element))
            .toList();

        audioFft.add(
          ArrayComplex(fft(ArrayComplex(aux)).sublist(0, cut)),
        );
      }
      break;
  }

  // TODO Teste da necessidade de transpor a matriz
  // TODO Test the need to transpose the matrix
  // audio_fft = matrixComplexTranspose(audio_fft);

  List<Array> audioPower = [];
  size = audioFft.length;

  for (var i = 0; i < size; i++) {
    Array aux = arrayComplexAbs(ArrayComplex(audioFft[i]));
    audioPower.add(aux * aux);
  }

  if (verbose) {
    time?.stop();
    print("fft - ${time?.elapsedMilliseconds}ms");
  }

  /*
   ! Passo 4
  */
  if (verbose) {
    time?.reset();
    time?.start();
  }
  List filterPointsAndFreqs =
      get_filter_points(freqMin, freqHigh, melFilterNum, fftSize);

  List<Array> filters = get_filters(filterPointsAndFreqs[0], fftSize);

  Array enorm = (Array(filterPointsAndFreqs[1].sublist(2, melFilterNum + 2)) -
      Array(filterPointsAndFreqs[1]).sublist(0, melFilterNum));

  for (var i = 0; i < melFilterNum; i++) {
    filters[i] = arrayMultiplyToScalar(filters[i], (2 / enorm.elementAt(i)));
  }

  Array2d audioFiltered =
          matrixDot(Array2d(filters), matrixTranspose(Array2d(audioPower))),
      resultAudioLog = await audioLog(audioFiltered),
      dctFilters = await dctTypeThree(dctFilterNum, melFilterNum),
      cepstralCoefficents = matrixDot(dctFilters, resultAudioLog);

  List<double> coeffs = [];

  for (var i = 0; i < cepstralCoefficents.row; i++) {
    coeffs.add(cepstralCoefficents[i][0]);
  }

  if (verbose) {
    time?.stop();
    print("finish - ${time?.elapsedMilliseconds}ms");
  }

  return coeffs;
}

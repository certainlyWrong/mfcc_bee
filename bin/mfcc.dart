// ignore_for_file: non_constant_identifier_names, unused_import

import 'functions/framing.dart';
import 'functions/audioLog.dart';
import 'functions/normalize.dart';
import 'functions/filterbank.dart';
import 'functions/dctTypeThree.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'functions/utils/bufferWav.dart';
import 'functions/utils/matrixComplexTranspose.dart';

Future<List<double>> mfcc(
  BufferWav buffer, {
  int hop_size = 15,
  int fft_size = 2048,
  int dctFilterNum = 20,
  bool verbose = false,
  int mel_filter_num = 10,
  bool normilize_activate = false,
}) async {
  /*
   * Timer usado para medir o tempo de execução
   * de cada processo, caso o parametro "verbose" == True
  */
  Stopwatch? time = verbose ? Stopwatch() : null;

  if (normilize_activate) {
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
    fft_size: fft_size,
    hop_size: hop_size,
    sample_rate: buffer.simplesRate,
  );

  double freqMin = 0, freqHigh = buffer.simplesRate / 2;

  // TODO testando se realmente é necessario transpor a matriz duas vezes para ter bons resultados
  // Array2d audio_frame_T = matrixTranspose(
  //   matrixMultiplyColumns(
  //     Array2d(await audio_framed),
  //     hann(fft_size),
  //   ),
  // );

  // TODO a função de janelamento está dando valores diferentes, talvez isso não altere o resultado final... Ou talvez será necessario reimplementar
  Array windowHann = hann(fft_size);

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

  for (var i = 0; i < size; i++) {
    List<Complex> aux =
        audioWin.elementAt(i).map((element) => Complex(real: element)).toList();

    audioFft.add(
      ArrayComplex(fft(ArrayComplex(aux)).sublist(0, cut)),
    );
  }

  // TODO Teste da necessidade de transpor a matriz
  // audio_fft = matrixComplexTranspose(audio_fft);

  List<Array> audioPower = [];
  size = audioFft.length;

  for (var i = 0; i < size; i++) {
    Array aux = arrayComplexAbs(ArrayComplex(audioFft[i]));
    audioPower.add(aux * aux);
  }

  if (verbose) {
    time?.stop();
    print("fft and others - ${time?.elapsedMilliseconds}ms");
  }

  /*
   ! Passo 4
  */
  if (verbose) {
    time?.reset();
    time?.start();
  }
  List filterPointsAndFreqs =
      get_filter_points(freqMin, freqHigh, mel_filter_num, fft_size);

  List<Array> filters = get_filters(filterPointsAndFreqs[0], fft_size);

  Array enorm = (Array(filterPointsAndFreqs[1].sublist(2, mel_filter_num + 2)) -
      Array(filterPointsAndFreqs[1]).sublist(0, mel_filter_num));

  for (var i = 0; i < mel_filter_num; i++) {
    filters[i] = arrayMultiplyToScalar(filters[i], (2 / enorm.elementAt(i)));
  }

  Array2d audioFiltered =
          matrixDot(Array2d(filters), matrixTranspose(Array2d(audioPower))),
      resultAudioLog = await audioLog(audioFiltered),
      dctFilters = await dctTypeThree(dctFilterNum, mel_filter_num),
      cepstralCoefficents = matrixDot(dctFilters, resultAudioLog);

  List<double> MFCCs = [];

  for (var i = 0; i < cepstralCoefficents.row; i++) {
    MFCCs.add(cepstralCoefficents[i][0]);
  }

  if (verbose) {
    time?.stop();
    print("finish - ${time?.elapsedMilliseconds}ms");
  }

  return MFCCs;
}

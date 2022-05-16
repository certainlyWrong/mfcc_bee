// ignore_for_file: non_constant_identifier_names, unused_import

import 'functions/dctTypeThree.dart';
import 'functions/framing.dart';
import 'functions/audioLog.dart';
import 'functions/normalize.dart';
import 'package:scidart/numdart.dart';
import 'package:scidart/scidart.dart';
import 'functions/utils/bufferWav.dart';
import 'functions/filterbank.dart';
import 'functions/utils/matrixComplexTranspose.dart';

Future<List<double>> mfcc(
  BufferWav buffer, {
  int hop_size = 15,
  int fft_size = 2048,
  int mel_filter_num = 10,
  bool verbose = false,
  bool normalize = false,
  String? status,
}) async {
  /*
   * Timer usado para medir o tempo de execução
   * de cada processo, caso o parametro "verbose" == True
  */
  Stopwatch? time = verbose ? Stopwatch() : null;

  if (normalize) {
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

  List<Array> audio_framed = await framing(
    buffer.signal,
    fft_size: fft_size,
    hop_size: hop_size,
    sample_rate: buffer.simplesRate,
  );

  double freq_min = 0, freq_high = buffer.simplesRate / 2;

  // TODO testando se realmente é necessario transpor a matriz duas vezes para ter bons resultados
  // Array2d audio_frame_T = matrixTranspose(
  //   matrixMultiplyColumns(
  //     Array2d(await audio_framed),
  //     hann(fft_size),
  //   ),
  // );

  // TODO a função de janelamento está dando valores diferentes, talvez isso não altere o resultado final... Ou talvez será necessario reimplementar
  Array window_hann = hann(fft_size);

  List<Array> audio_win =
      Array2d(audio_framed).map((element) => element * window_hann).toList();

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

  int size = audio_win.length, cut = (1 + audio_win[0].length ~/ 2);
  List<ArrayComplex> audio_fft = [];

  for (var i = 0; i < size; i++) {
    List<Complex> aux = audio_win
        .elementAt(i)
        .map((element) => Complex(real: element))
        .toList();

    audio_fft.add(
      ArrayComplex(fft(ArrayComplex(aux)).sublist(0, cut)),
    );
  }

  // TODO Teste da necessidade de transpor a matriz
  // audio_fft = matrixComplexTranspose(audio_fft);

  List<Array> audio_power = [];
  size = audio_fft.length;

  for (var i = 0; i < size; i++) {
    Array aux = arrayComplexAbs(ArrayComplex(audio_fft[i]));
    audio_power.add(aux * aux);
  }

  if (verbose) {
    time?.stop();
    print("fft and others - ${time?.elapsedMilliseconds}ms");
  }

  List filter_points_and_freqs =
      get_filter_points(freq_min, freq_high, mel_filter_num, fft_size);

  List<Array> filters = get_filters(filter_points_and_freqs[0], fft_size);

  Array enorm =
      (Array(filter_points_and_freqs[1].sublist(2, mel_filter_num + 2)) -
          Array(filter_points_and_freqs[1]).sublist(0, mel_filter_num));

  for (var i = 0; i < mel_filter_num; i++) {
    filters[i] = arrayMultiplyToScalar(filters[i], (2 / enorm.elementAt(i)));
  }

  Array2d audio_filtered =
          matrixDot(Array2d(filters), matrixTranspose(Array2d(audio_power))),
      result_audio_log = await audioLog(audio_filtered);

  int dctFilterNum = 40;

  Array2d dct_filters = await dctTypeThree(dctFilterNum, mel_filter_num);

  Array2d cepstral_coefficents = matrixDot(dct_filters, result_audio_log);

  List<double> MFCCs = [];

  for (var i = 0; i < cepstral_coefficents.row; i++) {
    MFCCs.add(cepstral_coefficents[i][0]);
  }

  return MFCCs;
}

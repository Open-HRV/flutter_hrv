library flutter_hrv;

/// A HRV Calculator.
import 'package:scidart/numdart.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:powerdart/powerdart.dart';
import 'dart:developer'  as dev;


double normalize(double? hrvValue, String hrvKey) {
  switch(hrvKey) {
    case 'RMSSD':
      return min((hrvValue! * 100 / 150).round(), 100) - 12;
    case 'SDNN':
      return min((hrvValue! * 100 / 120).round(), 100) - 12;
  }
  return hrvValue!;
}

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class RrsData{
  RrsData(this.x, this.y);
  final int x;
  late final int y;
}

class PowerSpectrumData {
  PowerSpectrumData(this.x, this.y);
  final double x; //frequency
  late final double y; //spe
}

class FrequencyDomainData {
  FrequencyDomainData(this.psd, this.hrvFrequencyDomain){
    psdList = [];
    for (int i = 0; i < psd.f.length; i++){
      psdList.add(PowerSpectrumData(psd.f.elementAt(i).toPrecision(3), psd.pxx.elementAt(i)));
    }
  }
  PsdResult psd;
  late List<PowerSpectrumData> psdList;
  Map<String, double> hrvFrequencyDomain;
}

class CalculateHrv{

  static List<RrsData> filterPeaks(List<RrsData> dataRrs) {
    var dataArray = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    const threshold = 300;
    var refMedian = median(dataArray.getRangeArray(0, 3));
    for (var i = 3; i < dataArray.length - 4; i++){
      var refMedian = median(dataArray.getRangeArray(i, i + 3));
      if (dataArray.elementAt(i) - refMedian > threshold ||
          refMedian - dataArray.elementAt(i) > threshold) {
        double newValue = (dataArray.elementAt(i + 1) + dataArray.elementAt(i - 1)) / 2;
        var newData = RrsData(dataRrs[i].x ,newValue.round());
        dataRrs.replaceRange(i, i + 1, [newData]);
      }
      refMedian = median(dataArray.getRangeArray(i, i + 3));
    }
    return dataRrs;
  }

  static Map<String, double> calcTimeDomain(List<RrsData> dataRrs){
    var rrs = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    Map<String, double> out = {};
    Array diffRrs = arrayDiff(rrs);

    out['MeanNN'] = mean(rrs);
    out["SDNN"] = standardDeviation(rrs);

    out['RMSSD'] = sqrt(mean(arrayPow(diffRrs, 2)));
    out["SDSD"] = standardDeviation(diffRrs);

    return out;
  }

  static FrequencyDomainData calcFrequencyDomain(List<RrsData> dataRrs){
    Map<String, double> out = {};
    var rrs = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    var peaks = _rrsToPeak(rrs, 1);
    final psdRes = psd(peaks, 1);
    dev.log('data:' + area.toString());
    dev.log(psdRes.pxx.toString());
    dev.log(psdRes.f.toString());
    out['coh'] = _coherence(psdRes.pxx);
    return FrequencyDomainData(psdRes, out);
  }

//To Do fix
  static double _coherence (List<double> freq){
    double coh = (freq[1] / arraySum(Array(freq)));
    return coh;
  }

  static Array _rrsToPeak(Array rri, int sampling) {
    Array result = Array([0, (rri[0] / 1000) * sampling]);
    dev.log(result.toString());
    for (var i = 1; i < rri.length; i++){
      result.add(result[i - 1] + ((rri[i - 1] / 1000) * sampling));
    }
    return result;
  }

// TODO resonance frequency calculator
  static double _resonaceFrequency(Map<String, Array> hrvValues, Array breathingFrequency) {
    return 0.0;
  }

// TODO 2 dimensional hrvScore base on the
  static Array _hrvScore(Map<String, Array> hrvValues) {
    Array result = Array([]);
    for (var i = 0; i < hrvValues.length; i++) {
      var val = (normalize(hrvValues['RMSSD']![i], "RMSSD") +
          normalize(hrvValues['SDNN']![i], "SDNN")) / 2;
      result.add(val);
    }
    return result;
  }
}




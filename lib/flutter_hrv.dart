library flutter_hrv;

/// A HRV Calculator.
import 'package:scidart/numdart.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:powerdart/powerdart.dart';


double _normalize(double? hrvValue, String hrvKey) {
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
  final int x; // time offset
  late final int y; // RR value
}

class PowerSpectrumData {
  PowerSpectrumData(this.x, this.y);
  final double x; // frequency
  late final double y; // spectrum
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

  static List<RrsData> filterPeaksRrsData(List<RrsData> dataRrs) {
    var dataArray = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    const threshold = 300;
    var refMedian = median(dataArray.getRangeArray(0, 3));
    for (var i = 3; i < dataArray.length - 4; i++){
      refMedian = median(dataArray.getRangeArray(i, i + 3));
      if (dataArray.elementAt(i) - refMedian > threshold ||
          refMedian - dataArray.elementAt(i) > threshold) {
        double newValue = (dataArray.elementAt(i + 1) + dataArray.elementAt(i - 1)) / 2;
        var newData = RrsData(dataRrs[i].x, newValue.round());
        dataRrs.replaceRange(i, i + 1, [newData]);
      }
      refMedian = median(dataArray.getRangeArray(i, i + 3));
    }
    return dataRrs;
  }

  static List<double> filterPeaksRrs(List<double> rrs) {
    var dataArray = Array(rrs);
    const threshold = 300;
    var refMedian = median(dataArray.getRangeArray(0, 3));
    for (var i = 3; i < dataArray.length - 4; i++){
      refMedian = median(dataArray.getRangeArray(i, i + 3));
      if (dataArray.elementAt(i) - refMedian > threshold ||
          refMedian - dataArray.elementAt(i) > threshold) {
        double newValue = (dataArray.elementAt(i + 1) + dataArray.elementAt(i - 1)) / 2;
        rrs.replaceRange(i, i + 1, [newValue]);
      }
      refMedian = median(dataArray.getRangeArray(i, i + 3));
    }
    return rrs;
  }

  static Map<String, double> calcTimeDomainRrsData(List<RrsData> dataRrs){
    var rrs = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    Map<String, double> out = {};
    Array diffRrs = arrayDiff(rrs);

    out['MeanNN'] = mean(rrs);
    out["SDNN"] = standardDeviation(rrs);

    out['RMSSD'] = sqrt(mean(arrayPow(diffRrs, 2)));
    out["SDSD"] = standardDeviation(diffRrs);

    return out;
  }

  static Map<String, double> calcTimeDomainRrs(List<double> rrs){
    var rrsArray = Array(rrs);
    Map<String, double> out = {};
    Array diffRrs = arrayDiff(rrsArray);

    out['MeanNN'] = mean(rrsArray);
    out["SDNN"] = standardDeviation(rrsArray);

    out['RMSSD'] = sqrt(mean(arrayPow(diffRrs, 2)));
    out["SDSD"] = standardDeviation(diffRrs);

    return out;
  }

  static FrequencyDomainData calcFrequencyDomainRrsData(List<RrsData> dataRrs){
    Map<String, double> out = {};
    var rrs = Array(dataRrs.map((i) => i.y.toDouble()).toList());
    var rrsMean = mean(rrs);
    var normRrs = rrs.map((rr) => rr - rrsMean).toList();
    final psdRes = psd(normRrs, 1);
    final len = psdRes.pxx.length;
    final lfBottomIndex = (len * 0.08).round();
    final lfTopIndex = (len * 0.30).round();
    final hfBottomIndex = lfTopIndex + 1;
    final hfTopIndex = (len * 0.8).round();
    final lf = psdRes.pxx.sublist(lfBottomIndex, lfTopIndex).reduce((a, b) => a + b);
    final hf = psdRes.pxx.sublist(hfBottomIndex, hfTopIndex).reduce((a, b) => a + b);

    out['coh'] = _coherence(psdRes.pxx);
    out['HF'] = hf;
    out['LF'] = lf;
    out['LF/HF'] = lf/hf;
    return FrequencyDomainData(psdRes, out);
  }

  static FrequencyDomainData calcFrequencyDomainRrs(List<double> rrs){
    Map<String, double> out = {};
    var rrsArray = Array(rrs);
    var rrsMean = mean(rrsArray);
    var normRrs = rrsArray.map((rr) => rr - rrsMean).toList();
    final psdRes = psd(normRrs, 1);
    final len = psdRes.pxx.length;
    final lfBottomIndex = (len * 0.08).round();
    final lfTopIndex = (len * 0.30).round();
    final hfBottomIndex = lfTopIndex + 1;
    final hfTopIndex = (len * 0.8).round();
    final lf = psdRes.pxx.sublist(lfBottomIndex, lfTopIndex).reduce((a, b) => a + b);
    final hf = psdRes.pxx.sublist(hfBottomIndex, hfTopIndex).reduce((a, b) => a + b);

    out['coh'] = _coherence(psdRes.pxx);
    out['HF'] = hf;
    out['LF'] = lf;
    out['LF/HF'] = lf/hf;
    return FrequencyDomainData(psdRes, out);
  }


//To Do fix
  static double _coherence (List<double> freq){
    double coh = (freq[1] / arraySum(Array(freq)));
    return coh;
  }

  static Array _rrsToPeak(Array rri, int sampling) {
    Array result = Array([0, (rri[0] / 1000) * sampling]);
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
  static Array hrvScore(Map<String, Array> hrvValues) {
    Array result = Array([]);
    for (var i = 0; i < hrvValues.length; i++) {
      var val = (_normalize(hrvValues['RMSSD']![i], "RMSSD") +
          _normalize(hrvValues['SDNN']![i], "SDNN")) / 2;
      result.add(val);
    }
    return result;
  }
}




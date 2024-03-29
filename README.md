<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This is a Flutter package which can be used to calcualate HRV values of given RR signal. This is still alpha version

## Features

You can calculate using it the following time domain HRV indexes:
- MeanNN
- SDNN
- RMSSD
- SDSD

And frequency domain indexes:
- HF
- LF 
- LF/HF


Package provide also robust filtering which is helpful for calcualting missing peaks within the signal using moving median filter

## Getting started
This library is using following dart packages:
- scidart 
- powerdart

## Usage




```dart
var List<RrsData> rrs = [RrsData(0, 0)]; // Here you aggregate your RR peaks from you device. (so far tested with polar H10)
var Map<String, double> hrvValues = {};

rrs = CalculateHrv.filterPeaks(rrs);
hrvValues.addAll(CalculateHrv.calcTimeDomain(rrs));
psd = CalculateHrv.calcFrequencyDomain(rrs);
hrvValues.addAll(psd.hrvFrequencyDomain);

// function to aggregate RrsData
  void _addToList(rr){
    rrs.add(RrsData((rrs.isEmpty ? 0 : rrs.last.x) + int.parse(rr.toString()), rr));
  }
```

It can be transformed to loop ofc:

```dart
rrs = [967, 967, 983, 923, 923, 895, 895, 895, 937, 967, 967, 967, 983, 983, 952, ...] # example data
List<RrsData> rrs_data = [];
for (var rr in rrs) {
    rrs_data.add(RrsData((rrs_data.isEmpty ? 0 : rrs_data.last.x) + rr, rr));
  }
```

UPDATA 

You can now use it as well this way
```dart
var List<double> rrs = [];
var Map<String, double> hrvValues = {};

rrs = CalculateHrv.filterPeaksRrs(rrs);
hrvValues.addAll(CalculateHrv.calcTimeDomainRrs(rrs));
psd = CalculateHrv.calcFrequencyDomain(rrs);
hrvValues.addAll(psd.hrvFrequencyDomain);
```

## Additional information

TODO:
- More time domain and frequency domain coeficients 
- Parametrize filtering
- Test with more devices


For contact, consultation and request:
przemyslaw.marciniak2@gmail.com

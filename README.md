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
And cohenrence as a frequency domain coeficient as well as the power spectrum of the RR signal 

Package provide also robust filtering which is helpful for calcualting missing peaks within the signal

## Getting started

scidart 
powerdart

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.


```dart
var List<RrsData> rrs = [RrsData(0, 0)]; // Here you aggregate your RR peaks from you device. (so far tested with polar H10)
var Map<String, double> hrvValues = {};

rrs = CalculateHrv.filterPeaks(rrs);
hrvValues.addAll(CalculateHrv.calcTimeDomain(rrsWindow));
psd = CalculateHrv.calcFrequencyDomain(rrsWindow);
hrvValues.addAll(psd.hrvFrequencyDomain);

// function to aggregate RrsData
  void _addToList(rr){
    rrs.add(RrsData((rrs.isEmpty ? 0 : rrs.last.x) + int.parse(rr.toString()), rr));
  }
```

## Additional information

TODO:
- More time domain and frequency domain coeficients 
- Parametrize filtering
- Test with more devices

part of 'calculations_bloc.dart';

abstract class CalculationsState {}

class CalculationsLoading extends CalculationsState {}

class CalculationsSuccess extends CalculationsState {
  // List<double>? gyroscopeValues;
  // List<double>? magnetoValues;
  // double angle;
  double calibratedPitch;
  double calibratedYaw;
  double calibratedRoll;
  double initialPitch;
  double initialYaw;
  double initialRoll;
  double meanAngle;

  CalculationsSuccess({
    required this.calibratedPitch,
    required this.calibratedYaw,
    required this.calibratedRoll,
    required this.initialPitch,
    required this.initialYaw,
    required this.initialRoll,
    required this.meanAngle,
  });
}

class CalculationsError extends CalculationsState {}

class CollectingData extends CalculationsState {
  int seconds;
  CollectingData(this.seconds);
}

class ReadyToCollectData extends CalculationsState {}

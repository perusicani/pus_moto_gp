part of 'calculations_bloc.dart';

abstract class CalculationsState {}

class CalculationsLoading extends CalculationsState {}

class CalculationsSuccess extends CalculationsState {
  // List<double>? accelerometerValues;
  // List<double>? gyroscopeValues;
  // List<double>? magnetoValues;
  double angle;

  CalculationsSuccess(
      // this.accelerometerValues,
      // this.gyroscopeValues,
      // this.magnetoValues,
      this.angle);
}

class CalculationsError extends CalculationsState {}

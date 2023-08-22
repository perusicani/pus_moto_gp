part of 'calculations_bloc.dart';

abstract class CalculationsEvent {}

class Calculate extends CalculationsEvent {}

class StartUprightCalibration extends CalculationsEvent {}

class StartTiltCalibration extends CalculationsEvent {}

class Calibrating extends CalculationsEvent {
  final int seconds;
  Calibrating(this.seconds);
}

class EmitCalibrated extends CalculationsEvent {}

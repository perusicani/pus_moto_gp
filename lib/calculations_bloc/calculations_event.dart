part of 'calculations_bloc.dart';

abstract class CalculationsEvent {}

class Reset extends CalculationsEvent {}

class Calculate extends CalculationsEvent {}

class StartRotationCalibration extends CalculationsEvent {}

class Calibrating extends CalculationsEvent {
  final int seconds;
  Calibrating(this.seconds);
}

class EmitCalibrated extends CalculationsEvent {}

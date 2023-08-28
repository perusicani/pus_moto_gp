import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:collection/collection.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

const double G = 9.81;
const int calibrationTime = 2;

class CalculationsBloc extends Bloc<CalculationsEvent, CalculationsState> {
  CalculationsBloc() : super(ReadyToCollectData()) {
    _init();
    on<Calculate>((event, emit) => _calculate(event, emit));
    on<EmitCalibrated>((event, emit) => _emit(event, emit));
    on<StartTiltCalibration>(
        (event, emit) => _startTiltCalibration(event, emit));
    on<StartUprightCalibration>(
        (event, emit) => _startUprightCalibration(event, emit));
    on<Calibrating>((event, emit) => _calibrating(event, emit));
  }

  List<double>? _a;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  // Persistent data
  List<double>? _aT;
  List<double>? _aF;

  List<double>? get tiltVals => _aT;
  List<double>? get flatVals => _aF;

  // Helper
  List<List<double>> _compiledData = [];
  bool _collectFlatData = false;
  bool _collectTiltData = false;
  bool _calculateAngle = false;

  void startCalculatingAngle() => _calculateAngle = true;

  void _init() {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _a = <double>[event.x, event.y, event.z];
          if (_collectTiltData) _compiledData.add(_a!);
          if (_collectFlatData) _compiledData.add(_a!);
          if (_calculateAngle) add(Calculate());
        },
      ),
    );
  }

  @override
  Future<void> close() {
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    return super.close();
  }

  void _calibrating(Calibrating event, Emitter<CalculationsState> emit) {
    emit(CollectingData(event.seconds));
  }

  void _calculate(Calculate event, Emitter<CalculationsState> emit) {
    if (_a == null) {
      emit(CalculationsLoading());
    } else {
      // compute cross product of collected data
      List<double> c = [];
      c.add(_aF![1] * _aT![2] - _aT![1] * _aF![2]);
      c.add(_aT![0] * _aF![2] - _aF![0] * _aT![2]);
      c.add(_aF![0] * _aT![1] - _aT![0] * _aF![2]);

      // X, Y, Z
      List<double> X = [0, 0, 0];
      List<double> Y = [0, 0, 0];
      List<double> Z = [0, 0, 0];

      for (var i = 0; i < 3; i++) {
        Y[i] = _aT![i] / G;
        // Tu ispadne c[0] == 0 - validiraj!!!
        if (c[0] == 0) c[0] = 0.1;
        if (c[1] == 0) c[1] = 0.1;
        if (c[2] == 0) c[2] = 0.1;
        Z[i] = c[i] / sqrt(c[0] * c[0]) + c[1] * c[1] + c[2] * c[2];
      }

      // compute X by cross product of Y and Z
      X[0] = Y[1] * Z[2] - Z[1] * Y[2];
      X[1] = Z[0] * Y[2] - Y[0] * Z[2];
      X[2] = Y[0] * Z[1] - Z[0] * Y[2];

      // Success state will be edited with the necessary data -> angle that should be shown or whatever we need
      emit(CalculationsSuccess(
        [
          A('x', X, Y, Z),
          A('y', X, Y, Z),
          A('z', X, Y, Z),
          _computeLean(A('x', X, Y, Z), A('y', X, Y, Z), A('z', X, Y, Z))
        ],
      ));
    }
  }

  double _computeLean(double Ax, double Ay, double Az) {
    double s = sqrt(Ax * Ax + Ay * Ay - G * G);

    double angle = asin((G * Ax - s * Ay) / (Ax * Ax + Ay * Ay));

    // print(angle);
    return angle;
  }

  // assume ax, ay, az are values given by accelerometer
  double A(
    String coordinate,
    List<double> X,
    List<double> Y,
    List<double> Z,
  ) {
    if (coordinate == 'x') {
      return _a![0] * X[0] + _a![1] * X[1] + _a![2] * X[2];
    } else if (coordinate == 'y') {
      return _a![0] * Y[0] + _a![1] * Y[1] + _a![2] * Y[2];
    } else {
      return _a![0] * Z[0] + _a![1] * Z[1] + _a![2] * Z[2];
    }
  }

  void _startTiltCalibration(
      StartTiltCalibration event, Emitter<CalculationsState> emit) {
    print("tilt calibration started");
    _collectTiltData = true;
    int secondsRemaining = calibrationTime;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Calibrating(secondsRemaining));
      if (secondsRemaining == 0) {
        _collectTiltData = false;

        List<double> x = [];
        List<double> y = [];
        List<double> z = [];

        // Average
        for (List<double> values in _compiledData) {
          x.add(values[0]);
          y.add(values[1]);
          z.add(values[2]);
        }

        _aT = [];
        _aT!.add(x.average);
        _aT!.add(y.average);
        _aT!.add(z.average);

        // Reset
        _compiledData = [];

        print("tilt calibration finished");
        timer.cancel();
        add(EmitCalibrated());
      }
      secondsRemaining--;
    });
  }

  void _emit(EmitCalibrated event, Emitter<CalculationsState> emit) =>
      emit(ReadyToCollectData());

  void _startUprightCalibration(
      StartUprightCalibration event, Emitter<CalculationsState> emit) {
    _collectFlatData = true;
    int secondsRemaining = calibrationTime;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Calibrating(secondsRemaining));
      if (secondsRemaining == 0) {
        _collectFlatData = false;

        List<double> x = [];
        List<double> y = [];
        List<double> z = [];

        // Average
        for (List<double> values in _compiledData) {
          x.add(values[0]);
          y.add(values[1]);
          z.add(values[2]);
        }

        _aF = [];
        _aF!.add(x.average);
        _aF!.add(y.average);
        _aF!.add(z.average);

        // Reset
        _compiledData = [];

        timer.cancel();
        add(EmitCalibrated());
      }
      secondsRemaining--;
    });
  }
}

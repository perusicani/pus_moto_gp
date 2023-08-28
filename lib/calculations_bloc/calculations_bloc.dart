import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

const double G = 9.81;
const int calibrationTime = 2;
const int deg = 180;
const double rad = pi;

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

  List<double> _averagePitch = [];

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
          if (_collectFlatData) {
            _compiledData.add(_a!);
          }
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
      // Spremljeno očitanje od trenutnog oduzet
      Vector3 _Rt = Vector3.array(_a!);
      Vector3 _Rs = Vector3.array(_aF!);
      Vector3 _R = _Rt;
      _R.sub(_Rs);

      double _pitch = asin(
        _R.x /
            (sqrt(pow(_R.x, 2) +
                sqrt(pow(_R.y, 2) +
                    sqrt(
                      pow(_R.z, 2),
                    )))),
      );

      double _roll = atan(_R.y / _R.z);

      double _rollRt = atan(_Rt.y / _Rt.z);
      double _rollRs = atan(_Rs.y / _Rs.z);

      double _subRoll = _rollRt - _rollRs;

      double _pitchRt = asin(
        _Rt.x /
            (sqrt(pow(_Rt.x, 2) +
                sqrt(pow(_Rt.y, 2) +
                    sqrt(
                      pow(_Rt.z, 2),
                    )))),
      );
      double _pitchRs = asin(
        _Rs.x /
            (sqrt(pow(_Rs.x, 2) +
                sqrt(pow(_Rs.y, 2) +
                    sqrt(
                      pow(_Rs.z, 2),
                    )))),
      );

      double _subPitch = _pitchRt - _pitchRs;

      _averagePitch.add(_subPitch);

      if (_averagePitch.length > 5) {
        // print(DateTime.now());
        emit(CalculationsSuccess([
          double.parse(degrees(_subPitch).toStringAsPrecision(3)),
          double.parse(degrees(_subRoll).toStringAsPrecision(3)),
          double.parse(degrees(_pitch).toStringAsPrecision(3)),
          double.parse(degrees(_roll).toStringAsPrecision(3)),
        ]));
        _averagePitch = [];
      }

      // print("_pitch");
      // print((_pitch).toStringAsPrecision(3));
      // print("_roll");
      // print((_roll).toStringAsPrecision(3));
      // emit(CalculationsSuccess([
      //   double.parse(degrees(_pitch).toStringAsPrecision(3)),
      //   double.parse(degrees(_roll).toStringAsPrecision(3)),
      // ]));
    }
    // else {
    //   // compute cross product of collected data
    //   List<double> c = [];
    //   c.add(_aF![1] * _aT![2] - _aT![1] * _aF![2]);
    //   c.add(_aT![0] * _aF![2] - _aF![0] * _aT![2]);
    //   c.add(_aF![0] * _aT![1] - _aT![0] * _aF![2]);

    //   // X, Y, Z
    //   List<double> X = [0, 0, 0];
    //   List<double> Y = [0, 0, 0];
    //   List<double> Z = [0, 0, 0];

    //   for (var i = 0; i < 3; i++) {
    //     Y[i] = _aT![i] / G;
    //     // Tu ispadne c[0] == 0 - validiraj!!!
    //     if (c[0] == 0) c[0] = 0.1;
    //     if (c[1] == 0) c[1] = 0.1;
    //     if (c[2] == 0) c[2] = 0.1;
    //     Z[i] = c[i] / sqrt(c[0] * c[0]) + c[1] * c[1] + c[2] * c[2];
    //   }

    //   // compute X by cross product of Y and Z
    //   X[0] = Y[1] * Z[2] - Z[1] * Y[2];
    //   X[1] = Z[0] * Y[2] - Y[0] * Z[2];
    //   X[2] = Y[0] * Z[1] - Z[0] * Y[2];

    //   // Success state will be edited with the necessary data -> angle that should be shown or whatever we need
    //   emit(CalculationsSuccess(
    //     [
    //       A('x', X, Y, Z),
    //       A('y', X, Y, Z),
    //       A('z', X, Y, Z),
    //       _computeLean(A('x', X, Y, Z), A('y', X, Y, Z), A('z', X, Y, Z))
    //     ],
    //   ));
    // }
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
        _aT!.add(double.parse(x.average.toStringAsPrecision(3)));
        _aT!.add(double.parse(y.average.toStringAsPrecision(3)));
        _aT!.add(double.parse(z.average.toStringAsPrecision(3)));

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
        _aF!.add(double.parse(x.average.toStringAsPrecision(3)));
        _aF!.add(double.parse(y.average.toStringAsPrecision(3)));
        _aF!.add(double.parse(z.average.toStringAsPrecision(3)));

        // Reset
        _compiledData = [];

        timer.cancel();
        add(EmitCalibrated());
      }
      secondsRemaining--;
    });
  }
}

import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:position_sensors/position_sensors.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math.dart';

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
    on<StartRotationCalibration>(
        (event, emit) => _startRotationCalibration(event, emit));
    on<Calibrating>((event, emit) => _calibrating(event, emit));
  }

  List<double>? _a;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  // Persistent data
  List<double>? _aT;
  List<double>? _aF;
  List<Quaternion> _rot = [];
  Quaternion? _calibration;

  List<double>? get tiltVals => _aT;
  List<double>? get flatVals => _aF;
  List<Quaternion>? get rotation => _rot;
  Quaternion? get calibration => _calibration;
  Quaternion? get inverse =>
      _calibration != null ? _calibration!.inverted() : null;

  // Helper
  List<List<double>> _compiledData = [];
  bool _collectFlatData = false;
  bool _collectTiltData = false;
  bool _collectRotationData = false;
  bool _calculateAngle = false;

  void startCalculatingAngle() => _calculateAngle = true;

  Future<void> _init() async {
    // _streamSubscriptions.add(
    //   accelerometerEvents.listen(
    //     (AccelerometerEvent event) {
    //       _a = <double>[event.x, event.y, event.z];
    //       if (_collectTiltData) _compiledData.add(_a!);
    //       if (_collectFlatData) _compiledData.add(_a!);
    //       if (_calculateAngle) add(Calculate());
    //     },
    //   ),
    // );
    _streamSubscriptions.add(
      PositionSensors.rotationEvents.listen((RotationEvent event) {
        // print(
        //     "Rotation vector: [x: ${event.x}, y: ${event.x}, z: ${event.z}, w: ${event.w}]");
        _currentRot = Quaternion(event.x, event.y, event.z, event.w);
        // EulerAngles a = toEulerAngles(_curentRot);
        // print(a.pitch);
        // print(a.roll);
        // print(a.yaw);
        if (_collectRotationData) {
          _rot.add(Quaternion(event.x, event.y, event.z, event.w));
        }
        if (_calculateAngle) add(Calculate());
      }),
    );
  }

  late Quaternion _currentRot;

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
    // if (_a == null) {
    //   emit(CalculationsLoading());
    // } else {

    if (_calculateAngle) {
      EulerAngles b = toEulerAngles(_currentRot);

      // trenutni quaternion * inverted calibration quaternion
      // https://paroj.github.io/gltut/Positioning/Tut08%20Quaternions.htmlx
      // a = trenutna
      // b = inverzna
      Quaternion r = Quaternion(
        _currentRot.w * inverse!.x +
            _currentRot.x * inverse!.w +
            _currentRot.y * inverse!.z -
            _currentRot.z * inverse!.y,
        _currentRot.w * inverse!.y +
            _currentRot.y * inverse!.w +
            _currentRot.z * inverse!.x -
            _currentRot.x * inverse!.z,
        _currentRot.w * inverse!.z +
            _currentRot.z * inverse!.w +
            _currentRot.x * inverse!.y -
            _currentRot.y * inverse!.x,
        _currentRot.w * inverse!.w -
            _currentRot.x * inverse!.x -
            _currentRot.y * inverse!.y -
            _currentRot.z * inverse!.z,
      );
      _currentRot = r;

      EulerAngles a = toEulerAngles(_currentRot);

      emit(CalculationsSuccess([
        0.0,
        degrees(b.pitch!),
        degrees(b.roll!),
        degrees(b.yaw!),
        0.0,
        0.0,
        0.0,
        degrees(a.pitch!),
        degrees(a.roll!),
        degrees(a.yaw!),
        0.0,
      ]));
    }
  }

// this implementation assumes normalized quaternion
// converts to Euler angles in 3-2-1 sequence
  EulerAngles toEulerAngles(Quaternion q) {
    EulerAngles angles = EulerAngles();

    // roll (x-axis rotation)
    double sinr_cosp = 2 * (q.w * q.x + q.y * q.z);
    double cosr_cosp = 1 - 2 * (q.x * q.x + q.y * q.y);
    angles.roll = atan2(sinr_cosp, cosr_cosp);

    // pitch (y-axis rotation)
    double sinp = sqrt(1 + 2 * (q.w * q.y - q.x * q.z));
    double cosp = sqrt(1 - 2 * (q.w * q.y - q.x * q.z));
    angles.pitch = 2 * atan2(sinp, cosp) - pi / 2;

    // yaw (z-axis rotation)
    double siny_cosp = 2 * (q.w * q.z + q.x * q.y);
    double cosy_cosp = 1 - 2 * (q.y * q.y + q.z * q.z);
    angles.yaw = atan2(siny_cosp, cosy_cosp);

    return angles;
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

  void _startRotationCalibration(
      StartRotationCalibration event, Emitter<CalculationsState> emit) {
    _collectRotationData = true;
    int secondsRemaining = calibrationTime;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Calibrating(secondsRemaining));
      if (secondsRemaining == 0) {
        _collectRotationData = false;

        List<double> x = [];
        List<double> y = [];
        List<double> z = [];
        List<double> w = [];
        // Average
        for (Quaternion values in _rot) {
          x.add(values.x);
          y.add(values.y);
          z.add(values.z);
          w.add(values.w);
        }

        _calibration = Quaternion(x.average, y.average, z.average, w.average);

        // Reset
        _rot = [];

        timer.cancel();
        add(EmitCalibrated());
      }
      secondsRemaining--;
    });
  }
}

class EulerAngles {
  double? roll, pitch, yaw;
  EulerAngles({this.pitch, this.roll, this.yaw});

  void setPitch(double val) {
    pitch = val;
  }

  void setRoll(double val) {
    roll = val;
  }

  void setYaw(double val) {
    yaw = val;
  }
}

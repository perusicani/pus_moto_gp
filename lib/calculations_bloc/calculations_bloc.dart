import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:collection/collection.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

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

  List<double>? _accelerometerValues;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  // Persistent data
  List<double>? _accelerometerTiltValues;
  List<double>? _accelerometerUprightValues;

  // Helper
  List<List<double>> _compiledData = [];
  bool _collectUprightData = false;
  bool _collectTiltData = false;

  void _init() {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          if (_collectTiltData) _compiledData.add(_accelerometerValues!);
          if (_collectUprightData) _compiledData.add(_accelerometerValues!);
          // add(Calculate());
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
    if (_accelerometerValues == null) {
      emit(CalculationsLoading());
    } else {
      // // TODO:
      //     Here goes the actual mat
      // hs
      // //

      // Success state will be edited with the necessary data -> angle that should be shown or whatever we need
      emit(CalculationsSuccess(_accelerometerValues!));
    }
  }

  void _startTiltCalibration(
      StartTiltCalibration event, Emitter<CalculationsState> emit) {
    print("tilt calibration started");
    _collectTiltData = true;
    int secondsRemaining = 5;

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

        _accelerometerTiltValues = [];
        _accelerometerTiltValues!.add(x.average);
        _accelerometerTiltValues!.add(y.average);
        _accelerometerTiltValues!.add(z.average);

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
    _collectUprightData = true;
    int secondsRemaining = 5;

    Timer.periodic(const Duration(seconds: 1), (timer) {
      add(Calibrating(secondsRemaining));
      if (secondsRemaining == 0) {
        _collectUprightData = false;

        List<double> x = [];
        List<double> y = [];
        List<double> z = [];

        // Average
        for (List<double> values in _compiledData) {
          x.add(values[0]);
          y.add(values[1]);
          z.add(values[2]);
        }

        _accelerometerUprightValues = [];
        _accelerometerUprightValues!.add(x.average);
        _accelerometerUprightValues!.add(y.average);
        _accelerometerUprightValues!.add(z.average);

        // Reset
        _compiledData = [];

        timer.cancel();
        add(EmitCalibrated());
      }
      secondsRemaining--;
    });
  }
}

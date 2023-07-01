import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

class CalculationsBloc extends Bloc<CalculationsEvent, CalculationsState> {
  CalculationsBloc() : super(CalculationsLoading()) {
    _init();
    on<Calculate>((event, emit) => _calculate(event, emit));
  }

  // List<double>? _accelerometerValues;
  // List<double>? _gyroscopeValues;
  List<double>? _magnetoValues;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void _init() {
    // _streamSubscriptions.add(
    //   accelerometerEvents.listen(
    //     (AccelerometerEvent event) {
    //       _accelerometerValues = <double>[event.x, event.y, event.z];
    //       add(Calculate());
    //     },
    //   ),
    // );
    // _streamSubscriptions.add(
    //   gyroscopeEvents.listen(
    //     (GyroscopeEvent event) {
    //       _gyroscopeValues = <double>[event.x, event.y, event.z];
    //       add(Calculate());
    //     },
    //   ),
    // );
    _streamSubscriptions.add(
      magnetometerEvents.listen(
        (MagnetometerEvent event) {
          _magnetoValues = <double>[event.x, event.y, event.z];
          add(Calculate());
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

  void _calculate(Calculate event, Emitter<CalculationsState> emit) {
    if (_magnetoValues == null) {
      emit(CalculationsLoading());
    } else {
      // // TODO:
      //     Here goes the actual maths
      // //

      // Success state will be edited with the necessary data -> angle that should be shown or whatever we need
      emit(CalculationsSuccess(
        _magnetoValues!.first,
      ));
    }
  }
}

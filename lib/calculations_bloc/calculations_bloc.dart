import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

part 'calculations_event.dart';
part 'calculations_state.dart';

class CalculationsBloc extends Bloc<CalculationsEvent, CalculationsState> {
  CalculationsBloc() : super(CalculationsLoading()) {
    _init();
    on<Calculate>((event, emit) => _calculate(event, emit));
  }

  bool _writeStill = false;
  bool _writeForward = false;
  bool _writeStillLeft = false;
  bool _writeStillRight = false;
  bool _writeForwardLeft = false;
  bool _writeForwardRight = false;

  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;
  final List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  void setWriteBool(String key) {
    switch (key) {
      case 'still':
        _writeStill = true;
        _writeForward = false;
        _writeForwardLeft = false;
        _writeForwardRight = false;
        _writeStillLeft = false;
        _writeStillRight = false;
        break;
      case 'forward':
        _writeStill = false;
        _writeForward = true;
        _writeForwardLeft = false;
        _writeForwardRight = false;
        _writeStillLeft = false;
        _writeStillRight = false;
        break;
      case 'still_left':
        _writeStill = false;
        _writeForward = false;
        _writeForwardLeft = false;
        _writeForwardRight = false;
        _writeStillLeft = true;
        _writeStillRight = false;
        break;
      case 'still_right':
        _writeStill = false;
        _writeForward = false;
        _writeForwardLeft = false;
        _writeForwardRight = false;
        _writeStillLeft = false;
        _writeStillRight = true;
        break;
      case 'forward_left':
        _writeStill = false;
        _writeForward = false;
        _writeForwardLeft = true;
        _writeForwardRight = false;
        _writeStillLeft = false;
        _writeStillRight = false;
        break;
      case 'forward_right':
        _writeStill = false;
        _writeForward = false;
        _writeForwardLeft = false;
        _writeForwardRight = true;
        _writeStillLeft = false;
        _writeStillRight = false;
        break;
      default:
    }
  }

  void _init() {
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          _accelerometerValues = <double>[event.x, event.y, event.z];
          if (_writeStill) writeReadings('still');
          if (_writeForward) writeReadings('forward');
          if (_writeStillLeft) writeReadings('still_left');
          if (_writeStillRight) writeReadings('still_right');
          if (_writeForwardLeft) writeReadings('forward_left');
          if (_writeForwardRight) writeReadings('forward_tight');
          emit(CalculationsSuccess(_accelerometerValues, _gyroscopeValues));
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          _gyroscopeValues = <double>[event.x, event.y, event.z];
          emit(CalculationsSuccess(_accelerometerValues, _gyroscopeValues));
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
    // if (_magnetoValues == null) {
    //   emit(CalculationsLoading());
    // } else {
    // // TODO:
    //     Here goes the actual maths
    // //

    // Success state will be edited with the necessary data -> angle that should b
    //e shown or whatever we need
    emit(CalculationsSuccess(_accelerometerValues, _gyroscopeValues));
    // }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> _localFile(String key) async {
    final path = await _localPath;
    return File('$path/$key.txt');
  }

  Future<void> writeReadings(String key) async {
    final file = await _localFile(key);

    // Write the file
    file.writeAsStringSync(
      "accelero: ${_accelerometerValues!.map((e) => e.toStringAsFixed(2)).toList().join(", ")}\ngyro: ${_gyroscopeValues!.map((e) => e.toStringAsFixed(2)).toList().join(", ")}\n",
      mode: FileMode.append,
    );
  }
}

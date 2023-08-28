import 'package:flutter/services.dart';
import 'package:position_sensors_platform_interface/position_sensors_platform_interface.dart';

/// Channel of commucation with the plataform SDK
class MethodChannelPositionSensors extends PositionSensorsPlatformInterface {
  MethodChannel methodChannel = const MethodChannel('position_sensors');

  static const EventChannel _rotationEventChannel =
      EventChannel('position_sensors/rotation');
  Stream<RotationEvent>? _rotationEvents;

  static const EventChannel _gameRotationEventChannel =
      EventChannel('position_sensors/gameRotation');
  Stream<RotationEvent>? _gameRotationEvents;

  static const EventChannel _magneticRotationEventChannel =
      EventChannel('position_sensors/magneticRotation');
  Stream<RotationEvent>? _magneticRotationEvents;

  static const EventChannel _magneticFieldEventChannel =
      EventChannel('position_sensors/magneticField');
  Stream<MagneticFieldEvent>? _magneticFieldEvents;

  static const EventChannel _uncalibratedMagneticFieldEventChannel =
      EventChannel('position_sensors/uncalibratedMagneticField');
  Stream<MagneticFieldEvent>? _uncalibratedMagneticFieldEvents;

  static const EventChannel _proximityEventChannel =
      EventChannel('position_sensors/proximity');
  Stream<ProximityEvent>? _proximityEvents;

  @override
  Stream<RotationEvent> get rotationEvents {
    _rotationEvents ??=
        _rotationEventChannel.receiveBroadcastStream().map((dynamic event) {
      final list = event.cast<double>();
      return RotationEvent(list[0]!, list[1]!, list[2]!);
    });
    return _rotationEvents!;
  }

  @override
  Stream<RotationEvent> get gameRotationEvents {
    _gameRotationEvents ??=
        _gameRotationEventChannel.receiveBroadcastStream().map((dynamic event) {
      final list = event.cast<double>();
      return RotationEvent(list[0]!, list[1]!, list[2]!);
    });
    return _gameRotationEvents!;
  }

  @override
  Stream<RotationEvent> get magneticRotationEvents {
    _magneticRotationEvents ??= _magneticRotationEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      final list = event.cast<double>();
      return RotationEvent(list[0]!, list[1]!, list[2]!);
    });
    return _magneticRotationEvents!;
  }

  @override
  Stream<MagneticFieldEvent> get magneticFieldEvents {
    _magneticFieldEvents ??= _magneticFieldEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      final list = event.cast<double>();
      return MagneticFieldEvent(list[0]!, list[1]!, list[2]!);
    });
    return _magneticFieldEvents!;
  }

  @override
  Stream<MagneticFieldEvent> get uncalibratedMagneticFieldEvents {
    _uncalibratedMagneticFieldEvents ??= _uncalibratedMagneticFieldEventChannel
        .receiveBroadcastStream()
        .map((dynamic event) {
      final list = event.cast<double>();
      return MagneticFieldEvent.uncalibrated(
          list[0]!, list[1]!, list[2]!, list[3]!, list[4]!, list[5]!);
    });
    return _uncalibratedMagneticFieldEvents!;
  }

  @override
  Stream<ProximityEvent> get proximityEvents {
    _proximityEvents ??=
        _proximityEventChannel.receiveBroadcastStream().map((dynamic event) {
      final list = event.cast<double>();
      return ProximityEvent(list[0]!);
    });
    return _proximityEvents!;
  }

  @override
  Future<List<String>?> get supportedSensors async {
    final List<String>? sensors =
        await methodChannel.invokeListMethod('getSupportedSensors');
    return sensors;
  }

  @override
  Future<int?> get delay async {
    final int? value = await methodChannel.invokeMethod('getDelay');
    return value;
  }

  @override
  Future<double?> get proximityFarValue async {
    final double? value =
        await methodChannel.invokeMethod('getProximityFarValue');
    return value;
  }

  @override
  Future<void> setDelay(int delay) async {
    await methodChannel.invokeMethod('setDelay', delay);
  }
}

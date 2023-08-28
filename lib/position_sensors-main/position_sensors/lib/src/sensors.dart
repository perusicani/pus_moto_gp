import 'package:position_sensors_platform_interface/position_sensors_platform_interface.dart';

/// Class that holds all event listeners and methods supported
class Sensors extends PositionSensorsPlatformInterface {
  factory Sensors() => _singleton ??= Sensors._();

  Sensors._();

  static Sensors? _singleton;

  static PositionSensorsPlatformInterface get _platform =>
      PositionSensorsPlatformInterface.instance;

  @override
  Stream<RotationEvent> get rotationEvents {
    return _platform.rotationEvents;
  }

  @override
  Stream<RotationEvent> get gameRotationEvents {
    return _platform.gameRotationEvents;
  }

  @override
  Stream<RotationEvent> get magneticRotationEvents {
    return _platform.magneticRotationEvents;
  }

  @override
  Stream<MagneticFieldEvent> get magneticFieldEvents {
    return _platform.magneticFieldEvents;
  }

  @override
  Stream<MagneticFieldEvent> get uncalibratedMagneticFieldEvents {
    return _platform.uncalibratedMagneticFieldEvents;
  }

  @override
  Stream<ProximityEvent> get proximityEvents {
    return _platform.proximityEvents;
  }

  @override
  Future<List<String>?> get supportedSensors async {
    return _platform.supportedSensors;
  }

  @override
  Future<int?> get delay async {
    return _platform.delay;
  }

  @override
  Future<double?> get proximityFarValue async {
    return _platform.proximityFarValue;
  }

  @override
  Future<void> setDelay(int delay) async {
    return _platform.setDelay(delay);
  }
}

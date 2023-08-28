import 'dart:async';

import 'package:position_sensors/src/sensors.dart';
import 'package:position_sensors_platform_interface/position_sensors_platform_interface.dart';
export 'package:position_sensors_platform_interface/position_sensors_platform_interface.dart';

final Sensors _sensors = Sensors();

/// Plugin's main class
class PositionSensors {
  /// Get the device's sensors supported by the plugin
  static Future<List<String>?> get supportedSensors async {
    return _sensors.supportedSensors;
  }

  /// Get the delay of the information stream
  static Future<int?> get delay async {
    return _sensors.delay;
  }

  /// Get the maximum value of proximity sensor
  static Future<double?> get proximityFarValue async {
    return _sensors.proximityFarValue;
  }

  /// Set the delay of the information stream
  static Future<void> setDelay(int delay) async {
    return _sensors.setDelay(delay);
  }

  /// Changes in rotation detected by the accelerometer, gyroscope and magnetometer
  static Stream<RotationEvent> get rotationEvents {
    return _sensors.rotationEvents;
  }

  /// Changes in rotation detected by the accelerometer and gyroscope
  static Stream<RotationEvent> get gameRotationEvents {
    return _sensors.gameRotationEvents;
  }

  /// Changes in rotation detected by the accelerometer and magnetometer
  static Stream<RotationEvent> get magneticRotationEvents {
    return _sensors.magneticRotationEvents;
  }

  /// Changes in earth's magnetic field detected by the magnetometer
  static Stream<MagneticFieldEvent> get magneticFieldEvents {
    return _sensors.magneticFieldEvents;
  }

  /// Changes in earth's magnetic field detected by the magnetometer (with iron bias)
  static Stream<MagneticFieldEvent> get uncalibratedMagneticFieldEvents {
    return _sensors.uncalibratedMagneticFieldEvents;
  }

  /// Changes in distace to some object detected by the proximity sensor
  static Stream<ProximityEvent> get proximityEvents {
    return _sensors.proximityEvents;
  }
}

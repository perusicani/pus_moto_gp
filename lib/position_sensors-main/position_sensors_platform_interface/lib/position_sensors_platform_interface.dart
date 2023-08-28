import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:position_sensors_platform_interface/src/magnect_field_event.dart';
import 'package:position_sensors_platform_interface/src/proximity_event.dart';
import 'package:position_sensors_platform_interface/src/rotation_event.dart';

import 'src/method_channel_position_sensors.dart';

export 'src/rotation_event.dart';
export 'src/magnect_field_event.dart';
export 'src/proximity_event.dart';

/// Common interface of the position_sensors plugin
abstract class PositionSensorsPlatformInterface extends PlatformInterface {
  static final Object _token = Object();

  PositionSensorsPlatformInterface() : super(token: _token);

  static PositionSensorsPlatformInterface _instance =
      MethodChannelPositionSensors();

  static PositionSensorsPlatformInterface get instance => _instance;

  static set instance(PositionSensorsPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Changes in rotation detected by the accelerometer, gyroscope and magnetometer
  Stream<RotationEvent> get rotationEvents {
    throw UnimplementedError('rotationEvents has not been implemented.');
  }

  /// Changes in rotation detected by the accelerometer and gyroscope
  Stream<RotationEvent> get gameRotationEvents {
    throw UnimplementedError('gameRotationEvents has not been implemented.');
  }

  /// Changes in rotation detected by the accelerometer and magnetometer
  Stream<RotationEvent> get magneticRotationEvents {
    throw UnimplementedError(
        'magneticRotationEvents has not been implemented.');
  }

  /// Changes in earth's magnetic field detected by the magnetometer
  Stream<MagneticFieldEvent> get magneticFieldEvents {
    throw UnimplementedError('magneticFieldEvents has not been implemented.');
  }

  /// Changes in earth's magnetic field detected by the magnetometer (with bias)
  Stream<MagneticFieldEvent> get uncalibratedMagneticFieldEvents {
    throw UnimplementedError(
        'uncalibratedMagneticField has not been implemented.');
  }

  /// Changes in distace to some object detected by the proximity sensor
  Stream<ProximityEvent> get proximityEvents {
    throw UnimplementedError('proximityEvents has not been implemented.');
  }

  /// Get the device's sensors supported by the plugin
  Future<List<String>?> get supportedSensors async {
    throw UnimplementedError('supportedSensors has not been implemented.');
  }

  /// Get the delay of the information stream
  Future<int?> get delay async {
    throw UnimplementedError('get delay has not been implemented.');
  }

  /// Get the maximum value of proximity sensor
  Future<double?> get proximityFarValue async {
    throw UnimplementedError('get proximityFarValue has not been implemented.');
  }

  /// Set the delay of the information stream
  Future<void> setDelay(int delay) async {
    throw UnimplementedError('setDelay has not been implemented.');
  }
}

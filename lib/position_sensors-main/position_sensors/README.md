# position_sensors

<a href="https://pub.dev/packages/position_sensors">
  <img src="https://img.shields.io/pub/v/position_sensors.svg?style=flat-square&label=Pub" alt="pub.dev link">
</a>

A plugin to access information about position sensors.

## Usage

The `PositionSensors` class contains all methods and events listeners.

```dart
import 'package:position_sensors/position_sensors.dart';

// Listen to rotation events
PositionSensors.rotationEvents.listen((event) {
    print("Rotation vector: [x: ${event.x}, y: ${event.x}, z: ${event.z}]")
    // Rotation vector: [x: 0.0, y: 0.0, z: 0.0]
});

print(await PositionSensors.supportedSensors);
// [proximity, rotation]

final int SENSOR_DELAY_GAME = 1;
await PositionSensors.setDelay(1);
print(await PositionSensors.delay);
// 1

// the maximum value, especially useful for binary proximity sensors
print(await PositionSensors.proximityFarValue);
```

The following sensors are available:

| Combination of sensors                   | Listener                        | Output             |
| :--------------------------------------- | :------------------------------ | :----------------- |
| accelerometer + gyroscope + magnetometer | rotationEvents                  | RotationEvent      |
| accelerometer + gyroscope                | gameRotationEvents              | RotationEvent      |
| accelerometer + magnetometer             | magneticRotationEvents          | RotationEvent      |
| magnetometer                             | magneticFieldEvents             | MagneticFieldEvent |
| magnetometer                             | uncalibratedMagneticFieldEvents | MagneticFieldEvent |
| proximity                                | proximityEvents                 | ProximityEvent     |

See more in https://developer.android.com/guide/topics/sensors/sensors_position.
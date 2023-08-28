/// An event that reports the device's rotation relative to some point.
class RotationEvent {
  RotationEvent(this.x, this.y, this.z);

  /// Rotation vector component along the x axis (x * sin(θ/2)).
  final double x;

  /// Rotation vector component along the y axis (y * sin(θ/2)).
  final double y;

  /// Rotation vector component along the z axis (z * sin(θ/2)).
  final double z;

  @override
  String toString() => '[RotationEvent (x: $x, y: $y, z: $z)]';
}

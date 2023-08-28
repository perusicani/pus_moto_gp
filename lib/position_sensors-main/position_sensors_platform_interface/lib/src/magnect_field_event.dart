/// An event that reports the strength of earth's magnetic field.
class MagneticFieldEvent {
  MagneticFieldEvent(this.x, this.y, this.z) {
    xBias = 0.0;
    yBias = 0.0;
    zBias = 0.0;
  }

  MagneticFieldEvent.uncalibrated(
      this.x, this.y, this.z, this.xBias, this.yBias, this.zBias);

  /// Geomagnetic field strength along the x axis.
  final double x;

  /// Geomagnetic field strength along the y axis.
  final double y;

  /// Geomagnetic field strength along the z axis.
  final double z;

  /// Iron bias estimation along the x axis.
  late final double xBias;

  /// Iron bias estimation along the y axis.
  late final double yBias;

  /// Iron bias estimation along the z axis.
  late final double zBias;

  @override
  String toString() => '[MagneticFieldEvent (x: $x, y: $y, z: $z)]';
}

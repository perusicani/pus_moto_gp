/// An event that reports the distance of the sensor to an object.
class ProximityEvent {
  ProximityEvent(this.distance);

  /// Distance from object (in cm)
  final double distance;

  @override
  String toString() => '[ProximityEvent (distance: $distance)]';
}

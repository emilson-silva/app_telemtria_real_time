class TelemetryData {
  final double latitude;
  final double longitude;
  final double altitude;
  final double speed;
  final double accuracy;
  final double heading;

  final double accelerometerX;
  final double accelerometerY;
  final double accelerometerZ;

  final double gyroscopeX;
  final double gyroscopeY;
  final double gyroscopeZ;
  final double magnetometerX;
  final double magnetometerY;
  final double magnetometerZ;

  final DateTime timestamp;
  const TelemetryData({
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.accuracy,
    required this.heading,
    required this.accelerometerX,
    required this.accelerometerY,
    required this.accelerometerZ,
    required this.gyroscopeX,
    required this.gyroscopeY,
    required this.gyroscopeZ,
    required this.magnetometerX,
    required this.magnetometerY,
    required this.magnetometerZ,
    required this.timestamp,
  });
}

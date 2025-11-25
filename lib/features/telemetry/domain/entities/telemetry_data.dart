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

  double get formattedSpeed => speed * 3.6; // Convert m/s to km/h

  double get speedKmh => speed * 3.6;

  double get accelerationMagnitude {
    return _calculateMagnitude(accelerometerX, accelerometerY, accelerometerZ);
  }

  double get gyroscopeMagnitude {
    return _calculateMagnitude(gyroscopeX, gyroscopeY, gyroscopeZ);
  }

  double get magnetometerMagnitude {
    return _calculateMagnitude(magnetometerX, magnetometerY, magnetometerZ);
  }

  double _calculateMagnitude(double x, double y, double z) {
    return (x * x + y * y + z * z).abs();
  }

  TelemetryData copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? speed,
    double? accuracy,
    double? heading,
    double? accelerometerX,
    double? accelerometerY,
    double? accelerometerZ,
    double? gyroscopeX,
    double? gyroscopeY,
    double? gyroscopeZ,
    double? magnetometerX,
    double? magnetometerY,
    double? magnetometerZ,
    DateTime? timestamp,
  }) {
    return TelemetryData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      accuracy: accuracy ?? this.accuracy,
      heading: heading ?? this.heading,
      accelerometerX: accelerometerX ?? this.accelerometerX,
      accelerometerY: accelerometerY ?? this.accelerometerY,
      accelerometerZ: accelerometerZ ?? this.accelerometerZ,
      gyroscopeX: gyroscopeX ?? this.gyroscopeX,
      gyroscopeY: gyroscopeY ?? this.gyroscopeY,
      gyroscopeZ: gyroscopeZ ?? this.gyroscopeZ,
      magnetometerX: magnetometerX ?? this.magnetometerX,
      magnetometerY: magnetometerY ?? this.magnetometerY,
      magnetometerZ: magnetometerZ ?? this.magnetometerZ,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Representação em string para debug
  @override
  String toString() {
    return 'TelemetryData('
        'lat: ${latitude.toStringAsFixed(6)}, '
        'lng: ${longitude.toStringAsFixed(6)}, '
        'speed: ${speed.toStringAsFixed(2)} m/s, '
        'time: $timestamp)';
  }

  /// Comparação de igualdade entre objetos
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TelemetryData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.altitude == altitude &&
        other.speed == speed &&
        other.accuracy == accuracy &&
        other.heading == heading &&
        other.accelerometerX == accelerometerX &&
        other.accelerometerY == accelerometerY &&
        other.accelerometerZ == accelerometerZ &&
        other.gyroscopeX == gyroscopeX &&
        other.gyroscopeY == gyroscopeY &&
        other.gyroscopeZ == gyroscopeZ &&
        other.magnetometerX == magnetometerX &&
        other.magnetometerY == magnetometerY &&
        other.magnetometerZ == magnetometerZ &&
        other.timestamp == timestamp;
  }

  /// Hash code para uso em coleções (Set, Map)
  @override
  int get hashCode => Object.hash(
    latitude,
    longitude,
    altitude,
    speed,
    accuracy,
    heading,
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
    magnetometerX,
    magnetometerY,
    magnetometerZ,
    timestamp,
  );
}

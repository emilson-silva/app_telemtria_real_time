import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../domain/entities/telemetry_data.dart';
import '../../domain/repositories/telemetry_repository.dart';
import '../datasources/location_data_source.dart';
import '../datasources/sensor_data_source.dart';

class TelemetryRepositoryImpl implements TelemetryRepository {
  final LocationDataSource locationDataSource;
  final SensorDataSource sensorDataSource;

  StreamSubscription<Position>? _locationSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;

  final StreamController<TelemetryData> _telemetryController =
      StreamController<TelemetryData>.broadcast();

  Position? _lastPosition;
  AccelerometerEvent? _lastAccelerometer;
  GyroscopeEvent? _lastGyroscope;
  MagnetometerEvent? _lastMagnetometer;

  bool _isTracking = false;

  TelemetryRepositoryImpl({
    required this.locationDataSource,
    required this.sensorDataSource,
  });

  @override
  Future<void> startTracking() async {
    if (_isTracking) return;

    _isTracking = true;

    _locationSubscription = locationDataSource.getLocationStream().listen(
      (position) {
        _lastPosition = position;
        _emitTelemetryData();
      },
      onError: (error) {
        print('❌ Erro no GPS: $error');
      },
    );

    _accelerometerSubscription = sensorDataSource
        .getAccelerometerStream()
        .listen(
          (event) {
            _lastAccelerometer = event;
            _emitTelemetryData();
          },
          onError: (error) {
            print('❌ Erro no acelerômetro: $error');
          },
        );

    _gyroscopeSubscription = sensorDataSource.getGyroscopeStream().listen(
      (event) {
        _lastGyroscope = event;
        _emitTelemetryData();
      },
      onError: (error) {
        print('❌ Erro no giroscópio: $error');
      },
    );

    _magnetometerSubscription = sensorDataSource.getMagnetometerStream().listen(
      (event) {
        _lastMagnetometer = event;
        _emitTelemetryData();
      },
      onError: (error) {
        print('❌ Erro no magnetômetro: $error');
      },
    );
  }

  @override
  Future<void> stopTracking() async {
    _isTracking = false;

    await _locationSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    await _gyroscopeSubscription?.cancel();
    await _magnetometerSubscription?.cancel();

    _locationSubscription = null;
    _accelerometerSubscription = null;
    _gyroscopeSubscription = null;
    _magnetometerSubscription = null;

    _lastPosition = null;
    _lastAccelerometer = null;
    _lastGyroscope = null;
    _lastMagnetometer = null;
  }

  @override
  Stream<TelemetryData> getTelemetryStream() {
    return _telemetryController.stream;
  }

  @override
  Future<bool> checkPermissions() async {
    return await locationDataSource.checkPermission();
  }

  @override
  Future<bool> requestPermissions() async {
    return await locationDataSource.requestPermission();
  }

  void _emitTelemetryData() {
    if (_lastPosition == null || _lastAccelerometer == null) {
      return;
    }

    final telemetryData = TelemetryData(
      latitude: _lastPosition!.latitude,
      longitude: _lastPosition!.longitude,
      altitude: _lastPosition!.altitude,
      speed: _lastPosition!.speed,
      accuracy: _lastPosition!.accuracy,
      heading: _lastPosition!.heading,

      accelerometerX: _lastAccelerometer!.x,
      accelerometerY: _lastAccelerometer!.y,
      accelerometerZ: _lastAccelerometer!.z,

      gyroscopeX: _lastGyroscope?.x ?? 0.0,
      gyroscopeY: _lastGyroscope?.y ?? 0.0,
      gyroscopeZ: _lastGyroscope?.z ?? 0.0,

      magnetometerX: _lastMagnetometer?.x ?? 0.0,
      magnetometerY: _lastMagnetometer?.y ?? 0.0,
      magnetometerZ: _lastMagnetometer?.z ?? 0.0,

      timestamp: DateTime.now(),
    );

    _telemetryController.add(telemetryData);
  }

  void dispose() {
    stopTracking();
    _telemetryController.close();
  }
}

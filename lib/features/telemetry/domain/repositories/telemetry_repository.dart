import '../entities/telemetry_data.dart';

abstract class TelemetryRepository {
  Future<void> startTracking();

  Future<void> stopTracking();

  Stream<TelemetryData> getTelemetryStream();

  Future<bool> checkPermissions();

  Future<bool> requestPermissions();
}

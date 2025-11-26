import '../repositories/telemetry_repository.dart';

class StopTracking {
  final TelemetryRepository repository;

  StopTracking(this.repository);

  Future<void> call() async {
    return await repository.stopTracking();
  }
}

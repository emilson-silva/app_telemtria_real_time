import '../repositories/telemetry_repository.dart';

class StartTracking {
  final TelemetryRepository repository;

  StartTracking(this.repository);

  Future<void> call() async {
    final hasPermissions = await repository.checkPermissions();

    if (!hasPermissions) {
      final granted = await repository.requestPermissions();
      if (!granted) {
        throw Exception('Permissões de localização negadas');
      }
    }

    return await repository.startTracking();
  }
}

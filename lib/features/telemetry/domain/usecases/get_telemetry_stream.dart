import '../entities/telemetry_data.dart';
import '../repositories/telemetry_repository.dart';

class GetTelemetryStream {
  final TelemetryRepository repository;

  GetTelemetryStream(this.repository);

  Stream<TelemetryData> call() {
    return repository.getTelemetryStream();
  }
}

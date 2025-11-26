import 'package:sensors_plus/sensors_plus.dart';

abstract class SensorDataSource {
  Stream<AccelerometerEvent> getAccelerometerStream();
  Stream<GyroscopeEvent> getGyroscopeStream();
  Stream<MagnetometerEvent> getMagnetometerStream();
}

class SensorDataSourceImpl implements SensorDataSource {
  @override
  Stream<AccelerometerEvent> getAccelerometerStream() {
    return accelerometerEventStream();
  }

  @override
  Stream<GyroscopeEvent> getGyroscopeStream() {
    return gyroscopeEventStream();
  }

  @override
  Stream<MagnetometerEvent> getMagnetometerStream() {
    return magnetometerEventStream();
  }
}

import 'package:app_telemtria_real_time/features/telemetry/data/repositories/temetry_repository_impl.dart';
import 'package:app_telemtria_real_time/features/telemetry/presetation/providers/telemetry_provider.dart';
import 'package:app_telemtria_real_time/features/telemetry/presetation/screens/telemetry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/telemetry/data/datasources/location_data_source.dart';
import 'features/telemetry/data/datasources/sensor_data_source.dart';
import 'features/telemetry/domain/repositories/telemetry_repository.dart';
import 'features/telemetry/domain/usecases/get_telemetry_stream.dart';
import 'features/telemetry/domain/usecases/start_tracking.dart';
import 'features/telemetry/domain/usecases/stop_tracking.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // Initialize data sources
    final locationDataSource = LocationDataSourceImpl();
    final sensorDataSource = SensorDataSourceImpl();

    // Initialize repository
    final TelemetryRepository telemetryRepository = TelemetryRepositoryImpl(
      locationDataSource: locationDataSource,
      sensorDataSource: sensorDataSource,
    );

    // Initialize use cases
    final startTrackingUseCase = StartTracking(telemetryRepository);
    final stopTrackingUseCase = StopTracking(telemetryRepository);
    final getTelemetryStreamUseCase = GetTelemetryStream(telemetryRepository);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TelemetryProvider(
            startTrackingUseCase: startTrackingUseCase,
            stopTrackingUseCase: stopTrackingUseCase,
            getTelemetryStreamUseCase: getTelemetryStreamUseCase,
            telemetryRepository: telemetryRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Telemetria em Tempo Real',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            foregroundColor: Colors.white,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        home: const TelemetryScreen(),
      ),
    );
  }
}

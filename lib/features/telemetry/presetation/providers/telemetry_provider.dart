/// ═══════════════════════════════════════════════════════════════════════════
/// PRESENTATION LAYER - PROVIDER (Gerenciador de Estado)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// O QUE É UM PROVIDER?
/// - Gerencia o ESTADO da aplicação (dados, loading, erros)
/// - Conecta a UI com os Use Cases do Domain
/// - Implementa o padrão Observer: notifica listeners quando o estado muda
/// - É a "ponte" entre a UI (widgets) e a lógica de negócio (use cases)
///
/// PADRÃO UTILIZADO: Provider + ChangeNotifier
/// - ChangeNotifier: classe do Flutter para gerenciar estado reativo
/// - notifyListeners(): avisa os widgets que algo mudou
/// - Os widgets se inscrevem com Consumer ou Provider.of
///
/// POR QUE USAR PROVIDER?
/// - Separação UI/Lógica: widgets não chamam use cases diretamente
/// - Reatividade: UI atualiza automaticamente quando estado muda
/// - Testabilidade: podemos testar o provider sem widgets
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/telemetry_data.dart';
import '../../domain/usecases/start_tracking.dart';
import '../../domain/usecases/stop_tracking.dart';
import '../../domain/usecases/get_telemetry_stream.dart';
import '../../domain/repositories/telemetry_repository.dart';

class TelemetryProvider with ChangeNotifier {
  final StartTracking startTrackingUseCase;
  final StopTracking stopTrackingUseCase;
  final GetTelemetryStream getTelemetryStreamUseCase;
  final TelemetryRepository telemetryRepository;

  TelemetryData? _currentData;
  bool _isTracking = false;
  String? _errorMessage;
  StreamSubscription<TelemetryData>? _telemetrySubscription;

  TelemetryProvider({
    required this.startTrackingUseCase,
    required this.stopTrackingUseCase,
    required this.getTelemetryStreamUseCase,
    required this.telemetryRepository,
  });

  TelemetryData? get currentData => _currentData;
  bool get isTracking => _isTracking;
  String? get errorMessage => _errorMessage;

  bool get hasData => _currentData != null;

  Future<void> checkAndRequestPermissions() async {
    try {
      final hasPermission = await telemetryRepository.checkPermissions();

      if (!hasPermission) {
        final granted = await telemetryRepository.requestPermissions();

        if (!granted) {
          _errorMessage = '⚠️ Permissões de localização negadas';
          notifyListeners();
          return;
        }
      }

      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = '❌ Erro ao verificar permissões: $e';
      notifyListeners();
    }
  }

  Future<void> startTracking() async {
    try {
      _errorMessage = null;
      notifyListeners();

      await startTrackingUseCase();

      _isTracking = true;

      _listenToTelemetry();

      notifyListeners();
    } catch (e) {
      _errorMessage = '❌ Erro ao iniciar rastreamento: $e';
      _isTracking = false;
      notifyListeners();
    }
  }

  Future<void> stopTracking() async {
    try {
      await stopTrackingUseCase();

      _isTracking = false;

      await _telemetrySubscription?.cancel();
      _telemetrySubscription = null;

      notifyListeners();
    } catch (e) {
      _errorMessage = '❌ Erro ao parar rastreamento: $e';
      notifyListeners();
    }
  }

  Future<void> toggleTracking() async {
    if (_isTracking) {
      await stopTracking();
    } else {
      await startTracking();
    }
  }

  void _listenToTelemetry() {
    _telemetrySubscription = getTelemetryStreamUseCase().listen(
      (data) {
        _currentData = data;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = '❌ Erro no stream: $error';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    super.dispose();
  }
}

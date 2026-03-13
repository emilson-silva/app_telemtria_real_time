// ignore: dangling_library_doc_comments
/// ═══════════════════════════════════════════════════════════════════════════
/// DATA LAYER - DATA SOURCE (Fonte de Dados)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// O QUE É UM DATA SOURCE?
/// - É a FONTE REAL dos dados
/// - Faz comunicação com APIs externas (GPS, sensores, APIs REST, BD)
/// - Conhece os detalhes de implementação (pacotes específicos)
///
/// POR QUE SEPARAR EM DATA SOURCES?
/// - Separação de responsabilidades (GPS em um lugar, sensores em outro)
/// - Facilita testar (podemos mockar cada fonte separadamente)
/// - Facilita trocar implementações (ex: trocar pacote de GPS)
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';

/// Interface abstrata para fonte de dados de localização GPS
///
/// Esta interface define o contrato para operações de GPS
abstract class LocationDataSource {
  /// Verifica se a permissão de localização foi concedida
  Future<bool> checkPermission();

  /// Solicita permissão de localização ao usuário
  Future<bool> requestPermission();

  /// Retorna um stream contínuo de posições GPS
  Stream<Position> getLocationStream();
}

/// Implementação concreta usando o pacote Geolocator
///
/// PACOTE USADO: geolocator
/// - Um dos pacotes mais populares para GPS em Flutter
/// - Funciona em Android e iOS
/// - Gerencia permissões automaticamente
class LocationDataSourceImpl implements LocationDataSource {
  StreamController<Position>? _locationController;

  @override
  Future<bool> checkPermission() async {
    // Verifica o status atual da permissão
    LocationPermission permission = await Geolocator.checkPermission();

    // Retorna true se temos permissão (sempre ou enquanto usa o app)
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestPermission() async {
    // Primeiro verifica o status atual
    LocationPermission permission = await Geolocator.checkPermission();

    // Se negado, solicita ao usuário
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Se negado permanentemente, não pode solicitar novamente
    // Usuário precisa ir nas configurações do telefone
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    // Retorna true se conseguiu permissão
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Stream<Position> getLocationStream() async* {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
        'Serviço de localização desativado. Ative o GPS do aparelho.',
      );
    }

    final LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
        intervalDuration: const Duration(seconds: 2),
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.fitness,
        distanceFilter: 1,
        pauseLocationUpdatesAutomatically: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 1,
      );
    }

    final firstPosition = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
    yield firstPosition;

    yield* Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  void dispose() {
    _locationController?.close();
  }
}

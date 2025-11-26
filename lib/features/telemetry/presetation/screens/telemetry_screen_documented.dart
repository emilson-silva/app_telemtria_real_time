/// ═══════════════════════════════════════════════════════════════════════════
/// PRESENTATION LAYER - SCREEN (Tela Principal)
/// ═══════════════════════════════════════════════════════════════════════════
///
/// Esta é a TELA PRINCIPAL do app
///
/// RESPONSABILIDADES:
/// - Exibir a UI para o usuário
/// - Escutar mudanças no Provider (estado)
/// - Chamar métodos do Provider quando usuário interage
/// - NÃO contém lógica de negócio (só UI)
///
/// WIDGETS USADOS:
/// - Consumer<TelemetryProvider>: Escuta mudanças no provider
/// - TelemetryInfoCard: Exibe dados em cards
/// - FloatingActionButton: Botão para iniciar/parar
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/telemetry_provider.dart';
import '../widgets/telemetry_info_card.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelemetryProvider>().checkAndRequestPermissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📡 Telemetria em Tempo Real'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<TelemetryProvider>(
        builder: (context, provider, child) {
          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(fontSize: 16, color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.checkAndRequestPermissions(),
                      icon: Icon(Icons.refresh),
                      label: Text('Tentar Novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!provider.isTracking) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 24),
                  Text(
                    'Rastreamento Desativado',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no botão para iniciar',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          if (!provider.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Aguardando dados do GPS...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final data = provider.currentData!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('🛰️ Localização GPS'),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    TelemetryInfoCard(
                      title: 'Velocidade',
                      value: '${data.speedKmh.toStringAsFixed(1)} km/h',
                      icon: Icons.speed,
                      color: Colors.blue,
                    ),
                    TelemetryInfoCard(
                      title: 'Altitude',
                      value: '${data.altitude.toStringAsFixed(0)} m',
                      icon: Icons.terrain,
                      color: Colors.green,
                    ),
                    TelemetryInfoCard(
                      title: 'Latitude',
                      value: data.latitude.toStringAsFixed(6),
                      icon: Icons.my_location,
                      color: Colors.orange,
                    ),
                    TelemetryInfoCard(
                      title: 'Longitude',
                      value: data.longitude.toStringAsFixed(6),
                      icon: Icons.place,
                      color: Colors.purple,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                _buildSectionTitle('📐 Acelerômetro (m/s²)'),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    TelemetryInfoCard(
                      title: 'Eixo X',
                      value: data.accelerometerX.toStringAsFixed(2),
                      icon: Icons.swap_horiz,
                      color: Colors.red,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Y',
                      value: data.accelerometerY.toStringAsFixed(2),
                      icon: Icons.swap_vert,
                      color: Colors.green,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Z',
                      value: data.accelerometerZ.toStringAsFixed(2),
                      icon: Icons.height,
                      color: Colors.blue,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                // ══════════════════════════════════════════════════════════
                // SEÇÃO: GIROSCÓPIO
                // ══════════════════════════════════════════════════════════
                _buildSectionTitle('🔄 Giroscópio (rad/s)'),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    TelemetryInfoCard(
                      title: 'Eixo X',
                      value: data.gyroscopeX.toStringAsFixed(2),
                      icon: Icons.rotate_left,
                      color: Colors.orange,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Y',
                      value: data.gyroscopeY.toStringAsFixed(2),
                      icon: Icons.rotate_right,
                      color: Colors.teal,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Z',
                      value: data.gyroscopeZ.toStringAsFixed(2),
                      icon: Icons.loop,
                      color: Colors.indigo,
                    ),
                  ],
                ),

                SizedBox(height: 24),

                _buildSectionTitle('🧲 Magnetômetro (μT)'),
                SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    TelemetryInfoCard(
                      title: 'Eixo X',
                      value: data.magnetometerX.toStringAsFixed(1),
                      icon: Icons.explore,
                      color: Colors.pink,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Y',
                      value: data.magnetometerY.toStringAsFixed(1),
                      icon: Icons.explore_outlined,
                      color: Colors.deepPurple,
                    ),
                    TelemetryInfoCard(
                      title: 'Eixo Z',
                      value: data.magnetometerZ.toStringAsFixed(1),
                      icon: Icons.compass_calibration,
                      color: Colors.cyan,
                    ),
                  ],
                ),

                SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Consumer<TelemetryProvider>(
        builder: (context, provider, child) {
          return FloatingActionButton.extended(
            onPressed: () => provider.toggleTracking(),
            icon: Icon(provider.isTracking ? Icons.stop : Icons.play_arrow),
            label: Text(provider.isTracking ? 'Parar' : 'Iniciar'),
            backgroundColor: provider.isTracking ? Colors.red : Colors.green,
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey[800],
      ),
    );
  }
}

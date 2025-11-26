import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/telemetry_provider.dart';
import '../widgets/telemetry_info_card.dart';

class TelemetryScreen extends StatefulWidget {
  const TelemetryScreen({super.key});

  @override
  State<TelemetryScreen> createState() => _TelemetryScreenState();
}

class _TelemetryScreenState extends State<TelemetryScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  double? _lastLat;
  double? _lastLng;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelemetryProvider>().checkAndRequestPermissions();
    });
  }

  void _updateMarker(double lat, double lng) {
    if (!mounted) return;

    setState(() {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('current_position'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Localização Atual'),
        ),
      );
    });

    if (_mapController != null) {
      try {
        _mapController!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      } catch (e) {
        // Handle potential errors gracefully
      }
    }
  }

  @override
  void dispose() {
    try {
      _mapController?.dispose();
    } catch (_) {}
    _mapController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final telemetryProvider = context.watch<TelemetryProvider>();
    final currentData = telemetryProvider.currentData;
    final isTracking = telemetryProvider.isTracking;
    final errorMessage = telemetryProvider.errorMessage;

    if (currentData != null) {
      final lat = currentData.latitude;
      final lng = currentData.longitude;
      if (_lastLat != lat || _lastLng != lng) {
        _lastLat = lat;
        _lastLng = lng;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _updateMarker(lat, lng);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Telemetria em Tempo Real'),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth > 800;

          return Column(
            children: [
              Expanded(
                flex: isWideScreen ? 2 : 1,
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-23.550520, -46.633308),
                    zoom: 15,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  compassEnabled: true,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),
              ),

              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        if (errorMessage != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red[300]!),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(color: Colors.red[700]),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        if (currentData != null) ...[
                          _buildDataGrid(context, currentData, isWideScreen),
                        ] else ...[
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.location_off,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Aguardando dados...',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Inicie o rastreamento para ver os dados',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Control Button
                        SizedBox(
                          width: isWideScreen ? 300 : double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (isTracking) {
                                telemetryProvider.stopTracking();
                              } else {
                                telemetryProvider.startTracking();
                              }
                            },
                            icon: Icon(
                              isTracking ? Icons.stop : Icons.play_arrow,
                              size: 28,
                            ),
                            label: Text(
                              isTracking
                                  ? 'Parar Rastreamento'
                                  : 'Iniciar Rastreamento',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isTracking
                                  ? Colors.red[600]
                                  : Colors.green[600],
                              foregroundColor: Colors.white,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataGrid(
    BuildContext context,
    dynamic currentData,
    bool isWideScreen,
  ) {
    final items = [
      {
        'title': 'Velocidade',
        'value': '${currentData.speedKmh.toStringAsFixed(1)} km/h',
        'icon': Icons.speed,
        'color': Colors.blue[600]!,
      },
      {
        'title': 'Direção',
        'value': '${currentData.heading.toStringAsFixed(0)}°',
        'icon': Icons.navigation,
        'color': Colors.purple[600]!,
      },
      {
        'title': 'Aceleração X',
        'value': '${currentData.accelerometerX.toStringAsFixed(2)} m/s²',
        'icon': Icons.swap_horiz,
        'color': Colors.orange[600]!,
      },
      {
        'title': 'Aceleração Y',
        'value': '${currentData.accelerometerY.toStringAsFixed(2)} m/s²',
        'icon': Icons.swap_vert,
        'color': Colors.green[600]!,
      },
      {
        'title': 'Aceleração Z',
        'value': '${currentData.accelerometerZ.toStringAsFixed(2)} m/s²',
        'icon': Icons.height,
        'color': Colors.red[600]!,
      },
      {
        'title': 'Latitude',
        'value': currentData.latitude.toStringAsFixed(6),
        'icon': Icons.place,
        'color': Colors.teal[600]!,
      },
      {
        'title': 'Longitude',
        'value': currentData.longitude.toStringAsFixed(6),
        'icon': Icons.place,
        'color': Colors.indigo[600]!,
      },
    ];

    if (isWideScreen) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return TelemetryInfoCard(
            title: item['title'] as String,
            value: item['value'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
          );
        },
      );
    } else {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return TelemetryInfoCard(
            title: item['title'] as String,
            value: item['value'] as String,
            icon: item['icon'] as IconData,
            color: item['color'] as Color,
          );
        },
      );
    }
  }
}

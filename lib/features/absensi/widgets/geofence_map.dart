import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../absensi_provider.dart';

class InteractiveGeofenceMap extends StatefulWidget {
  const InteractiveGeofenceMap({super.key});

  @override
  State<InteractiveGeofenceMap> createState() => _InteractiveGeofenceMapState();
}

class _InteractiveGeofenceMapState extends State<InteractiveGeofenceMap> {
  final MapController _mapController = MapController();

  void _reCenter(LatLng target) {
    _mapController.move(target, 16.5);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AbsensiProvider>();

    final officeLatLng = LatLng(provider.officeLat, provider.officeLng);
    final userPos = provider.currentPosition;
    final userLatLng = userPos != null ? LatLng(userPos.latitude, userPos.longitude) : officeLatLng;

    final distance = provider.distanceToOfficeMeters;
    final isInside = provider.isInsideGeofence;

    final CircleMarker geofenceCircle = CircleMarker(
      point: officeLatLng,
      radius: provider.officeRadiusMeters,
      useRadiusInMeter: true,
      color: isInside
          ? AppColors.success.withOpacity(0.18)
          : AppColors.danger.withOpacity(0.18),
      borderColor: isInside ? AppColors.success : AppColors.danger,
      borderStrokeWidth: 2.2,
    );

    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Peta Interaktif (OpenStreetMap)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: userPos != null ? userLatLng : officeLatLng,
                initialZoom: 16.5,
                minZoom: 13.0,
                maxZoom: 18.5,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.simpeg.kpi.mobile',
                ),
                CircleLayer(
                  circles: [geofenceCircle],
                ),
                MarkerLayer(
                  markers: [
                    // Marker KPI Pusat
                    Marker(
                      point: officeLatLng,
                      width: 80,
                      height: 50,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'KPI Pusat',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.red,
                            size: 26,
                          ),
                        ],
                      ),
                    ),

                    // Marker Posisi User GPS
                    if (userPos != null)
                      Marker(
                        point: userLatLng,
                        width: 44,
                        height: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (isInside ? AppColors.success : AppColors.danger)
                                    .withOpacity(0.25),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isInside ? AppColors.success : AppColors.danger,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // Top Status Bar Badge (Overlay)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      distance == null
                          ? Icons.location_searching_rounded
                          : (isInside ? Icons.verified_user_rounded : Icons.warning_amber_rounded),
                      color: distance == null
                          ? AppColors.gray
                          : (isInside ? AppColors.success : AppColors.danger),
                      size: 19,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            distance == null
                                ? 'Menentukan Lokasi Presensi...'
                                : (isInside ? 'Dalam Radius Presensi' : 'Di Luar Radius Presensi'),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: distance == null
                                  ? AppColors.black
                                  : (isInside ? AppColors.success : AppColors.danger),
                            ),
                          ),
                          Text(
                            distance == null
                                ? 'Ketuk ikon GPS untuk memperbarui lokasi'
                                : 'Jarak: ${distance.toStringAsFixed(0)}m dari KPI Pusat (Max ${provider.officeRadiusMeters.toInt()}m)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.gray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom-Right Floating Controls (Re-center & Refresh)
            Positioned(
              bottom: 12,
              right: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'map_recenter_user',
                    elevation: 3,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.black,
                    onPressed: () {
                      if (userPos != null) {
                        _reCenter(userLatLng);
                      } else {
                        provider.updateCurrentLocation();
                      }
                    },
                    child: provider.isFetchingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.red),
                          )
                        : const Icon(Icons.my_location_rounded, size: 18),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

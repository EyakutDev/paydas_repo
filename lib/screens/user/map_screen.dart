import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/app_colors.dart';
import '../../models/restaurant.dart';
import '../../services/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _userLocation;
  String _errorMessage = '';
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Konum servisleri kapalı.\nLütfen konumunuzu açın.';
          });
        }
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            setState(() {
              _errorMessage =
                  'Konum izni reddedildi.\nHaritayı kullanmak için izin verin.';
            });
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _errorMessage =
                'Konum izni kalıcı olarak reddedildi.\nAyarlardan izin vermeniz gerekiyor.';
          });
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint('Harita hatası: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Konum alınırken hata oluştu:\n$e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          // AppBar
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.map_outlined, color: AppColors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Harita',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Firebase Stream Builder
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseService.getBusinesses(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Hata: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];

                // Firestore verilerini Restaurant modeline çevir
                final restaurants = docs.map((doc) {
                  return Restaurant.fromMap(
                    doc.data() as Map<String, dynamic>,
                    doc.id,
                  );
                }).toList();

                return Column(
                  children: [
                    // Harita Alanı
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: _errorMessage.isNotEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    _errorMessage,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              )
                            : FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter:
                                      _userLocation ??
                                      const LatLng(41.0082, 28.9784),
                                  initialZoom: 13.0,
                                  interactionOptions: const InteractionOptions(
                                    flags:
                                        InteractiveFlag.all &
                                        ~InteractiveFlag.rotate,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.paydas.app',
                                  ),
                                  if (_userLocation != null)
                                    MarkerLayer(
                                      markers: [
                                        // Kullanıcı
                                        Marker(
                                          point: _userLocation!,
                                          width: 60,
                                          height: 60,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.blue,
                                            size: 40,
                                          ),
                                        ),
                                        // İşletmeler
                                        ...restaurants.map(
                                          (place) => Marker(
                                            point: LatLng(
                                              place.latitude,
                                              place.longitude,
                                            ),
                                            width: 50,
                                            height: 50,
                                            child: _buildPlacePin(place),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                      ),
                    ),

                    // İşletme Listesi
                    if (restaurants.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.store_mall_directory,
                              size: 18,
                              color: AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Kayıtlı İşletmeler',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${restaurants.length} işletme',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: restaurants.length,
                          itemBuilder: (context, index) {
                            final place = restaurants[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.inputBorder.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryGreen.withOpacity(
                                        0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.storefront,
                                      color: AppColors.primaryGreen,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          place.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          place.address.isNotEmpty
                                              ? place.address
                                              : 'Adres girilmemiş',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary
                                                .withOpacity(0.8),
                                          ),
                                        ),
                                        if (place.askiItemCount > 0)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4.0,
                                            ),
                                            child: Text(
                                              '${place.askiItemCount} askıda ürün',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.primaryGreen,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Mesafe hesaplama eklenebilir
                                  if (_userLocation != null &&
                                      place.latitude != 0 &&
                                      place.longitude != 0)
                                    _buildDistanceChip(place),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ] else ...[
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Text(
                            'Henüz kayıtlı işletme bulunmuyor.',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacePin(Restaurant place) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: AppColors.primaryGreen, width: 2),
          ),
          child: const Center(
            child: Icon(Icons.store, size: 16, color: AppColors.primaryGreen),
          ),
        ),
        const Icon(
          Icons.arrow_drop_down,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildDistanceChip(Restaurant place) {
    final distance = Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      place.latitude,
      place.longitude,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        distance < 1000
            ? '${distance.toStringAsFixed(0)}m'
            : '${(distance / 1000).toStringAsFixed(1)}km',
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

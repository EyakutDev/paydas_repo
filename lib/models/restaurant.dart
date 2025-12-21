class Restaurant {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final int askiItemCount;
  final double rating; // Added rating

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.askiItemCount = 0,
    this.rating = 0.0, // Default value
  });

  // Demo verisi için factory
  factory Restaurant.demo({
    required String id,
    required String name,
    String? distance,
    int askiItemCount = 5,
  }) {
    return Restaurant(
      id: id,
      name: name,
      address: 'Demo Adres',
      distance: distance ?? '800m uzakta',
      latitude: 41.0082,
      longitude: 28.9784,
      askiItemCount: askiItemCount,
      rating: 4.5, // Demo rating
    );
  }
  factory Restaurant.fromMap(Map<String, dynamic> map, String id) {
    return Restaurant(
      id: id,
      name: map['name'] ?? '',
      address: map['address'] ?? '',
      distance: '1.2km', // Hesaplama yapılana kadar dummy
      imageUrl: map['imageUrl'],
      latitude: map['latitude'] ?? 41.0082,
      longitude: map['longitude'] ?? 28.9784,
      askiItemCount: map['askiCount'] ?? 0,
      rating: (map['rating'] ?? 0.0).toDouble(), // Fetch rating
    );
  }
}

class Restaurant {
  final String id;
  final String name;
  final String address;
  final String distance;
  final String? imageUrl;
  final double latitude;
  final double longitude;
  final int askiItemCount;

  Restaurant({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.askiItemCount = 0,
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
    );
  }
}

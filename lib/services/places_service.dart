import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/restaurant.dart';

class PlacesService {
  // ⚠️ DİKKAT: Buraya kendi Google Places API Key'inizi girmelisiniz.
  // Google Cloud Console'dan "Places API (New)" veya "Places API" servisini aktif edip API Key almalısınız.
  // Ayrıca faturalandırma hesabının bağlı olduğundan emin olun.
  static String get _apiKey => dotenv.env['PLACES_API_KEY'] ?? 'YOUR_GOOGLE_PLACES_API_KEY';

  static Future<List<Restaurant>> getNearbyPlaces(LatLng location) async {
    if (_apiKey == 'YOUR_GOOGLE_PLACES_API_KEY') {
      // API Key girilmemişse boş liste veya demo data dön
      print('UYARI: Google Places API Key girilmemiş!');
      return [];
    }

    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

    // Aranan türler: restoran, fırın, market, kafe
    // Google Places API type parametresi tek bir tip alır veya keyword kullanılabilir.
    // Birden fazla tip için keyword kullanmak daha esnektir.
    final String keyword = 'restoran,fırın,market,cafe';

    final String url =
        '$baseUrl?location=${location.latitude},${location.longitude}&radius=1000&keyword=$keyword&language=tr&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final List results = data['results'];

          return results.map((place) {
            final loc = place['geometry']['location'];
            final lat = loc['lat'];
            final lng = loc['lng'];

            // Mesafeyi hesapla (basit bir kuş uçuşu hesaplama veya API'den gelmez, kendimiz hesaplarız)
            // Ancak şimdilik sadece görsel olarak UI'da göstereceğiz.

            return Restaurant(
              id:
                  place['place_id'] ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              name: place['name'] ?? 'Bilinmeyen İşletme',
              address: place['vicinity'] ?? 'Adres yok',
              imageUrl: place['icon'] ?? '', // Google ikonu
              rating: (place['rating'] ?? 0.0).toDouble(),
              latitude: lat,
              longitude: lng,
              distance: 'Yakın', // Sonra hesaplanabilir
              askiItemCount:
                  0, // Dışarıdan gelen veri olduğu için askı bilgisi yok
            );
          }).toList();
        } else {
          print(
            'Places API Hata: ${data['status']} - ${data['error_message']}',
          );
          return [];
        }
      } else {
        print('HTTP Hata: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Servis Hatası: $e');
      return [];
    }
  }
}

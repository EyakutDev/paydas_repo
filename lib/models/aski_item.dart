import 'menu_item.dart';

class AskiItem {
  final String id;
  final MenuItem menuItem;
  final int quantity;
  final DateTime addedAt;
  AskiStatus status;
  String? reservedByUserId;
  String? reservedByUserName;
  DateTime? reservedAt;

  AskiItem({
    required this.id,
    required this.menuItem,
    required this.quantity,
    required this.addedAt,
    this.status = AskiStatus.available,
    this.reservedByUserId,
    this.reservedByUserName,
    this.reservedAt,
  });

  factory AskiItem.fromMap(Map<String, dynamic> map, String docId) {
    // MenuItem'ı map'ten oluşturuyoruz (Firebase'de düz olarak saklanıyor)
    final menuItem = MenuItem.fromMap(map);
    return AskiItem(
      id: docId,
      menuItem: menuItem,
      quantity: map['quantity'] ?? 0,
      addedAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      status: AskiStatus.values.firstWhere(
        (e) => e.toString() == 'AskiStatus.${map['status'] ?? 'available'}',
        orElse: () => AskiStatus.available,
      ),
    );
  }
}

enum AskiStatus {
  available, // Bekliyor
  reserved, // Rezerve edildi
  delivered, // Teslim edildi
  cancelled, // İptal edildi
}

class ReservationItem {
  final String id;
  final AskiItem askiItem;
  final String userId;
  final String userName;
  final DateTime reservedAt;
  ReservationStatus status;

  ReservationItem({
    required this.id,
    required this.askiItem,
    required this.userId,
    required this.userName,
    required this.reservedAt,
    this.status = ReservationStatus.pending,
    this.code,
  });

  final String? code;

  factory ReservationItem.fromMap(Map<String, dynamic> map, String docId) {
    // AskiItem'ı basitleştirilmiş şekilde oluşturuyoruz
    final menuItem = MenuItem(
      id: map['itemId'] ?? '',
      name: map['itemName'] ?? '',
      price: 0, // Fiyat bilgisi rezervasyon kaydında yoksa 0
      categoryId: '',
    );

    return ReservationItem(
      id: docId,
      askiItem: AskiItem(
        id: map['itemId'] ?? '',
        menuItem: menuItem,
        quantity: 1, // Rezervasyon 1 adet varsayılıyor
        addedAt: DateTime.now(),
      ),
      userId: map['visitorId'] ?? '',
      userName: 'Müşteri', // İsim kaydı yoksa varsayılan
      reservedAt: (map['createdAt'] as dynamic).toDate(),
      status: ReservationStatus.values.firstWhere(
        (e) =>
            e.toString() == 'ReservationStatus.${map['status'] ?? 'pending'}',
        orElse: () => ReservationStatus.pending,
      ),
      code: map['code'],
    );
  }
}

enum ReservationStatus {
  pending, // Bekliyor
  confirmed, // Onaylandı
  delivered, // Teslim edildi
  cancelled, // İptal edildi
}

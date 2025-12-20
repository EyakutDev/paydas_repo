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
  });
}

enum ReservationStatus {
  pending, // Bekliyor
  confirmed, // Onaylandı
  delivered, // Teslim edildi
  cancelled, // İptal edildi
}

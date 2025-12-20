class MenuItem {
  final String id;
  final String name;
  final double price;
  int quantity;
  final String categoryId;
  bool isOnAski;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
    required this.categoryId,
    this.isOnAski = false,
  });

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? categoryId,
    bool? isOnAski,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      categoryId: categoryId ?? this.categoryId,
      isOnAski: isOnAski ?? this.isOnAski,
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final List<MenuItem> items;

  MenuCategory({required this.id, required this.name, List<MenuItem>? items})
    : items = items ?? [];

  MenuCategory copyWith({String? id, String? name, List<MenuItem>? items}) {
    return MenuCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      items: items ?? this.items,
    );
  }
}

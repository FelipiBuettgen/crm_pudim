class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String categoryId;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.categoryId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'categoryId': categoryId,
    };
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      categoryId: map['categoryId'] ?? '',
    );
  }
}

class MenuCategory {
  final String id;
  final String name;
  final String iconCode;

  MenuCategory({required this.id, required this.name, required this.iconCode});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iconCode': iconCode};
  }

  factory MenuCategory.fromMap(Map<String, dynamic> map) {
    return MenuCategory(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      iconCode: map['iconCode'] ?? '',
    );
  }
}

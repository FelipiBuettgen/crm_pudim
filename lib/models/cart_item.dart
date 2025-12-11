import 'menu_item.dart';

class CartItem {
  final String id;
  final MenuItem menuItem;
  int quantity;
  String? observations;

  CartItem({
    required this.id,
    required this.menuItem,
    this.quantity = 1,
    this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'menuItem': menuItem.toMap(),
      'quantity': quantity,
      'observations': observations,
      'totalPrice': totalPrice,
    };
  }

  double get totalPrice => menuItem.price * quantity;
}

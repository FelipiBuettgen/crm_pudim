import '../models/menu_item.dart';
import '../models/order_model.dart';
import '../models/cart_item.dart';

class MockData {
  static final List<MenuCategory> categories = [
    MenuCategory(id: '1', name: 'Pudins', iconCode: 'pudding'),
    MenuCategory(id: '2', name: 'Bebidas', iconCode: 'drink'),
    MenuCategory(id: '3', name: 'Sobremesas', iconCode: 'dessert'),
  ];

  static final List<MenuItem> menuItems = [
    MenuItem(
      id: '1',
      name: 'Pudim de Leite',
      description: 'O clássico pudim de leite condensado.',
      price: 12.0,
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: '1',
    ),
    MenuItem(
      id: '2',
      name: 'Pudim de Chocolate',
      description: 'Pudim cremoso de chocolate belga.',
      price: 15.0,
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: '1',
    ),
    MenuItem(
      id: '3',
      name: 'Café Expresso',
      description: 'Café forte e encorpado.',
      price: 5.0,
      imageUrl: 'https://via.placeholder.com/150',
      categoryId: '2',
    ),
  ];

  static List<OrderModel> getOrders() {
    return List.generate(20, (index) {
      final status = OrderStatus.values[index % OrderStatus.values.length];
      final createdAt = DateTime.now().subtract(
        Duration(days: index % 5, hours: index),
      );
      final completedAt =
          (status == OrderStatus.delivered || status == OrderStatus.ready)
          ? createdAt.add(Duration(minutes: 15 + (index % 30)))
          : null;

      return OrderModel(
        id: 'order_$index',
        orderNumber: 1000 + index,
        items: [
          CartItem(
            id: 'item_$index',
            menuItem: menuItems[index % menuItems.length],
            quantity: (index % 3) + 1,
          ),
        ],
        total: menuItems[index % menuItems.length].price * ((index % 3) + 1),
        status: status,
        createdAt: createdAt,
        completedAt: completedAt,
        paymentMethod: index % 2 == 0 ? 'Credit Card' : 'Pix',
      );
    });
  }
}

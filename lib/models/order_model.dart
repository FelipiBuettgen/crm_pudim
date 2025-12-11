import 'cart_item.dart';
import 'menu_item.dart';

enum OrderStatus { pending, preparing, ready, delivered, cancelled }

class OrderModel {
  final String id;
  final int orderNumber;
  final List<CartItem> items;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? preparedAt;
  final DateTime? completedAt;
  final String paymentMethod;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.preparedAt,
    this.completedAt,
    required this.paymentMethod,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'items': items.map((x) => x.toMap()).toList(),
      'total': total,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'preparedAt': preparedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      orderNumber: map['orderNumber'] ?? 0,
      items: map['items'] != null
          ? List<CartItem>.from(
              (map['items'] as List<dynamic>).map<CartItem>(
                (x) => CartItem(
                  id: x['id'],
                  menuItem: MenuItem.fromMap(
                    Map<String, dynamic>.from(x['menuItem']),
                  ),
                  quantity: x['quantity'],
                  observations: x['observations'],
                ),
              ),
            )
          : [],
      total: (map['total'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(map['createdAt']),
      preparedAt: map['preparedAt'] != null
          ? DateTime.parse(map['preparedAt'])
          : null,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      paymentMethod: map['paymentMethod'] ?? '',
    );
  }

  Duration? get preparationTime {
    if (completedAt != null) {
      return completedAt!.difference(createdAt);
    }
    return null;
  }
}

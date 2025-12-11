import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../models/menu_item.dart';

class FirebaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Orders
  Stream<List<OrderModel>> getOrders() {
    late StreamController<List<OrderModel>> controller;
    List<OrderModel> activeOrders = [];
    List<OrderModel> archivedOrders = [];

    void emitCombined() {
      final allOrders = [...activeOrders, ...archivedOrders];
      // Sort by createdAt descending
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      controller.add(allOrders);
    }

    List<OrderModel> parseOrders(DataSnapshot snapshot) {
      final data = snapshot.value;
      if (data == null) return [];

      final List<OrderModel> orders = [];
      if (data is Map) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['id'] = key;
          try {
            orders.add(OrderModel.fromMap(map));
          } catch (e) {
            print('Error parsing order $key: $e');
          }
        });
      }
      return orders;
    }

    StreamSubscription? activeSub;
    StreamSubscription? archivedSub;

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        activeSub = _db.child('orders').onValue.listen((event) {
          activeOrders = parseOrders(event.snapshot);
          emitCombined();
        });

        archivedSub = _db.child('archived_orders').onValue.listen((event) {
          archivedOrders = parseOrders(event.snapshot);
          emitCombined();
        });
      },
      onCancel: () {
        activeSub?.cancel();
        archivedSub?.cancel();
      },
    );

    return controller.stream;
  }

  // Menu Items
  Stream<List<MenuItem>> getMenuItems() {
    return _db.child('menu_items').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final List<MenuItem> items = [];
      if (data is Map) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['id'] = key;
          items.add(MenuItem.fromMap(map));
        });
      } else if (data is List) {
        for (var item in data) {
          if (item != null) {
            final map = Map<String, dynamic>.from(item as Map);
            items.add(MenuItem.fromMap(map));
          }
        }
      }
      return items;
    });
  }

  // Categories
  Stream<List<MenuCategory>> getCategories() {
    return _db.child('categories').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return [];

      final List<MenuCategory> categories = [];
      if (data is Map) {
        data.forEach((key, value) {
          final map = Map<String, dynamic>.from(value as Map);
          map['id'] = key;
          categories.add(MenuCategory.fromMap(map));
        });
      } else if (data is List) {
        for (var item in data) {
          if (item != null) {
            final map = Map<String, dynamic>.from(item as Map);
            categories.add(MenuCategory.fromMap(map));
          }
        }
      }
      return categories;
    });
  }

  // Add Menu Item
  Future<void> addMenuItem(MenuItem item) {
    final newRef = _db.child('menu_items').push();
    // We might want to use the key as ID, or if ID is already generated
    final itemWithId = MenuItem(
      id: newRef.key!,
      name: item.name,
      description: item.description,
      price: item.price,
      imageUrl: item.imageUrl,
      categoryId: item.categoryId,
    );
    return newRef.set(itemWithId.toMap());
  }

  // Update Menu Item
  Future<void> updateMenuItem(MenuItem item) {
    return _db.child('menu_items').child(item.id).update(item.toMap());
  }

  // Upload Image
  Future<String> uploadImage(
    Uint8List fileBytes,
    String fileName,
    String contentType,
  ) async {
    final ref = _storage.ref().child('menu_images/$fileName');
    final metadata = SettableMetadata(contentType: contentType);
    final uploadTask = ref.putData(fileBytes, metadata);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  // Update Order Status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) {
    final Map<String, dynamic> updates = {'status': status.name};

    if (status == OrderStatus.preparing) {
      updates['preparedAt'] = DateTime.now().toIso8601String();
    } else if (status == OrderStatus.ready || status == OrderStatus.delivered) {
      // Assuming ready or delivered marks completion of preparation/process
      updates['completedAt'] = DateTime.now().toIso8601String();
    }

    return _db.child('orders').child(orderId).update(updates);
  }
}

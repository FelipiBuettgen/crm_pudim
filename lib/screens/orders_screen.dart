import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import '../models/order_model.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _filter = 'Ativos'; // 'Ativos', 'Arquivados', 'Todos'

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return StreamBuilder<List<OrderModel>>(
      stream: firebaseService.getOrders(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allOrders = snapshot.data ?? [];

        // Apply filter
        final orders = allOrders.where((order) {
          if (_filter == 'Todos') return true;

          final isArchived =
              order.status == OrderStatus.delivered ||
              order.status == OrderStatus.cancelled;

          if (_filter == 'Arquivados') return isArchived;
          if (_filter == 'Ativos') return !isArchived;

          return true;
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pedidos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  // Filter Chips
                  Row(
                    children: [
                      _buildFilterChip('Ativos'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Arquivados'),
                      const SizedBox(width: 8),
                      _buildFilterChip('Todos'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),
              if (orders.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Text(
                      'Nenhum pedido encontrado para este filtro.',
                      style: TextStyle(color: AppTheme.gray),
                    ),
                  ),
                )
              else
                Card(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(
                            order.status,
                          ).withOpacity(0.1),
                          child: Icon(
                            Icons.receipt,
                            color: _getStatusColor(order.status),
                          ),
                        ),
                        title: Text('Pedido #${order.orderNumber}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)} - ${order.items.length} itens',
                            ),
                            if (order.preparationTime != null)
                              Text(
                                'Tempo de preparo: ${order.preparationTime!.inMinutes} min',
                                style: const TextStyle(
                                  color: AppTheme.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'R\$ ${order.total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                  order.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                order.status.name.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          setState(() {
            _filter = label;
          });
        }
      },
      backgroundColor: Colors.white,
      selectedColor: AppTheme.primary.withOpacity(0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppTheme.primary : AppTheme.gray,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : Colors.grey.shade300,
        ),
      ),
      showCheckmark: false,
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warning;
      case OrderStatus.preparing:
        return AppTheme.secondary;
      case OrderStatus.ready:
        return AppTheme.success;
      case OrderStatus.delivered:
        return AppTheme.primary;
      case OrderStatus.cancelled:
        return AppTheme.danger;
    }
  }
}

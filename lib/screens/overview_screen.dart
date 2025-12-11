import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';
import '../widgets/stat_card.dart';
import '../widgets/sales_chart.dart';
import '../services/firebase_service.dart';
import '../models/order_model.dart';

class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

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

        final orders = snapshot.data ?? [];
        final stats = _calculateStats(orders);
        final chartData = _generateChartData(orders);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visão Geral',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
              const Text(
                'Acompanhe o desempenho da sua loja em tempo real',
                style: TextStyle(color: AppTheme.gray, fontSize: 16),
              ),
              const SizedBox(height: 30),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 1200
                      ? 4
                      : (width > 800 ? 2 : 1);

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    childAspectRatio: 1.5,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      StatCard(
                        title: 'Vendas Totais',
                        value: 'R\$ ${stats['totalSales'].toStringAsFixed(2)}',
                        change: stats['salesChange'],
                        isIncrease: stats['salesIncrease'],
                        icon: FontAwesomeIcons.dollarSign,
                        color: AppTheme.success,
                      ),
                      StatCard(
                        title: 'Pedidos',
                        value: '${stats['totalOrders']}',
                        change: stats['ordersChange'],
                        isIncrease: stats['ordersIncrease'],
                        icon: FontAwesomeIcons.bagShopping,
                        color: AppTheme.secondary,
                      ),
                      StatCard(
                        title: 'Ticket Médio',
                        value: 'R\$ ${stats['avgTicket'].toStringAsFixed(2)}',
                        change: stats['ticketChange'],
                        isIncrease: stats['ticketIncrease'],
                        icon: FontAwesomeIcons.chartPie,
                        color: AppTheme.warning,
                      ),
                      StatCard(
                        title: 'Tempo Médio',
                        value: '${stats['avgPrepTime']} min',
                        change: stats['prepTimeChange'],
                        isIncrease: stats['prepTimeIncrease'],
                        icon: FontAwesomeIcons.clock,
                        color: AppTheme.primary,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 30),
              Container(
                height: 400,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Vendas nos últimos 30 dias',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SalesChart(
                        spots: chartData['spots'] as List<FlSpot>,
                        maxY: chartData['maxY'] as double,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _calculateStats(List<OrderModel> orders) {
    final now = DateTime.now();
    final startOfCurrentPeriod = now.subtract(const Duration(days: 30));
    final startOfPreviousPeriod = now.subtract(const Duration(days: 60));

    // Current Period Stats
    final currentOrders = orders
        .where((o) => o.createdAt.isAfter(startOfCurrentPeriod))
        .toList();

    double totalSales = 0;
    int totalOrders = currentOrders.length;
    int totalPrepTimeMinutes = 0;
    int completedOrdersCount = 0;

    for (var order in currentOrders) {
      totalSales += order.total;
      if (order.preparationTime != null) {
        totalPrepTimeMinutes += order.preparationTime!.inMinutes;
        completedOrdersCount++;
      }
    }

    double avgTicket = totalOrders > 0 ? totalSales / totalOrders : 0;
    int avgPrepTime = completedOrdersCount > 0
        ? (totalPrepTimeMinutes / completedOrdersCount).round()
        : 0;
    int customers = (totalOrders * 0.7).floor();

    // Previous Period Stats
    final prevOrders = orders
        .where(
          (o) =>
              o.createdAt.isAfter(startOfPreviousPeriod) &&
              o.createdAt.isBefore(startOfCurrentPeriod),
        )
        .toList();

    double prevTotalSales = 0;
    int prevTotalOrders = prevOrders.length;
    int prevTotalPrepTimeMinutes = 0;
    int prevCompletedOrdersCount = 0;

    for (var order in prevOrders) {
      prevTotalSales += order.total;
      if (order.preparationTime != null) {
        prevTotalPrepTimeMinutes += order.preparationTime!.inMinutes;
        prevCompletedOrdersCount++;
      }
    }

    double prevAvgTicket = prevTotalOrders > 0
        ? prevTotalSales / prevTotalOrders
        : 0;
    int prevAvgPrepTime = prevCompletedOrdersCount > 0
        ? (prevTotalPrepTimeMinutes / prevCompletedOrdersCount).round()
        : 0;
    int prevCustomers = (prevTotalOrders * 0.7).floor();

    // Calculate Changes
    String calculateChange(num current, num previous) {
      if (previous == 0) return current > 0 ? '+100%' : '0%';
      final change = ((current - previous) / previous) * 100;
      return '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)}%';
    }

    bool isIncrease(num current, num previous) {
      return current >= previous;
    }

    return {
      'totalSales': totalSales,
      'totalOrders': totalOrders,
      'avgTicket': avgTicket,
      'customers': customers,
      'avgPrepTime': avgPrepTime,
      'salesChange': calculateChange(totalSales, prevTotalSales),
      'salesIncrease': isIncrease(totalSales, prevTotalSales),
      'ordersChange': calculateChange(totalOrders, prevTotalOrders),
      'ordersIncrease': isIncrease(totalOrders, prevTotalOrders),
      'ticketChange': calculateChange(avgTicket, prevAvgTicket),
      'ticketIncrease': isIncrease(avgTicket, prevAvgTicket),
      'customersChange': calculateChange(customers, prevCustomers),
      'customersIncrease': isIncrease(customers, prevCustomers),
      'prepTimeChange': calculateChange(avgPrepTime, prevAvgPrepTime),
      'prepTimeIncrease':
          avgPrepTime <= prevAvgPrepTime, // Lower time is better (Green)
    };
  }

  Map<String, dynamic> _generateChartData(List<OrderModel> orders) {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));
    final Map<int, double> dailyTotals = {};

    // Initialize all 30 days with 0
    for (int i = 0; i <= 30; i++) {
      dailyTotals[i] = 0;
    }

    for (var order in orders) {
      if (order.createdAt.isAfter(thirtyDaysAgo)) {
        final difference = now.difference(order.createdAt).inDays;
        // Map difference (0-29) to chart x-axis (30-1)
        // Actually, let's map day 1 to 30 days ago, day 30 to today.
        // difference = 0 means today. difference = 29 means 29 days ago.
        // x = 30 - difference.
        // If difference is 0 (today), x = 30.
        // If difference is 29 (29 days ago), x = 1.
        final dayIndex = 30 - difference;
        if (dayIndex >= 1 && dayIndex <= 30) {
          dailyTotals[dayIndex] = (dailyTotals[dayIndex] ?? 0) + order.total;
        }
      }
    }

    final List<FlSpot> spots = [];
    double maxY = 0;

    for (int i = 1; i <= 30; i++) {
      final total = dailyTotals[i] ?? 0;
      spots.add(FlSpot(i.toDouble(), total));
      if (total > maxY) maxY = total;
    }

    if (maxY == 0) maxY = 100; // Default scale if no sales

    return {'spots': spots, 'maxY': maxY};
  }
}

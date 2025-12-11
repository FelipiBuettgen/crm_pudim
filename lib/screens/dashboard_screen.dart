import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import 'overview_screen.dart';
import 'orders_screen.dart';
import 'menu_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const OverviewScreen(),
    const OrdersScreen(),
    const MenuScreen(),
    const Center(child: Text('Financeiro - Em breve')),
    const Center(child: Text('Configurações - Em breve')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedIndex: _selectedIndex,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
          Expanded(child: _screens[_selectedIndex]),
        ],
      ),
    );
  }
}

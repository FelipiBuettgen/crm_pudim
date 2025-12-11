import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../theme/app_theme.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: AppTheme.primary,
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Icon(FontAwesomeIcons.bowlFood, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text(
                  'O Pudim Perfeito',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CRM & Analytics',
                  style: TextStyle(color: AppTheme.light, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildNavItem(0, 'Visão Geral', FontAwesomeIcons.chartLine),
          _buildNavItem(1, 'Pedidos', FontAwesomeIcons.receipt),
          _buildNavItem(2, 'Cardápio', FontAwesomeIcons.utensils),
          _buildNavItem(3, 'Financeiro', FontAwesomeIcons.wallet),
          const Spacer(),
          _buildNavItem(4, 'Configurações', FontAwesomeIcons.gear),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String title, IconData icon) {
    final isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : AppTheme.light,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : AppTheme.light,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isSelected ? AppTheme.secondary : null,
      onTap: () => onItemSelected(index),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

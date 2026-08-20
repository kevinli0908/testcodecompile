import 'package:flutter/material.dart';
import '../screens/touch_controller_screen.dart';
import '../theme/app_theme.dart';

class BottomTabBar extends StatelessWidget {
  final TabType selectedTab;
  final Function(TabType) onTabChanged;

  const BottomTabBar({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // 水平方向填充
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTabItem(
            icon: Icons.touch_app,
            label: 'Gestures',
            tab: TabType.gestures,
          ),
          _buildTabItem(
            icon: Icons.devices,
            label: 'Device',
            tab: TabType.device,
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required TabType tab,
  }) {
    final isSelected = selectedTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabChanged(tab),
        child: Container(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
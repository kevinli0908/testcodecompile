import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DeviceSettingCard extends StatelessWidget {
  final VoidCallback onSwitchToDeviceTab; // 改为切换 Tab 的回调

  const DeviceSettingCard({super.key, required this.onSwitchToDeviceTab});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSwitchToDeviceTab, // 点击时切换 Tab
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 14, 23, 41),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'assets/images/icon_003.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const Text(
                    'Device Settings',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

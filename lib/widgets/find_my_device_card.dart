import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FindMyDeviceCard extends StatelessWidget {
  final VoidCallback onSectionTap;
  final VoidCallback onPlaySound;

  const FindMyDeviceCard({
    super.key,
    required this.onSectionTap,
    required this.onPlaySound,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onSectionTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromARGB(255,14,23,41),
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
                      'assets/images/icon_002.png',
                      width: 48,
                      height: 48,
                    ),
                  ),
                  const Text(
                    'Find My Device',
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
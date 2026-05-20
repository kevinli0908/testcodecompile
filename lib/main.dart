import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/touch_controller_screen.dart';
import 'services/storage/storage_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService().init();
  runApp(const TouchControllerApp());
}

class TouchControllerApp extends StatelessWidget {
  const TouchControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Touch Controller',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const TouchControllerScreen(),
    );
  }
}
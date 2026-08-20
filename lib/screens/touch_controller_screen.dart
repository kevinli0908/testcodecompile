import 'package:flutter/material.dart';
import 'package:flutter_bee_project/screens/quick_start_guide_screen.dart';
import 'package:flutter_bee_project/screens/scan_screen.dart';
import 'package:flutter_bee_project/services/bluetooth/ota_manager.dart';
import 'package:flutter_bee_project/widgets/scan_item_card.dart';
import '../models/device_model.dart';
import '../theme/app_font.dart';
import '../widgets/customize_gesture_card.dart';
import '../widgets/device_setting_card.dart';
import '../widgets/find_my_device_card.dart';
import '../widgets/quick_start_guide_card.dart';
import 'device_settings_screen.dart';
import '../widgets/bottom_tab_bar.dart';
import '../theme/app_theme.dart';
import 'customize_gesture_screen.dart';
import 'find_my_device_screen.dart';
import 'device_settings_detail_screen.dart';
import '../services/bluetooth/omni_ble.dart';
import '../services/bluetooth/ota_manager.dart';

class TouchControllerScreen extends StatefulWidget{
  const TouchControllerScreen({super.key});

  @override
  State<TouchControllerScreen> createState() => _TouchControllerScreenState();
}

enum TabType { gestures, device }

class _TouchControllerScreenState extends State<TouchControllerScreen>{
  TabType _selectedTab = TabType.gestures;
  DeviceModel _device = DeviceModel.defaultDevice();
  //final BleManager _bleManager = BleManager();

  @override
  void initState() {
    super.initState();
    //_connectBleDevice();
  }

  void _updateDevice(DeviceModel updatedDevice) {
    setState(() {
      _device = updatedDevice;
    });
  }

  void _switchToDeviceTab() {
    setState(() {
      _selectedTab = TabType.device;
    });
  }

  void _switchToGestureTab() {
    setState(() {
      _selectedTab = TabType.gestures;
    });
  }

  void _connectBleDevice() async{
    //_otaManager.registerCallback(this);
    //_otaManager.findOmniOTADevice();

  /*  await _bleManager.connectAndListen(
      onConnected: () {
         print('连接成功');
         //_otaManager.startOTA()
      },
      onDisconnected: () {
        print('断开连接');
      },
      onDataReceived: (data) {
        print('收到数据: $data');
    }
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: AppTheme.defaultPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    if (_selectedTab == TabType.gestures) ...[
                      _buildHeader(),
                      const SizedBox(height: 32),

                      CustomizeGestureCard(
                        onSectionTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustomizeGesturePage(),
                            ),
                          );
                        },
/*                        onGestureTap: (index, gesture) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GestureDetailScreen(
                                gesture: gesture,
                                index: index,
                                onGestureUpdated: _updateGesture,
                              ),
                            ),
                          );
                        },*/
                      ),
                      const SizedBox(height: 16),
                      FindMyDeviceCard(
                        onSectionTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindMyDeviceScreen(),
                            ),
                          );
                        },
                        onPlaySound: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Playing sound on device...'),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppTheme.primaryBlue,
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),
                      DeviceSettingCard(
                        onSwitchToDeviceTab: _switchToDeviceTab, // 新增回调
                      ),

                      const SizedBox(height: 16),
                      QuickStartGuide(
                        onSectionTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuickStartGuidePage(),
                            ),
                          );
                        },
                        onPlaySound: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Playing sound on device...'),
                              duration: Duration(seconds: 1),
                              backgroundColor: AppTheme.primaryBlue,
                            ),
                          );
                        },
                      ),

                    ] else ...[
                      DeviceSettingsScreen(
                        device: _device,
                        onUpdateDevice: _updateDevice,
                        onBackToGesture: _switchToGestureTab,
                      ),
                    ],
                  ],
                ),
              ),
            ),
/*            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: BottomTabBar(
                selectedTab: _selectedTab,
                onTabChanged: (tab) {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
              ),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Text(
            'Bee Companion App',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Control your device seamlessly',
            style: TextStyle(
              fontSize: AppFont.fourthTitleSize,
              color: AppTheme.thirdTitle,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
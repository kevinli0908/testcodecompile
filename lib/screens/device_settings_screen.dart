import 'package:flutter/material.dart';
import '../models/device_model.dart';
import '../theme/app_theme.dart';
import '../services/bluetooth/ota_manager.dart';
import '../services/bluetooth/omni_ble.dart';
import '../services/storage/storage_service.dart';
import '../services/bluetooth/defines.dart';

class DeviceSettingsScreen extends StatefulWidget {
  final DeviceModel device;
  final VoidCallback onSectionTap;
  final Function(DeviceModel) onUpdateDevice;

  const DeviceSettingsScreen({
    super.key,
    required this.device,
    required this.onSectionTap,
    required this.onUpdateDevice,
  });

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen>  with AutomaticKeepAliveClientMixin
    implements OTACallback{
  final OTAManager _otaManager = OTAManager();
  final StorageService _storage = StorageService();
  final OmniBle _omniBle = OmniBle();
  late int _connectStatus;
  //bool _isConnecting = true;
  int _batteryPercentage = 0;
  String _currentVersion = "";
  String _newVersion = "";

  // ✅ 添加进度条变量
  bool _isUpgrading = false;
  double _upgradeProgress = 0.0;

  @override
  bool get wantKeepAlive => true;  // 关键：保持页面状态不被销毁

  @override
  void onDeviceNotFound() {
    debugPrint("onDeviceNotFound:");
    if (mounted) {
      setState(() {
        _connectStatus = _omniBle.getGattState();
        //_isConnected = false;
      });
    }
  }

  @override
  void onFirmwareAvailable(String rcuVer, String imgVer, bool upgrade) {
    debugPrint("onFirmwareAvailable: rcuVer=$rcuVer, imgVer=$imgVer, upgrade=$upgrade");
    if (mounted) {
      setState(() {
        //_isConnected = true;
        _connectStatus = _omniBle.getGattState();
        _currentVersion = rcuVer;
        _newVersion = imgVer;
        _batteryPercentage = _omniBle.getBatteryLevel();
        _saveDeviceStatus();
      });

    }
  }

  @override
  void onFirmwareUpToDate(String rcuVer) {
    debugPrint("onFirmwareUpToDate: rcuVer=$rcuVer");
  }

  @override
  void onFirmwareUpdateResult(String result) {
    debugPrint("onFirmwareUpdateResult: result=$result");
    // ✅ 升级完成，重置进度
    if (mounted) {
      setState(() {
        _isUpgrading = false;
        _upgradeProgress = 0.0;
      });
    }
  }

  @override
  void onFirmwareUpdating(int current, int total, int repeatCount) {
    //debugPrint("onFirmwareUpdating: current=$current, total=$total, repeatCount=$repeatCount");
    // 更新进度
    if (mounted) {
      setState(() {
        _isUpgrading = true;
        _upgradeProgress = current / total;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _connectStatus = _omniBle.getGattState();
    _loadDeviceStatus();
    _connectBleDevice();
  }

  void _loadDeviceStatus() async{
    setState(() {
      _batteryPercentage = _storage.getBatteryPercentage();
      _currentVersion = _storage.getCurrentVersion();
      _newVersion = _storage.getNewVersion();
      //_isConnected = _storage.getLastConnected();
    });
  }

  void _saveDeviceStatus() async{
    await _storage.saveBatteryPercentage(_batteryPercentage);
    await _storage.saveCurrentVersion(_currentVersion);
    await _storage.saveNewVersion(_newVersion);
    //await _storage.saveLastConnected(_isConnected);
  }

  void _connectBleDevice() async{
    _otaManager.registerCallback(this);
    _otaManager.findOmniOTADevice();

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

  // 获取显示文本
  String get _stateText {
    if (_connectStatus == Defines.STATE_GATT_CONNECTING || _connectStatus == Defines.STATE_GATT_MTU_EXCHANGE) {
      return 'Connecting...';
    } else if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return 'Connected';
    } else {
      return 'Disconnected';
    }
  }

  IconData get _batteryIcon {
    if (_connectStatus == Defines.STATE_GATT_CONNECTING || _connectStatus == Defines.STATE_GATT_MTU_EXCHANGE) {
      return Icons.battery_0_bar;
    } else if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return Icons.battery_std;
    } else {
      return Icons.battery_0_bar;
    }
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onSectionTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: AppTheme.successGreen,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Device Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 20),

          // Device Status Card
          Card(
            child: Padding(
              padding: AppTheme.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Device',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _stateText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: widget.device.isConnected
                              ? AppTheme.successGreen
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 两端对齐
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Battery: $_batteryPercentage%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        _batteryIcon,
                        color: _getBatteryColor(widget.device.batteryPercentage),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          // Firmware Version update
          Card(
            child: Padding(
              padding: AppTheme.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firmware Update',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Current version: $_currentVersion',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'New version: $_newVersion available',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),

                  // ✅ 添加进度条显示
                  if (_isUpgrading) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _upgradeProgress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(_upgradeProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // ✅ 添加全宽按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // 点击升级逻辑
                        //_startFirmwareUpdate();
                        _otaManager.startOTA();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Firmware Version Card
          Card(
            child: Padding(
              padding: AppTheme.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Firmware Version',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _currentVersion,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int percentage) {
    if (percentage >= 70) return AppTheme.successGreen;
    if (percentage >= 30) return AppTheme.warningOrange;
    return AppTheme.errorRed;
  }

}
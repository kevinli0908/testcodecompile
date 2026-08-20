import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/bluetooth/defines.dart';
import '../services/bluetooth/device_control_manager.dart';
import '../services/bluetooth/omni_gatt_manager.dart';
import '../theme/app_font.dart';
import '../theme/app_theme.dart';

class FindMyDeviceScreen extends StatefulWidget {
  const FindMyDeviceScreen({super.key});

  @override
  State<FindMyDeviceScreen> createState() => _FindMyDeviceScreenState();
}

class _FindMyDeviceScreenState extends State<FindMyDeviceScreen> implements DeviceControlCallback{
  bool _isPlayingSound = false;
  late int _connectStatus = OmniGattManager.instance.getGattState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DeviceControlManager.instance.registerCallback(this);
    _connectStatus = OmniGattManager.instance.getGattState();
    //startTimer();
  }

@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    OmniGattManager.instance.closeRing();
    //stopTimer();
  }

  @override
  void onDeviceNotFound() {
    // TODO: implement onDeviceNotFound
    if (mounted) {
      setState(() {
        _connectStatus = OmniGattManager.instance.getGattState();
      });
    }
  }

  @override
  void onGattConnectionStateChanged(int state) {
    // TODO: implement onGattConnectionStateChanged
    if (mounted) {
      setState(() {
        _connectStatus = OmniGattManager.instance.getGattState();
      });
    }
  }
  Color get _connectColor {
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return AppTheme.ble_connect;
    } else {
      return AppTheme.ble_disconnect;
    }
  }

  Color get _connectBkColor {
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return AppTheme.ble_connect_bk;
    } else {
      return AppTheme.ble_disconnect_bk;
    }
  }
  bool get _isConnected{
    if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return true;
    } else {
      return false;
    }
  }


  bool get _isCanPressUpdate{
    if(_isConnected  && !_isPlayingSound){
      return true;
    }else{
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.06),
            border: Border.all(color: Colors.white.withOpacity(0.16), width: 1),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: ImageIcon(
              AssetImage('assets/images/icon_004.png'),
              size: 20,
              color: Colors.white,
            ),
            padding: EdgeInsets.zero,
          ),
        ),

        title: const Text('Find My Device'),
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 12,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 描述文字
            Text(
              'Locate and manage your device remotely',
              style: TextStyle(
                fontSize: AppFont.fourthTitleSize,
                color: AppTheme.thirdTitle,
              ),
            ),
            const SizedBox(height: 24),

            Card(
              color: _connectBkColor,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: _connectColor,
                  width: 0.2,
                ),
              ),

              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.transparent,  // 🔑 完全透明
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: _connectColor,     // 🔑 绿色边框
                          width: 0.2,                  // 边框宽度
                        ),
                      ),
                      child: ImageIcon(
                        AssetImage('assets/images/icon_007.png'),
                        size: 20,
                        color: _connectColor,
                      ),
                    ),
                    SizedBox(width: 12),

                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _connectColor,
                        shape: BoxShape.circle,
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bluetooth connection',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _connectText,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    // 白色发光外框
                    BoxShadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 6,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  width: 155,
                  height: 155,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25),
                      width: 0.5,
                    ),
                    boxShadow: [
                      // inset 0 12px 24px rgba(255,255,255,.08)
                      BoxShadow(
                        color: Colors.white.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                        spreadRadius: -77,
                      ),
                      // inset 0 -10px 20px rgba(0,0,0,.5)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(0, -10),
                        spreadRadius: -77,
                      ),
                      // 0 22px 38px rgba(0,0,0,.36)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.36),
                        blurRadius: 38,
                        offset: const Offset(0, 22),
                      ),
                      // 0 0 30px rgba(96,165,250,.16)
                      BoxShadow(
                        color: const Color(0xFF60A5FA).withOpacity(0.16),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 18,
                        child: Container(
                          width: 5,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF60A5FA),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF60A5FA).withOpacity(0.9),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Text(
                        'OMNIDEVICES',
                        style: TextStyle(
                          color: Color(0xFFF8FAFC),
                          fontSize: 12,
                          letterSpacing: 0.09,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Align(
              alignment: Alignment.center,
              child: Text(
                'OMNIDEVICES',
                style: TextStyle(
                  fontSize: AppFont.secondTitleSize,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 2),

            Align(
              alignment: Alignment.center,
              child: Text(
                'Wireless Touch Remote',
                style: TextStyle(
                  fontSize: AppFont.thirdTitleSize,
                  color: AppTheme.secondTitle,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Play Sound 卡片
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: _playSound,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  // 内容居中
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 内容宽度自适应
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isPlayingSound
                              ? Icons.surround_sound
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Play Sound',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color:  Colors.white,
                          ),
                        ),
                        if (_isPlayingSound) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _connectText {
    if (_connectStatus == Defines.STATE_GATT_CONNECTING || _connectStatus == Defines.STATE_GATT_MTU_EXCHANGE) {
      return 'Connecting';
    } else if (_connectStatus == Defines.STATE_GATT_CONNECTED) {
      return 'Connected';
    } else {
      return 'Disconnected';
    }
  }



  Future<void> _playSound() async {
    if (!_isConnected) {
      return;
    }

    OmniGattManager.instance.openRing(0x01);

    setState(() {
      _isPlayingSound = true;
    });

    if (mounted) {
      setState(() {
        _isPlayingSound = false;
      });

      Fluttertoast.showToast(
        msg: 'Playing sound on device...',
        toastLength: Toast.LENGTH_SHORT,  // 或 Toast.LENGTH_LONG
        gravity: ToastGravity.BOTTOM,     // 位置：TOP, CENTER, BOTTOM
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );

/*      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Playing sound on device...'),
          duration: Duration(seconds: 2),
          backgroundColor: AppTheme.successGreen,
        ),
      );*/
    }
  }

  @override
  void onSetGestureStatus(bool status) {
    // TODO: implement onSetGestureStatus
  }

  @override
  void onGetGestureValue(int group, int value) {
    // TODO: implement onGetGestureValue
  }

  Timer? timer;

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      print('get ring...');
      List<int>? data = await OmniGattManager.instance.getRing();
      if (data != null && data.isNotEmpty) {
        int value = data[0]; // 直接取第一个字节
        print('get ring: $value');
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
    timer = null;
    print('cancel timer');
  }


}

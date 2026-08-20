import 'package:flutter/material.dart';
import 'package:flutter_bee_project/models/GestureMapping.dart';
import 'package:flutter_bee_project/services/bluetooth/device_control_manager.dart';

import '../services/bluetooth/omni_gatt_manager.dart';
import '../services/storage/storage_service.dart';
import '../theme/app_theme.dart';

class CustomizeGesturePage extends StatefulWidget {
  const CustomizeGesturePage({super.key});

  @override
  State<CustomizeGesturePage> createState() => _CustomizeGesturePageState();
}

class _CustomizeGesturePageState extends State<CustomizeGesturePage> implements DeviceControlCallback{
   late List<GestureItem> _gestures;
   late int _connectStatus;
   int? _expandedIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DeviceControlManager.instance.registerCallback(this);
    _connectStatus = OmniGattManager.instance.getGattState();
    _gestures = getGestures();

    // 延时500ms后加载
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
            DeviceControlManager.instance.getFirstGestureAction();
        });
      }
    });
  }

   @override
   void onDeviceNotFound() {
     // TODO: implement onDeviceNotFound

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

        title: const Text('Customize Gesture'),
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 12,
      ),

      body: Stack(
        children: [
          // 主列表
          Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: _gestures.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _gestures[index];
                final isExpanded = _expandedIndex == index;
                return _buildGestureCard(item, index, isExpanded);
              },
            ),
          ),
          // 遮罩层（点击关闭）
          if (_expandedIndex != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedIndex = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          // 弹出选项浮层
          if (_expandedIndex != null)
            _buildPopupOverlay(context, _expandedIndex!),
        ],
      ),
    );
  }

  Widget _buildGestureCard(GestureItem item, int index, bool isExpanded) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _expandedIndex = _expandedIndex == index ? null : index;
        });
      },

    child: SizedBox(
    height: 70, // 🔑 固定高度
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: isExpanded ? const Color(0xFF1A2332) : const Color(0xFF111827),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpanded
                ? Colors.blue.shade400.withOpacity(0.6)
                : Colors.white.withOpacity(0.06),
            width: isExpanded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 手势名称
            Expanded(
              flex: 4,
              child: Text(
                item.gesture,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // 操作名称
            Expanded(
              flex: 5,
              child: Text(
                item.action,
                style: TextStyle(
                  color: Colors.blue.shade400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(width: 4),

            Icon(
              Icons.keyboard_arrow_right,
              color:  Colors.grey.shade600,
              size: 22,
            ),

          ],
        ),
      ),
    ),
    );
  }

  Widget _buildPopupOverlay(BuildContext context, int index) {
    final item = _gestures[index];
    final options = GestureMapping.getActionOptions(item.gesture);

    return Positioned(
      left: 16,
      right: 16,
      top: _getCardTopPosition(index),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8), // 🔑 整个弹出框上下内边距
          decoration: BoxDecoration(
            color: const Color(0xFF1A2332),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.shade400.withOpacity(0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.blue.shade400.withOpacity(0.1),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),

                child: Row(
                  children: [
                    const SizedBox(width: 8),
                    Text(
                      'Assign action: ${item.gesture}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // 选项列表
              ...options.map((action) {
                final isSelected = action == item.action;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      final idx = _gestures.indexOf(item);
                      saveGesture(_gestures[idx].gesture, action);

                      debugPrint("getKeygroupValue: ${GestureMapping.getKeygroupValue(_gestures[idx].gesture)}");
                      debugPrint("getTargetValue: ${GestureMapping.getTargetValue(action)}");
                      DeviceControlManager.instance.setGestureAction(GestureMapping.getKeygroupValue(_gestures[idx].gesture), GestureMapping.getTargetValue(action));

                      _gestures[idx] = GestureItem(
                        gesture: item.gesture,
                        action: action,
                      );
                      _expandedIndex = null;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.shade400.withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue.shade400.withOpacity(0.5)
                            : Colors.white.withOpacity(0.06),
                        width: isSelected ? 1.5 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                        BoxShadow(
                          color: Colors.blue.shade400.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            action,
                            style: TextStyle(
                              color: isSelected ? Colors.blue.shade400 : Colors.white,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check,
                            color: Colors.blue.shade400,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  double _getCardTopPosition(int index) {
    // 计算卡片顶部位置
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final padding = 12.0;
    final cardHeight = 70.0;
    final spacing = 12.0;


    final top = appBarHeight + padding + (index * (cardHeight + spacing));


    final mediaQuery = MediaQuery.of(context);

    // 1. 屏幕总高度（包含导航键）
    double totalHeight = mediaQuery.size.height;

    // 4. 底部导航键高度
    double navigationBarHeight = mediaQuery.padding.bottom;

    double screenHeight =totalHeight - navigationBarHeight;

    final options = GestureMapping.getActionOptions(_gestures[index].gesture);
    final popupHeight = _estimatePopupHeight(options.length);

    debugPrint("_getCardTopPosition: navigationBarHeight=$navigationBarHeight");

    debugPrint("_getCardTopPosition: top=$top, screenHeight=$screenHeight, popupHeight=$popupHeight");

    if((top + popupHeight + 10) > screenHeight){
      return top - (cardHeight + spacing) - popupHeight;
    }else{
      return top;
    }

  }

  // 🔑 估算弹出框高度
  double _estimatePopupHeight(int optionCount) {
    double height = 52.0; // 标题
    height += 16.0; // 顶部 padding
    height += optionCount * 56.0; // 每个选项
    height += 16.0; // 底部 padding
    return height;
  }

  static List<GestureItem> getGestures() {
    String doubleTap = StorageService().getDoubleTap();
    debugPrint("getGestures: doubleTap=$doubleTap");
    if(doubleTap == null || doubleTap.isEmpty){
      doubleTap = 'Start/Exit Slideshow';
    }
    String tripleTap = StorageService().getTripleTap();
    debugPrint("getGestures: tripleTap=$tripleTap");
    if(tripleTap == null || tripleTap.isEmpty){
      tripleTap = 'Zoom In/Out';
    }
    String swipeUp = StorageService().getSwipeUpThreeSec();
    debugPrint("getGestures: swipeUp=$swipeUp");
    if(swipeUp == null || swipeUp.isEmpty){
      swipeUp = 'Backward 30 seconds';
    }
    String swipeDown = StorageService().getSwipeDownThreeSec();
    debugPrint("getGestures: swipeDown=$swipeDown");
    if(swipeDown == null || swipeDown.isEmpty){
      swipeDown = 'Backward 30 seconds';
    }
    String swipeLeft = StorageService().getSwipeLeftThreeSec();
    debugPrint("getGestures: swipeLeft=$swipeLeft");
    if(swipeLeft == null || swipeLeft.isEmpty){
      swipeLeft = 'Skip 30 seconds';
    }
    String swipeRight = StorageService().getSwipeRightThreeSec();
    debugPrint("getGestures: swipeRight=$swipeRight");
    if(swipeRight == null || swipeRight.isEmpty){
      swipeRight = 'Backward 30 seconds';
    }
    return [
      GestureItem(gesture: 'Double Tap', action: doubleTap),
      GestureItem(gesture: 'Triple Tap', action: tripleTap),
      GestureItem(gesture: 'Swipe Up + Hold 3s', action: swipeUp),
      GestureItem(gesture: 'Swipe Down + Hold 3s', action: swipeDown),
      GestureItem(gesture: 'Swipe Left + Hold 3s', action: swipeLeft),
      GestureItem(gesture: 'Swipe Right + Hold 3s', action: swipeRight),
    ];
  }

  static void saveGesture(String gesture, String action) {
    switch(gesture){
      case "Double Tap":{
        StorageService().saveDoubleTap(action);
      }
      case "Triple Tap":{
        StorageService().saveTripleTap(action);
      }
      case "Swipe Up + Hold 3s":{
        StorageService().saveSwipeUpThreeSec(action);
      }
      case "Swipe Down + Hold 3s":{
        StorageService().saveSwipeDownThreeSec(action);
      }
      case "Swipe Left + Hold 3s":{
        StorageService().saveSwipeLeftThreeSec(action);
      }
      case "Swipe Right + Hold 3s":{
        StorageService().saveSwipeRightThreeSec(action);
      }
    }
  }

  @override
  void onSetGestureStatus(bool status) {
    debugPrint("onGetGestureValue: status=$status");
  }

  @override
  void onGetGestureValue(int group, int value) {
      String gesture = GestureMapping.getGestureName(group);
      String action = GestureMapping.getActionName(value);
      debugPrint("onGetGestureValue: gesture=$gesture");
      debugPrint("onGetGestureValue: action=$action");
      saveGesture(gesture, action);
      _gestures = getGestures();
  }
}

@immutable
class GestureItem {
  final String gesture;
  final String action;

  const GestureItem({
    required this.gesture,
    required this.action,
  });
}
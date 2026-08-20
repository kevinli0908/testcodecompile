// lib/services/ota/image_manager.dart
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'defines.dart';

/// 图像管理器回调接口
abstract class ImageCallback {
  void onImageNotFound(int softwareID);

  /// @param imageName RCU image name
  /// @param imageID image software ID
  /// @param imageVersion imageVersion[0]:versionMinor, imageVersion[1]:versionMajor
  /// @param imageSize RCU image size
  void onImageInfo(String imageName, int imageID, Uint8List imageVersion, int imageSize);
}

/// 图像管理器 - 管理固件文件
class ImageManager {
  static const String TAG = "OMNI.BEE.ImageManager";

  ImageCallback? _callback;
  final Map<String, Uint8List> _imageMap = {};

  ImageManager() {
    _getAllImages();
  }

  void release() {
    _imageMap.clear();
  }

  void registerCallback(ImageCallback callback) {
    _callback = callback;
  }

  void unregisterCallback() {
    _callback = null;
  }

  /// 根据软件ID查找固件
  /// @param softwareID RCU software ID
  /// @param rcuVersion rcuVersion[0]:versionMinor, rcuVersion[1]:versionMajor
  void findImage(int softwareID, Uint8List rcuVersion) {
    debugPrint("$TAG findImage: softwareId=$softwareID");

    for (var entry in _imageMap.entries) {
      final imageName = entry.key;
      final imageData = entry.value;

      if (imageData.isNotEmpty && imageData.length > Defines.IMAGE_HEADER_LENGTH) {
        // 图像版本: imageData[2]:versionMinor, imageData[3]:versionMajor
        final imageVersion = Uint8List.sublistView(imageData, 2, 4);

        // 软件ID: imageData[12]:LSB, imageData[13]:MSB
        final imageID = Defines.bytesToInt(imageData, 12, 2, true);

        if (imageID == softwareID) {
          final intRcuVersion = Defines.bytesToInt(rcuVersion, 0, 2, true);
          final intImageVersion = Defines.bytesToInt(imageVersion, 0, 2, true);

          _callback?.onImageInfo(imageName, imageID, imageVersion, imageData.length);
          return;
        }
      }
    }

    _callback?.onImageNotFound(softwareID);
  }

  /// 获取图像头部信息（16字节）
  Uint8List? getImageHeader(String imageName) {
    debugPrint("$TAG getImageHeader: imageName=$imageName");

    if (imageName.isEmpty) return null;

    final imageData = _imageMap[imageName];
    if (imageData == null || imageData.length < Defines.IMAGE_HEADER_LENGTH) {
      return null;
    }

    return Uint8List.sublistView(imageData, 0, Defines.IMAGE_HEADER_LENGTH);
  }

  /// 获取指定位置的块数据
  Uint8List? getBlockData(String imageName, int position, int length) {
    if (imageName.isEmpty || position < 0 || length < 0) {
      debugPrint("$TAG getBlockData: position=$position, length=$length");
      return null;
    }

    final imageData = _imageMap[imageName];
    if (imageData == null || position >= imageData.length) return null;

    final end = (position + length) > imageData.length ? imageData.length : position + length;
    return Uint8List.sublistView(imageData, position, end);
  }

  /// 获取块数量
  int getBlockCount(String imageName, int blockSize) {
    if (imageName.isEmpty || blockSize < 0) {
      debugPrint("$TAG getBlockCount: imageName=$imageName, blockSize=$blockSize");
      return 0;
    }

    final imageData = _imageMap[imageName];
    if (imageData == null) return 0;

    final dataLength = imageData.length - Defines.IMAGE_HEADER_LENGTH;
    if (dataLength % blockSize != 0) {
      return (dataLength ~/ blockSize) + 1;
    }
    return dataLength ~/ blockSize;
  }

  /// 获取所有固件文件
  Future<void> _getAllImages() async {
    try {
      // 1. 读取 manifest.json 获取文件列表
      final manifestJson = await rootBundle.loadString('assets/firmware/firmware-index.json');
      final Map<String, dynamic> manifest = jsonDecode(manifestJson);
      final List<dynamic> files = manifest['files'];

      debugPrint("$TAG Found ${files.length} firmware files");

      // 2. 加载每个固件文件
      for (var fileName in files) {
        try {
          final path = 'assets/firmware/$fileName';
          final data = await rootBundle.load(path);
          final imageData = data.buffer.asUint8List();
          _imageMap[fileName as String] = imageData;
          debugPrint("$TAG Loaded: $fileName, size=${imageData.length} bytes");
        } catch (e) {
          debugPrint("$TAG Failed to load $fileName: $e");
        }
      }

    } catch (e) {
      debugPrint("$TAG Failed to load manifest: $e, trying fallback...");
      }
    }

  /// 手动添加固件数据（用于动态加载）
  void addImage(String imageName, Uint8List imageData) {
    _imageMap[imageName] = imageData;
    debugPrint("$TAG addImage: $imageName, size=${imageData.length}");
  }

  /// 获取所有固件名称列表
  List<String> getImageNames() {
    return _imageMap.keys.toList();
  }

  /// 检查是否有固件
  bool hasImage(String imageName) {
    return _imageMap.containsKey(imageName);
  }
}
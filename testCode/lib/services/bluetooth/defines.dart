
/// 命令和常量定义
class Defines {
  // UUID
  static const String UUID_OTA_SERV = "CBC0E185-76AF-402E-9B82-620884E57934";
  static const String UUID_OTA_COMMAND = "0F3EABD8-C687-42FC-ADCF-208BC2C126B9";
  static const String UUID_OTA_BLOCK = "83573389-10FC-416A-B451-8BE01E37442C";
  static const String UUID_CHARACTERISTIC_CONFIG = "00002902-0000-1000-8000-00805F9B34FB";
  // ==================== 电池服务 UUID ====================
  static const String UUID_BATTERY_SERV = "180F";
  static const String UUID_BATTERY_CHAR = "2A19";

  // GATT 状态
  static const int STATE_GATT_DISCONNECTED = 0;
  static const int STATE_GATT_DISCONNECTING = 1;
  static const int STATE_GATT_CONNECTING = 2;
  static const int STATE_GATT_MTU_EXCHANGE = 3;
  static const int STATE_GATT_CONNECTED = 5;

  // 命令头
  static const int CMD_HEADER = 0xA0;
  static const int CMD_RESTART_OTA = 0x15;

  // 命令 STB -> RCU (Host 发送)
  static const int CMD_HOST_GET_REMOTE_INFO = 0x01;
  static const int CMD_HOST_START_IMAGE_TRANSFER = 0x02;
  static const int CMD_HOST_RETURN_IMAGE_INFO = 0x03;
  static const int CMD_HOST_STOP_REMOTE = 0x05;
  static const int CMD_HOST_APPLY_NEW_IMAGE = 0x07;
  static const int CMD_HOST_RETURN_MAX_TRANSACTION_SIZE = 0x08;
  static const int CMD_HOST_COMMAND_RESERVED = 0x09;

  // 命令 STB <- RCU (设备返回)
  static const int CMD_RCU_RETURN_REMOTE_INFO = 0x01;
  static const int CMD_RCU_GET_IMAGE_INFO = 0x03;
  static const int CMD_RCU_RETURN_UPGRADE_RESULT = 0x04;
  static const int CMD_RCU_SET_MAX_TRANSACTION_SIZE = 0x08;
  static const int CMD_RCU_READY_FOR_RESUME = 0x0A;

  // 升级结果码
  static const int RESULT_RCU_BATTERY_LOW = 0x02;
  static const int RESULT_OTA_ONGOING = 0x04;
  static const int RESULT_INVALID_IMAGE = 0x06;
  static const int RESULT_OTA_COMPLETED_SUCCESSFULLY = 0x08;
  static const int RESULT_IMAGE_SIZE_LIMIT_EXCEEDED = 0x09;
  static const int RESULT_CRC_ERROR = 0x0A;
  static const int RESULT_RCU_ABORTED_OTA = 0x0B;
  static const int RESULT_NO_OTA_ONGOING = 0x0C;
  static const int RESULT_TIME_OUT = 0x15;

  // 默认值
  static const int DEFAULT_MAX_TRANSACTION_SIZE = 16;
  static const int MAX_RETRY_TIMES = 2;
  static const int IMAGE_HEADER_LENGTH = 16;

  /// 字节数组转整数
  static int bytesToInt(List<int> src, int position, int length, bool isLittleEndian) {
    int res = 0;
    int bit = 8;
    for (int i = 0; i < length; i++) {
      int offset = (isLittleEndian ? i : (length - i - 1)) * bit;
      res |= (src[i + position] & 0xff) << offset;
    }
    return res;
  }

  /// 获取版本字符串
  static String getVersionString(List<int> version) {
    if (version.length < 2) return "0.0";
    return "${version[1] & 0xFF}.${version[0] & 0xFF}";
  }

  /// 获取命令名称
  static String getCommandName(int cmd) {
    switch (cmd) {
      case CMD_HOST_GET_REMOTE_INFO: return "GET_REMOTE_INFO";
      case CMD_HOST_START_IMAGE_TRANSFER: return "START_IMAGE_TRANSFER";
      case CMD_HOST_RETURN_IMAGE_INFO: return "RETURN_IMAGE_INFO";
      case CMD_HOST_STOP_REMOTE: return "STOP_REMOTE";
      case CMD_HOST_APPLY_NEW_IMAGE: return "APPLY_NEW_IMAGE";
      case CMD_HOST_RETURN_MAX_TRANSACTION_SIZE: return "RETURN_MAX_TRANSACTION_SIZE";
      case CMD_RCU_RETURN_REMOTE_INFO: return "RCU_RETURN_REMOTE_INFO";
      case CMD_RCU_GET_IMAGE_INFO: return "RCU_GET_IMAGE_INFO";
      case CMD_RCU_RETURN_UPGRADE_RESULT: return "RCU_RETURN_UPGRADE_RESULT";
      case CMD_RCU_SET_MAX_TRANSACTION_SIZE: return "RCU_SET_MAX_TRANSACTION_SIZE";
      case CMD_RCU_READY_FOR_RESUME: return "RCU_READY_FOR_RESUME";
      default: return "UNKNOWN(0x${cmd.toRadixString(16).padLeft(2, '0')})";
    }
  }

  /// 获取结果名称
  static String getResultName(int result) {
    switch (result) {
      case RESULT_RCU_BATTERY_LOW: return "遥控器电量过低";
      case RESULT_OTA_ONGOING: return "OTA 进行中";
      case RESULT_INVALID_IMAGE: return "无效的固件镜像";
      case RESULT_OTA_COMPLETED_SUCCESSFULLY: return "升级成功";
      case RESULT_IMAGE_SIZE_LIMIT_EXCEEDED: return "固件大小超出限制";
      case RESULT_CRC_ERROR: return "CRC 校验错误";
      case RESULT_RCU_ABORTED_OTA: return "遥控器中止升级";
      case RESULT_NO_OTA_ONGOING: return "没有进行中的 OTA";
      case RESULT_TIME_OUT: return "操作超时";
      default: return "未知错误(0x${result.toRadixString(16).padLeft(2, '0')})";
    }
  }
}
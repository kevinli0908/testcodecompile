class GestureMapping {
  static const Map<int, String> _keygroupMap = {
    0x01: 'Double Tap',
    0x02: 'Triple Tap',
    0x03: 'Swipe Up + Hold 3s',
    0x04: 'Swipe Down + Hold 3s',
    0x05: 'Swipe Left + Hold 3s',
    0x06: 'Swipe Right + Hold 3s',
  };

  static const Map<String, int> _keygroupReverseMap = {
    'Double Tap': 0x01,
    'Triple Tap': 0x02,
    'Swipe Up + Hold 3s': 0x03,
    'Swipe Down + Hold 3s': 0x04,
    'Swipe Left + Hold 3s': 0x05,
    'Swipe Right + Hold 3s': 0x06,
  };

  static const Map<int, String> _targetMap = {
    0x01: 'Start/Exit Slideshow',
    0x02: 'Play/Pause',
    0x03: 'Like/Unlike',
    0x04: 'Zoom In/Out',
    0x05: 'Restart Stream',
    0x06: 'Open Comments',
    0x07: 'Play 2x Speed',
    0x08: 'Play 0.5x Speed',
    0x09: 'Skip 30 seconds',
    0x0A: 'Not Interested',
    0x0B: 'Backward 30 seconds',
    0x0C: 'Show More Like This',
  };

  static const Map<String, int> _targetReverseMap = {
    'Start/Exit Slideshow': 0x01,
    'Play/Pause': 0x02,
    'Like/Unlike': 0x03,
    'Zoom In/Out': 0x04,
    'Restart Stream': 0x05,
    'Open Comments': 0x06,
    'Play 2x Speed': 0x07,
    'Play 0.5x Speed': 0x08,
    'Skip 30 seconds': 0x09,
    'Not Interested': 0x0A,
    'Backward 30 seconds': 0x0B,
    'Show More Like This': 0x0C,
  };

  static String getGestureName(int keygroupValue) {
    return _keygroupMap[keygroupValue] ??
        'Unknown Gesture (0x${keygroupValue.toRadixString(16).padLeft(
            2, '0')})';
  }

  static String getActionName(int targetValue) {
    return _targetMap[targetValue] ??
        'Unknown Action (0x${targetValue.toRadixString(16).padLeft(2, '0')})';
  }

  static int getKeygroupValue(String gestureName) {
    return _keygroupReverseMap[gestureName] ?? 0x00;
  }

  static int getTargetValue(String actionName) {
    return _targetReverseMap[actionName] ?? 0x00;
  }

  static List<String> getAllGesturesValue() {
    return _keygroupMap.values.toList();
  }

  static List<int> getAllGesturesKey() {
    return _keygroupMap.keys.toList();
  }

  static List<String> getAllActionsValue() {
    return _targetMap.values.toList();
  }

  static List<int> getAllActionsKey() {
    return _targetMap.keys.toList();
  }

  static List<String> getActionOptions(String gesture) {
    switch (gesture) {
      case 'Double Tap':
        return ['Start/Exit Slideshow', 'Play/Pause', 'Like/Unlike'];
      case 'Triple Tap':
        return ['Zoom In/Out', 'Restart Stream', 'Open Comments'];
      case 'Swipe Up + Hold 3s':
        return [
          'Play 2x Speed',
          'Play 0.5x Speed',
          'Skip 30 seconds',
          'Backward 30 seconds',
          'Not Interested',
          'Show More Like This'
        ];
      case 'Swipe Down + Hold 3s':
        return [
          'Play 0.5x Speed',
          'Play 2x Speed',
          'Skip 30 seconds',
          'Backward 30 seconds',
          'Not Interested',
          'Show More Like This'
        ];
      case 'Swipe Left + Hold 3s':
        return [
          'Skip 30 seconds',
          'Backward 30 seconds',
          'Play 2x Speed',
          'Play 0.5x Speed'
        ];
      case 'Swipe Right + Hold 3s':
        return [
          'Play 0.5x Speed',
          'Play 2x Speed',
          'Skip 30 seconds',
          'Backward 30 seconds',
          'Not Interested',
          'Show More Like This'
        ];
      default:
        return ['Start/Exit Slideshow', 'Play/Pause'];
    }
  }
}

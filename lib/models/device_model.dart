class DeviceModel {
  final String name;
  final bool isConnected;
  final int batteryPercentage;
  final String currentFirmwareVersion;
  final String? availableFirmwareVersion;

  const DeviceModel({
    required this.name,
    required this.isConnected,
    required this.batteryPercentage,
    required this.currentFirmwareVersion,
    this.availableFirmwareVersion,
  });

  factory DeviceModel.defaultDevice() {
    return const DeviceModel(
      name: 'My Device',
      isConnected: true,
      batteryPercentage: 78,
      currentFirmwareVersion: '1.2.8',
      availableFirmwareVersion: '1.3.0',
    );
  }

  bool get hasUpdateAvailable => availableFirmwareVersion != null;

  DeviceModel copyWith({
    String? name,
    bool? isConnected,
    int? batteryPercentage,
    String? currentFirmwareVersion,
    String? availableFirmwareVersion,
  }) {
    return DeviceModel(
      name: name ?? this.name,
      isConnected: isConnected ?? this.isConnected,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      currentFirmwareVersion: currentFirmwareVersion ?? this.currentFirmwareVersion,
      availableFirmwareVersion: availableFirmwareVersion ?? this.availableFirmwareVersion,
    );
  }
}
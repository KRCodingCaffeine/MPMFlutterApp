import 'package:mpm/model/DeviceMapping/DeviceMappingData.dart';
import 'package:mpm/repository/device_mapping_repository/device_mapping_repo.dart';
import 'package:mpm/utils/device_utils.dart';

class DeviceMappingController {
  final _repo = DeviceMappingRepository();

  /// Registers or updates device mapping for a member
  Future<void> registerDeviceMapping(String memberId) async {
    try {
      final deviceInfo = await DeviceUtils.getDeviceInfo();

      final dataModel = DeviceMappingData(
        memberId: memberId,
        deviceId: deviceInfo['device_id'],
        deviceModel: deviceInfo['device_model'],
        deviceBrand: deviceInfo['device_brand'],
        osName: deviceInfo['os_name'],
        osVersion: deviceInfo['os_version'],
      );

      print("📲 Sending device mapping for member: $memberId");
      print("📦 Device Info: $deviceInfo");

      final response = await _repo.createDeviceMapping(dataModel);

      if (response.status == true) {
        print("✅ Device mapping successful → ${response.message}");
      } else {
        print("⚠️ Device mapping failed → ${response.message}");
      }
    } catch (e) {
      print("❌ Exception during device mapping: $e");
    }
  }
}

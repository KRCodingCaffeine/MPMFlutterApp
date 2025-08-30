import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<Map<String, String>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    String deviceId = '';
    String deviceModel = '';
    String deviceBrand = '';
    String osName = '';
    String osVersion = '';

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id ?? '';
      deviceModel = androidInfo.model ?? '';
      deviceBrand = androidInfo.brand ?? '';
      osName = 'android';
      osVersion = androidInfo.version.release ?? '';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor ?? '';
      deviceModel = iosInfo.utsname.machine ?? '';
      deviceBrand = 'Apple';
      osName = 'ios';
      osVersion = iosInfo.systemVersion ?? '';
    }

    return {
      "device_id": deviceId,
      "device_model": deviceModel,
      "device_brand": deviceBrand,
      "os_name": osName,
      "os_version": osVersion,
    };
  }
}

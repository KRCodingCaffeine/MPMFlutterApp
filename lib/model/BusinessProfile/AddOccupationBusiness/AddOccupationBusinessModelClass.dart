import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';

class AddOccupationBusinessModelClass {
  bool? status;
  int? code;
  String? message;
  BusinessData? data;

  AddOccupationBusinessModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddOccupationBusinessModelClass.fromJson(Map<String, dynamic> json) {
    return AddOccupationBusinessModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? BusinessData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['code'] = code;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class BusinessData {
  BusinessOccupationProfileData? profile;
  BusinessAddressData? address;

  BusinessData({
    this.profile,
    this.address,
  });

  factory BusinessData.fromJson(Map<String, dynamic> json) {
    return BusinessData(
      profile: json['profile'] != null ? BusinessOccupationProfileData.fromJson(json['profile']) : null,
      address: json['address'] != null ? BusinessAddressData.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (profile != null) {
      data['profile'] = profile!.toJson();
    }
    if (address != null) {
      data['address'] = address!.toJson();
    }
    return data;
  }
}
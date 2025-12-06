import 'package:mpm/model/BusinessProfile/BusinessAddress/BusinessAddressData.dart';
import 'package:mpm/model/BusinessProfile/BusinessOccupationProfile/BusinessOccupationProfileData.dart';
import 'package:mpm/model/BusinessProfile/UpdateOccupationBusiness/UpdateOccupationBusinessData.dart';


class UpdateOccupationBusinessModelClass {
  bool? status;
  int? code;
  String? message;
  UpdateBusinessData? data;

  UpdateOccupationBusinessModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory UpdateOccupationBusinessModelClass.fromJson(
      Map<String, dynamic> json) {
    return UpdateOccupationBusinessModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null
          ? UpdateBusinessData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['code'] = code;
    map['message'] = message;
    if (data != null) {
      map['data'] = data!.toJson();
    }
    return map;
  }
}

class UpdateBusinessData {
  BusinessOccupationProfileData? profile;
  BusinessAddressData? address;

  UpdateBusinessData({
    this.profile,
    this.address,
  });

  factory UpdateBusinessData.fromJson(Map<String, dynamic> json) {
    return UpdateBusinessData(
      profile: json['profile'] != null ? BusinessOccupationProfileData.fromJson(json['profile']) : null,
      address: json['address'] != null ? BusinessAddressData.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profile': profile?.toJson(),
      'address': address?.toJson(),
    };
  }
}

class DeviceMappingData {
  String? memberId;
  String? deviceId;
  String? deviceModel;
  String? deviceBrand;
  String? osName;
  String? osVersion;
  String? updatedBy;
  String? updatedAt;
  String? createdBy;
  String? createdAt;
  String? memberDeviceMappingId;

  DeviceMappingData({
    this.memberId,
    this.deviceId,
    this.deviceModel,
    this.deviceBrand,
    this.osName,
    this.osVersion,
    this.updatedBy,
    this.updatedAt,
    this.createdBy,
    this.createdAt,
    this.memberDeviceMappingId,
  });

  factory DeviceMappingData.fromJson(Map<String, dynamic> json) {
    return DeviceMappingData(
      memberId: json['member_id']?.toString(),
      deviceId: json['device_id']?.toString(),
      deviceModel: json['device_model']?.toString(),
      deviceBrand: json['device_brand']?.toString(),
      osName: json['os_name']?.toString(),
      osVersion: json['os_version']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      memberDeviceMappingId: json['member_device_mapping_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['member_id'] = memberId;
    dataMap['device_id'] = deviceId;
    dataMap['device_model'] = deviceModel;
    dataMap['device_brand'] = deviceBrand;
    dataMap['os_name'] = osName;
    dataMap['os_version'] = osVersion;
    dataMap['updated_by'] = updatedBy;
    dataMap['updated_at'] = updatedAt;
    dataMap['created_by'] = createdBy;
    dataMap['created_at'] = createdAt;
    dataMap['member_device_mapping_id'] = memberDeviceMappingId;
    return dataMap;
  }
}

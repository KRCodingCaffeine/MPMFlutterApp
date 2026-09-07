class SamitiTypeData {
  String? samitiSubCategoryId;
  String? samitiId;
  String? samitiSubCategoryName;
  String? zoneId;
  String? status;
  String? dateAdded;

  SamitiTypeData({
    this.samitiSubCategoryId,
    this.samitiId,
    this.samitiSubCategoryName,
    this.zoneId,
    this.status,
    this.dateAdded,
  });

  factory SamitiTypeData.fromJson(Map<String, dynamic> json) {
    return SamitiTypeData(
      samitiSubCategoryId:
      json['samiti_sub_category_id']?.toString(),

      samitiId:
      json['samiti_id']?.toString(),

      samitiSubCategoryName:
      json['samiti_sub_category_name']?.toString(),

      zoneId:
      json['zone_id']?.toString(),

      status:
      json['status']?.toString(),

      dateAdded:
      json['date_added']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_id': samitiId,
      'samiti_sub_category_name': samitiSubCategoryName,
      'zone_id': zoneId,
      'status': status,
      'date_added': dateAdded,
    };
  }
}
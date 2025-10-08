class SamitiOrganiser {
  String? samitiId;
  String? samitiName;
  SamitiSubCategory? subCategory;

  SamitiOrganiser({
    this.samitiId,
    this.samitiName,
    this.subCategory,
  });

  factory SamitiOrganiser.fromJson(Map<String, dynamic> json) {
    return SamitiOrganiser(
      samitiId: json['samiti_id']?.toString(),
      samitiName: json['samiti_name'],
      subCategory: json['sub_category'] != null
          ? SamitiSubCategory.fromJson(json['sub_category'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'samiti_id': samitiId,
      'samiti_name': samitiName,
      'sub_category': subCategory?.toJson(),
    };
  }
}

class SamitiSubCategory {
  String? samitiSubCategoryId;
  String? samitiId;
  String? samitiSubCategoryName;
  String? zoneId;
  String? status;
  String? dateAdded;

  SamitiSubCategory({
    this.samitiSubCategoryId,
    this.samitiId,
    this.samitiSubCategoryName,
    this.zoneId,
    this.status,
    this.dateAdded,
  });

  factory SamitiSubCategory.fromJson(Map<String, dynamic> json) {
    return SamitiSubCategory(
      samitiSubCategoryId: json['samiti_sub_category_id']?.toString(),
      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryName: json['samiti_sub_category_name'],
      zoneId: json['zone_id']?.toString(),
      status: json['status']?.toString(),
      dateAdded: json['date_added'],
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

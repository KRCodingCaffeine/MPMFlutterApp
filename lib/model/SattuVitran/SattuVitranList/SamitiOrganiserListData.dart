
class SamitiOrganiserListData {
  String? vitranSamitiOrganiserDataId;
  String? vitranId;
  String? samitiId;
  String? samitiSubCategoryId;
  String? addedBy;
  String? dateAdded;
  String? samitiName;
  String? samitiSubCategoryName;

  SamitiOrganiserListData({
    this.vitranSamitiOrganiserDataId,
    this.vitranId,
    this.samitiId,
    this.samitiSubCategoryId,
    this.addedBy,
    this.dateAdded,
    this.samitiName,
    this.samitiSubCategoryName,
  });

  factory SamitiOrganiserListData.fromJson(Map<String, dynamic> json) {
    return SamitiOrganiserListData(
      vitranSamitiOrganiserDataId: json['vitran_samiti_organiser_data_id']?.toString(),
      vitranId: json['vitran_id']?.toString(),
      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryId: json['samiti_sub_category_id']?.toString(),
      addedBy: json['added_by']?.toString(),
      dateAdded: json['date_added'],
      samitiName: json['samiti_name'],
      samitiSubCategoryName: json['samiti_sub_category_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitran_samiti_organiser_data_id': vitranSamitiOrganiserDataId,
      'vitran_id': vitranId,
      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'added_by': addedBy,
      'date_added': dateAdded,
      'samiti_name': samitiName,
      'samiti_sub_category_name': samitiSubCategoryName,
    };
  }
}
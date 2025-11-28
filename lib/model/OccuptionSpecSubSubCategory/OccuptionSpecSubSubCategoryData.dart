class OccuptionSpecSubSubCategoryData {
  String? subSubCategoryId;
  String? subCategoryId;
  String? subSubCategoryName;
  String? status;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  OccuptionSpecSubSubCategoryData({
    this.subSubCategoryId,
    this.subCategoryId,
    this.subSubCategoryName,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  OccuptionSpecSubSubCategoryData.fromJson(Map<String, dynamic> json) {
    subSubCategoryId = json['occupation_specialization_sub_sub_category_id'];
    subCategoryId = json['occupation_specialization_sub_category_id'];
    subSubCategoryName = json['sub_category_name'];
    status = json['status'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['occupation_specialization_sub_sub_category_id'] = subSubCategoryId;
    data['occupation_specialization_sub_category_id'] = subCategoryId;
    data['sub_category_name'] = subSubCategoryName;
    data['status'] = status;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    data['updated_by'] = updatedBy;
    data['updated_at'] = updatedAt;
    return data;
  }
}

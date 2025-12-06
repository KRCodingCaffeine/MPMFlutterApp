class OccuptionSpecSubCategoryData {
  String? specializationSubCategoryId;
  String? specializationId;
  String? specializationSubCategoryName;
  String? status;
  String? createdAt;
  String? updatedAt;

  OccuptionSpecSubCategoryData({
    this.specializationSubCategoryId,
    this.specializationId,
    this.specializationSubCategoryName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  OccuptionSpecSubCategoryData.fromJson(Map<String, dynamic> json) {
    specializationSubCategoryId = json['occupation_specialization_sub_category_id'];
    specializationId = json['occupation_specialization_id'];
    specializationSubCategoryName = json['specialization_sub_category_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['occupation_specialization_sub_category_id'] = specializationSubCategoryId;
    data['occupation_specialization_id'] = specializationId;
    data['specialization_sub_category_name'] = specializationSubCategoryName;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class OccuptionSpecSubCategoryData {
  String? id;
  String? specializationId;
  String? specializationSubCategoryName;
  String? status;
  String? createdAt;
  String? updatedAt;

  OccuptionSpecSubCategoryData({
    this.id,
    this.specializationId,
    this.specializationSubCategoryName,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  OccuptionSpecSubCategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    specializationId = json['occupation_specialization_id'];
    specializationSubCategoryName = json['specialization_sub_category_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['occupation_specialization_id'] = specializationId;
    data['specialization_sub_category_name'] = specializationSubCategoryName;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

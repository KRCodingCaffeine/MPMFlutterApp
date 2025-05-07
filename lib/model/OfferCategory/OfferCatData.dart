class OrganisationCategoryData {
  String? organisationCategoryId;
  String? organisationCategoryName;
  String? status;
  String? dateAdded;

  OrganisationCategoryData({
    this.organisationCategoryId,
    this.organisationCategoryName,
    this.status,
    this.dateAdded,
  });

  factory OrganisationCategoryData.fromJson(Map<String, dynamic> json) {
    return OrganisationCategoryData(
      organisationCategoryId: json['organisation_category_id']?.toString(),
      organisationCategoryName: json['organisation_category_name'],
      status: json['status']?.toString(),
      dateAdded: json['date_added'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['organisation_category_id'] = organisationCategoryId;
    data['organisation_category_name'] = organisationCategoryName;
    data['status'] = status;
    data['date_added'] = dateAdded;
    return data;
  }
}

class OrganisationCategoryModel {
  bool? status;
  String? message;
  List<OrganisationCategoryData>? data;

  OrganisationCategoryModel({this.status, this.message, this.data});

  factory OrganisationCategoryModel.fromJson(Map<String, dynamic> json) {
    return OrganisationCategoryModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => OrganisationCategoryData.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['message'] = message;
    data['data'] = this.data?.map((v) => v.toJson()).toList();
    return data;
  }
}
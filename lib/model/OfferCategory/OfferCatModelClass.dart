class OrganisationCategory {
  String? organisationCategoryId;
  String? organisationCategoryName;
  String? status;
  String? dateAdded;

  OrganisationCategory({
    this.organisationCategoryId,
    this.organisationCategoryName,
    this.status,
    this.dateAdded,
  });

  factory OrganisationCategory.fromJson(Map<String, dynamic> json) {
    return OrganisationCategory(
      organisationCategoryId: json['organisation_category_id']?.toString(),
      organisationCategoryName: json['organisation_category_name'],
      status: json['status']?.toString(),
      dateAdded: json['date_added'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organisation_category_id': organisationCategoryId,
      'organisation_category_name': organisationCategoryName,
      'status': status,
      'date_added': dateAdded,
    };
  }
}

class OrganisationCategoryModel {
  bool? status;
  String? message;
  List<OrganisationCategory>? data;

  OrganisationCategoryModel({this.status, this.message, this.data});

  factory OrganisationCategoryModel.fromJson(Map<String, dynamic> json) {
    return OrganisationCategoryModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List).map((v) => OrganisationCategory.fromJson(v)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}
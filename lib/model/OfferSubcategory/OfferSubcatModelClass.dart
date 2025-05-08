class OrganisationSubcategory {
  String? organisationSubcategoryId;
  String? organisationSubcategoryName;
  String? organisationCategoryId;
  String? status;
  String? dateAdded;

  OrganisationSubcategory({
    this.organisationSubcategoryId,
    this.organisationSubcategoryName,
    this.organisationCategoryId,
    this.status,
    this.dateAdded,
  });

  factory OrganisationSubcategory.fromJson(Map<String, dynamic> json) {
    return OrganisationSubcategory(
      organisationSubcategoryId: json['organisation_subcategory_id']?.toString(),
      organisationSubcategoryName: json['organisation_subcategory_name'],
      organisationCategoryId: json['organisation_category_id']?.toString(),
      status: json['status']?.toString(),
      dateAdded: json['date_added'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'organisation_subcategory_id': organisationSubcategoryId,
      'organisation_subcategory_name': organisationSubcategoryName,
      'organisation_category_id': organisationCategoryId,
      'status': status,
      'date_added': dateAdded,
    };
  }
}

class OrganisationSubcategoryModel {
  bool? status;
  String? message;
  List<OrganisationSubcategory>? data;

  OrganisationSubcategoryModel({this.status, this.message, this.data});

  factory OrganisationSubcategoryModel.fromJson(Map<String, dynamic> json) {
    return OrganisationSubcategoryModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? (json['data'] as List)
          .map((v) => OrganisationSubcategory.fromJson(v))
          .toList()
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
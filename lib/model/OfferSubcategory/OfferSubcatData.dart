import 'package:mpm/model/OfferSubcategory/OfferSubcatModelClass.dart';

class OrganisationSubcategoryData {
  final String? organisationSubcategoryId;
  final String? organisationSubcategoryName;
  final String? organisationCategoryId;
  final String? status;
  final String? dateAdded;

  OrganisationSubcategoryData({
    this.organisationSubcategoryId,
    this.organisationSubcategoryName,
    this.organisationCategoryId,
    this.status,
    this.dateAdded,
  });

  // Factory constructor for JSON parsing
  factory OrganisationSubcategoryData.fromJson(Map<String, dynamic> json) {
    return OrganisationSubcategoryData(
      organisationSubcategoryId: json['organisation_subcategory_id']?.toString(),
      organisationSubcategoryName: json['organisation_subcategory_name']?.toString(),
      organisationCategoryId: json['organisation_category_id']?.toString(),
      status: json['status']?.toString(),
      dateAdded: json['date_added']?.toString(),
    );
  }

  // Convert from OrganisationSubcategory model
  factory OrganisationSubcategoryData.fromModel(OrganisationSubcategory model) {
    return OrganisationSubcategoryData(
      organisationSubcategoryId: model.organisationSubcategoryId,
      organisationSubcategoryName: model.organisationSubcategoryName,
      organisationCategoryId: model.organisationCategoryId,
      status: model.status,
      dateAdded: model.dateAdded,
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

  // Helper to parse a list of subcategories from JSON
  static List<OrganisationSubcategoryData> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => OrganisationSubcategoryData.fromJson(json as Map<String, dynamic>)).toList();
  }

  // Helper to convert from model list
  static List<OrganisationSubcategoryData> fromModelList(List<OrganisationSubcategory> modelList) {
    return modelList.map((model) => OrganisationSubcategoryData.fromModel(model)).toList();
  }

  @override
  String toString() {
    return 'Subcategory(id: $organisationSubcategoryId, name: $organisationSubcategoryName)';
  }
}

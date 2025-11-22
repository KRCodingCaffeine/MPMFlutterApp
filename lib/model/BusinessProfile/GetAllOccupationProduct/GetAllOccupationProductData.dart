class GetAllOccupationProductData {
  String? productServiceId;
  String? memberBusinessOccupationProfileId;
  String? categoryId;
  String? subCategoryId;
  String? type;
  String? productName;
  String? description;
  String? productImage;
  String? keywords;
  String? price;
  String? currency;
  String? unit;
  String? status;
  String? isFeatured;
  String? displayOrder;
  String? createdBy;
  String? createdAt;

  GetAllOccupationProductData.fromJson(Map<String, dynamic> json) {
    productServiceId = json['product_service_id'];
    memberBusinessOccupationProfileId = json['member_business_occupation_profile_id'];
    categoryId = json['category_id'];
    subCategoryId = json['subcategory_id'];
    type = json['type'];
    productName = json['product_name'];
    description = json['description'];
    productImage = json['product_image'];
    keywords = json['keywords'];
    price = json['price'];
    currency = json['currency'];
    unit = json['unit'];
    status = json['status'];
    isFeatured = json['is_featured'];
    displayOrder = json['display_order'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
  }
}

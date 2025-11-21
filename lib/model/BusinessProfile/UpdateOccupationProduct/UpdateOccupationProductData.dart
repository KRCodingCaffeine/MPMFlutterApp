class UpdateOccupationProductData {
  String? productServiceId;
  String? memberBusinessOccupationProfileId;
  String? categoryId;
  String? subcategoryId;
  String? type;
  String? productName;
  String? description;
  String? keywords;
  String? price;
  String? currency;
  String? unit;
  String? status;
  String? isFeatured;
  String? displayOrder;
  String? updatedBy;
  String? updatedAt;

  UpdateOccupationProductData({
    this.productServiceId,
    this.memberBusinessOccupationProfileId,
    this.categoryId,
    this.subcategoryId,
    this.type,
    this.productName,
    this.description,
    this.keywords,
    this.price,
    this.currency,
    this.unit,
    this.status,
    this.isFeatured,
    this.displayOrder,
    this.updatedBy,
    this.updatedAt,
  });

  UpdateOccupationProductData.fromJson(Map<String, dynamic> json) {
    productServiceId = json['product_service_id']?.toString();
    memberBusinessOccupationProfileId =
        json['member_business_occupation_profile_id']?.toString();
    categoryId = json['category_id']?.toString();
    subcategoryId = json['subcategory_id']?.toString();
    type = json['type'];
    productName = json['product_name'];
    description = json['description'];
    keywords = json['keywords'];
    price = json['price']?.toString();
    currency = json['currency'];
    unit = json['unit'];
    status = json['status']?.toString();
    isFeatured = json['is_featured']?.toString();
    displayOrder = json['display_order']?.toString();
    updatedBy = json['updated_by']?.toString();
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['product_service_id'] = productServiceId;
    data['member_business_occupation_profile_id'] =
        memberBusinessOccupationProfileId;
    data['category_id'] = categoryId;
    data['subcategory_id'] = subcategoryId;
    data['type'] = type;
    data['product_name'] = productName;
    data['description'] = description;
    data['keywords'] = keywords;
    data['price'] = price;
    data['currency'] = currency;
    data['unit'] = unit;
    data['status'] = status;
    data['is_featured'] = isFeatured;
    data['display_order'] = displayOrder;
    data['updated_by'] = updatedBy;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ProductSubcategoryData {
  String? subcategoryId;
  String? categoryId;
  String? name;
  String? description;
  String? icon;
  String? status;
  String? displayOrder;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? categoryName;

  ProductSubcategoryData({
    this.subcategoryId,
    this.categoryId,
    this.name,
    this.description,
    this.icon,
    this.status,
    this.displayOrder,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.categoryName,
  });

  ProductSubcategoryData.fromJson(Map<String, dynamic> json) {
    subcategoryId = json['subcategory_id'];
    categoryId = json['category_id'];
    name = json['name'];
    description = json['description'];
    icon = json['subcategory_icon'];
    status = json['status'];
    displayOrder = json['display_order'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    categoryName = json['category_name'];
  }
}

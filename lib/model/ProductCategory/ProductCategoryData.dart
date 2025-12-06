class ProductCategoryData {
  String? categoryId;
  String? name;
  String? description;
  String? icon;
  String? type;
  String? status;
  String? displayOrder;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  ProductCategoryData({
    this.categoryId,
    this.name,
    this.description,
    this.icon,
    this.type,
    this.status,
    this.displayOrder,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  ProductCategoryData.fromJson(Map<String, dynamic> json) {
    categoryId = json['category_id'];
    name = json['name'];
    description = json['description'];
    icon = json['icon'];
    type = json['type'];
    status = json['status'];
    displayOrder = json['display_order'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }
}

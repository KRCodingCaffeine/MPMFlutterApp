class MemberShipData {
  String? id;
  String? membershipName;
  String? price;
  String? status;
  Null? createdAt;
  Null? updatedAt;

  MemberShipData(
      {this.id,
        this.membershipName,
        this.price,
        this.status,
        this.createdAt,
        this.updatedAt});

  MemberShipData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    membershipName = json['membership_name'];
    price = json['price'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['membership_name'] = this.membershipName;
    data['price'] = this.price;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
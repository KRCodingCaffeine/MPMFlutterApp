class Building {
  String? id;
  var userId;
  var pincodeId;
 var buildingName;
 var status;
  var createdAt;
  var updatedAt;

  Building(
      {this.id,
        this.userId,
        this.pincodeId,
        this.buildingName,
        this.status,
        this.createdAt,
        this.updatedAt});

  Building.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    pincodeId = json['pincode_id'];
    buildingName = json['building_name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['pincode_id'] = this.pincodeId;
    data['building_name'] = this.buildingName;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

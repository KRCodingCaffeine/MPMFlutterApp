class UpdateFamilyData{
  String? relationshipTypeId;

  UpdateFamilyData({this.relationshipTypeId});

  UpdateFamilyData.fromJson(Map<String, dynamic> json) {
    relationshipTypeId = json['relationship_type_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['relationship_type_id'] = this.relationshipTypeId;
    return data;
  }
}
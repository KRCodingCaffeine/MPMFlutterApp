class MemberSurnameData {
  String? id;
  String? surnameName;
  String? surnameKey;
  String? status;
  String? createdAt;
  String? createdBy;

  MemberSurnameData({
    this.id,
    this.surnameName,
    this.surnameKey,
    this.status,
    this.createdAt,
    this.createdBy,
  });

  MemberSurnameData.fromJson(Map<String, dynamic> json) {
    id = json['member_surname_id']?.toString();
    surnameName = json['surname_name'];
    surnameKey = json['surname_key'];
    status = json['status']?.toString();
    createdAt = json['created_at'];
    createdBy = json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_surname_id'] = id;
    data['surname_name'] = surnameName;
    data['surname_key'] = surnameKey;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['created_by'] = createdBy;
    return data;
  }
}

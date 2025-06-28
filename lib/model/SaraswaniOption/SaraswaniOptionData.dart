class SaraswaniOptionData {
  String? id;
  String? saraswaniOption;
  String? status;
  String? createdAt;
  String? updatedAt;

  SaraswaniOptionData({
    this.id,
    this.saraswaniOption,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  SaraswaniOptionData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    saraswaniOption = json['saraswani_option'];
    status = json['status'].toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['saraswani_option'] = saraswaniOption;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

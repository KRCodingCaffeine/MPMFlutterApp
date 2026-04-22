class GetOccupationByMemberIdData {
  String? id;
  String? memberId;
  String? occupation;
  String? companyName;
  String? experience;
  String? createdAt;

  GetOccupationByMemberIdData({
    this.id,
    this.memberId,
    this.occupation,
    this.companyName,
    this.experience,
    this.createdAt,
  });

  GetOccupationByMemberIdData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    memberId = json['member_id']?.toString();
    occupation = json['occupation'];
    companyName = json['company_name'];
    experience = json['experience'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['member_id'] = memberId;
    data['occupation'] = occupation;
    data['company_name'] = companyName;
    data['experience'] = experience;
    data['created_at'] = createdAt;
    return data;
  }
}
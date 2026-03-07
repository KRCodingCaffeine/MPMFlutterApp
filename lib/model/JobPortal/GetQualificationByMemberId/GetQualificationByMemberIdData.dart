class GetQualificationByMemberIdData {

  String? id;
  String? memberId;
  String? qualification;
  String? instituteName;
  String? yearOfPassing;
  String? createdAt;

  GetQualificationByMemberIdData({
    this.id,
    this.memberId,
    this.qualification,
    this.instituteName,
    this.yearOfPassing,
    this.createdAt,
  });

  GetQualificationByMemberIdData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    memberId = json['member_id']?.toString();
    qualification = json['qualification'];
    instituteName = json['institute_name'];
    yearOfPassing = json['year_of_passing'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {

    final Map<String, dynamic> data = {};

    data['id'] = id;
    data['member_id'] = memberId;
    data['qualification'] = qualification;
    data['institute_name'] = instituteName;
    data['year_of_passing'] = yearOfPassing;
    data['created_at'] = createdAt;

    return data;
  }
}
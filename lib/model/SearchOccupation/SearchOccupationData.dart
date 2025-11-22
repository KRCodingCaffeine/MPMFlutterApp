class SearchOccupationData {
  String? memberId;
  String? memberCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? fullName;
  String? mobile;
  String? email;
  String? profileImage;
  OccupationInfo? occupation;

  SearchOccupationData({
    this.memberId,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.mobile,
    this.email,
    this.profileImage,
    this.occupation,
  });

  SearchOccupationData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    memberCode = json['member_code'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    fullName = json['full_name'];
    mobile = json['mobile'];
    email = json['email'];
    profileImage = json['profile_image'];

    occupation = json['occupation'] != null
        ? OccupationInfo.fromJson(json['occupation'])
        : null;
  }
}

class OccupationInfo {
  String? occupationId;
  String? occupationName;
  String? professionId;
  String? professionName;
  String? specializationId;
  String? specializationName;

  OccupationInfo({
    this.occupationId,
    this.occupationName,
    this.professionId,
    this.professionName,
    this.specializationId,
    this.specializationName,
  });

  OccupationInfo.fromJson(Map<String, dynamic> json) {
    occupationId = json['occupation_id'];
    occupationName = json['occupation_name'];
    professionId = json['profession_id'];
    professionName = json['profession_name'];
    specializationId = json['specialization_id'];
    specializationName = json['specialization_name'];
  }
}

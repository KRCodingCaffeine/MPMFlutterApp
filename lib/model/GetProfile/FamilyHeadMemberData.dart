class FamilyHeadMemberData {
  var memberId;
  var memberCode;
  var firstName;
  var lastName;
  var middleName;
  var profileImage;
  var pincode;

  FamilyHeadMemberData(
      {this.memberId,
        this.memberCode,
        this.firstName,
        this.lastName,
        this.middleName,
        this.profileImage,
      this.pincode});

  FamilyHeadMemberData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    memberCode = json['member_code'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    middleName = json['middle_name'];
    profileImage = json['profile_image'];
    pincode = json['pincode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_id'] = this.memberId;
    data['member_code'] = this.memberCode;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['middle_name'] = this.middleName;
    data['profile_image'] = this.profileImage;
    data['pincode'] = this.pincode;
    return data;
  }
}

class SeekerMemberData {
  String? memberId;
  String? memberCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? whatsappNumber;
  String? email;
  String? profileImage;

  SeekerMemberData({
    this.memberId,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.profileImage,
  });

  SeekerMemberData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    memberCode = json['member_code']?.toString();
    firstName = json['first_name']?.toString();
    middleName = json['middle_name']?.toString();
    lastName = json['last_name']?.toString();
    mobile = json['mobile']?.toString();
    whatsappNumber = json['whatsapp_number']?.toString();
    email = json['email']?.toString();
    profileImage = json['profile_image']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_code': memberCode,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'profile_image': profileImage,
    };
  }
}

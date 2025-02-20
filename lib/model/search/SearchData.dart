class SearchData{
  String? memberId;
  String? profileImage;
  String? memberCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;

  SearchData(
      {this.memberId,
        this.profileImage,
        this.memberCode,
        this.firstName,
        this.middleName,
        this.lastName,
        this.mobile});

  SearchData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    profileImage = json['profile_image'];
    memberCode = json['member_code'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_id'] = this.memberId;
    data['profile_image'] = this.profileImage;
    data['member_code'] = this.memberCode;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['mobile'] = this.mobile;
    return data;
  }
}



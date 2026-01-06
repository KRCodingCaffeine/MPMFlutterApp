class ConnectedMemberData {
  String? requestId;

  // Requested TO member details
  String? memberId;
  String? memberCode;

  String? firstName;
  String? middleName;
  String? lastName;
  String? fullName;

  String? mobile;
  String? profileImage;

  String? occupationName;
  String? professionName;
  String? specializationName;

  String? status;
  String? requestedAt;

  ConnectedMemberData({
    this.requestId,
    this.memberId,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.fullName,
    this.mobile,
    this.profileImage,
    this.occupationName,
    this.professionName,
    this.specializationName,
    this.status,
    this.requestedAt,
  });

  ConnectedMemberData.fromJson(Map<String, dynamic> json) {
    requestId = json['member_business_connect_request_id']?.toString();

    memberId = json['requested_to_member_id']?.toString();
    memberCode = json['requested_to_member_code'];

    firstName = json['requested_to_first_name'];
    middleName = json['requested_to_middle_name'];
    lastName = json['requested_to_last_name'];

    fullName = json['requested_to_full_name'];
    mobile = json['requested_to_mobile'];
    profileImage = json['requested_to_profile_image'];

    occupationName = json['occupation_name'];
    professionName = json['occupation_profession_name'];
    specializationName = json['occupation_specialization_name'];
    status = json['business_connect_requested_status'];
    requestedAt = json['created_at'];
  }

  /// ✅ Safe full name builder
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }

    return [
      firstName,
      middleName,
      lastName,
    ].where((e) => e != null && e!.isNotEmpty).join(" ");
  }

  String get professionDisplay {
    if ((professionName ?? "").isNotEmpty &&
        (specializationName ?? "").isNotEmpty) {
      return "$professionName - $specializationName";
    }

    if ((professionName ?? "").isNotEmpty) {
      return professionName!;
    }

    if ((occupationName ?? "").isNotEmpty) {
      return occupationName!;
    }

    return "";
  }

  toJson() {}
}

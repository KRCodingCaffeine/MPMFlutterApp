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
  String? createdAt; // ✅ ADDED

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
    this.createdAt,
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
    createdAt = json['created_at']; // ✅ MAPPED
  }

  /// Full name fallback logic
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

  /// Profession display logic
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

  String get connectedDateFormatted {
    if (createdAt == null || createdAt!.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(createdAt!.replaceAll(" ", "T"));
      return "${dateTime.day.toString().padLeft(2, '0')} "
          "${_monthName(dateTime.month)} "
          "${dateTime.year}";
    } catch (_) {
      return createdAt!.split(" ").first; // fallback
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  Map<String, dynamic> toJson() {
    return {
      "member_business_connect_request_id": requestId,
      "requested_to_member_id": memberId,
      "requested_to_member_code": memberCode,
      "requested_to_first_name": firstName,
      "requested_to_middle_name": middleName,
      "requested_to_last_name": lastName,
      "requested_to_full_name": fullName,
      "requested_to_mobile": mobile,
      "requested_to_profile_image": profileImage,
      "occupation_name": occupationName,
      "occupation_profession_name": professionName,
      "occupation_specialization_name": specializationName,
      "business_connect_requested_status": status,
      "created_at": createdAt,
    };
  }
}

// lib/model/SearchOccupation/SearchOccupationData.dart
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

  factory OccupationInfo.fromJson(Map<String, dynamic> json) {
    return OccupationInfo(
      occupationId: json['occupation_id']?.toString(),
      occupationName: json['occupation_name']?.toString(),
      professionId: json['profession_id']?.toString(),
      professionName: json['profession_name']?.toString(),
      specializationId: json['specialization_id']?.toString(),
      specializationName: json['specialization_name']?.toString(),
    );
  }
}

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

  factory SearchOccupationData.fromJson(Map<String, dynamic> json) {
    OccupationInfo? occupationInfo;

    // Check if occupation data exists and create OccupationInfo
    if (json['occupation'] != null && json['occupation'] is Map) {
      occupationInfo = OccupationInfo.fromJson(json['occupation']);
    }

    return SearchOccupationData(
      memberId: json['member_id']?.toString(),
      memberCode: json['member_code']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profile_image']?.toString(),
      occupation: occupationInfo,
    );
  }

  // Helper getters for occupation data
  String? get occupationName => occupation?.occupationName;
  String? get professionName => occupation?.professionName;
  String? get specializationName => occupation?.specializationName;
}
// lib/model/SearchOccupation/SearchOccupationData.dart
class OccupationInfo {
  String? occupationId;
  String? occupationName;
  String? professionId;
  String? professionName;
  String? specializationId;
  String? specializationName;
  String? specializationSubCategoryId;
  String? specializationSubCategoryName;
  String? specializationSubSubCategoryId;
  String? specializationSubSubCategoryName;

  OccupationInfo({
    this.occupationId,
    this.occupationName,
    this.professionId,
    this.professionName,
    this.specializationId,
    this.specializationName,
    this.specializationSubCategoryId,
    this.specializationSubCategoryName,
    this.specializationSubSubCategoryId,
    this.specializationSubSubCategoryName,
  });

  factory OccupationInfo.fromJson(Map<String, dynamic> json) {
    return OccupationInfo(
      occupationId: json['occupation_id']?.toString(),
      occupationName: json['occupation_name']?.toString(),
      professionId: json['profession_id']?.toString(),
      professionName: json['profession_name']?.toString(),
      specializationId: json['specialization_id']?.toString(),
      specializationName: json['specialization_name']?.toString(),
      specializationSubCategoryId: json['specialization_sub_category_id']?.toString(),
      specializationSubCategoryName: json['specialization_sub_category_name']?.toString(),
      specializationSubSubCategoryId: json['specialization_sub_sub_category_id']?.toString(),
      specializationSubSubCategoryName: json['specialization_sub_sub_category_name']?.toString(),
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
  
  // Additional fields from API response for filtering
  String? occupationName;
  String? occupationProfessionName;
  String? specializationName;
  String? subCategoryName;
  String? subSubCategoryName;
  String? zoneId;
  String? zoneName;

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
    this.occupationName,
    this.occupationProfessionName,
    this.specializationName,
    this.subCategoryName,
    this.subSubCategoryName,
    this.zoneId,
    this.zoneName,
  });

  factory SearchOccupationData.fromJson(Map<String, dynamic> json) {
    OccupationInfo? occupationInfo;

    // Check if occupation data exists and create OccupationInfo
    if (json['occupation'] != null && json['occupation'] is Map) {
      occupationInfo = OccupationInfo.fromJson(json['occupation']);
    }

    // 🔥 FIX: Handle nested member object OR direct member_id
    String? parsedMemberId;

    if (json['member_id'] != null) {
      parsedMemberId = json['member_id'].toString();
    } else if (json['member'] != null &&
        json['member'] is Map &&
        json['member']['member_id'] != null) {
      parsedMemberId = json['member']['member_id'].toString();
    } else {
      parsedMemberId = null;
    }

    return SearchOccupationData(
      memberId: parsedMemberId,
      memberCode: json['member_code']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      fullName: json['full_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profile_image']?.toString(),
      occupation: occupationInfo,
      // Extract filter fields directly from JSON (matching PHP structure)
      // Check if occupation is a Map/object first, then extract name
      occupationName: json['occupation'] is Map 
          ? json['occupation']['occupation_name']?.toString()
          : (json['occupation_name']?.toString() ?? json['occupation']?.toString() ?? occupationInfo?.occupationName),
      occupationProfessionName: json['occupation'] is Map
          ? json['occupation']['profession_name']?.toString()
          : (json['occupation_profession_name']?.toString() ?? occupationInfo?.professionName),
      specializationName: json['occupation'] is Map
          ? json['occupation']['specialization_name']?.toString()
          : (json['specialization_name']?.toString() ?? occupationInfo?.specializationName),
      subCategoryName: json['occupation'] is Map
          ? json['occupation']['specialization_sub_category_name']?.toString()
          : (json['sub_category_name']?.toString() ?? occupationInfo?.specializationSubCategoryName),
      subSubCategoryName: json['occupation'] is Map
          ? json['occupation']['specialization_sub_sub_category_name']?.toString()
          : (json['sub_sub_category_name']?.toString() ?? occupationInfo?.specializationSubSubCategoryName),
      zoneId: json['zone_id']?.toString(),
      zoneName: json['zone_name']?.toString(),
    );
  }

  // Helper getters for occupation data
  String? get occupationNameValue => occupationName ?? occupation?.occupationName;
  String? get professionNameValue => occupationProfessionName ?? occupation?.professionName;
  String? get specializationNameValue => specializationName ?? occupation?.specializationName;
  String? get subCategoryNameValue => subCategoryName ?? occupation?.specializationSubCategoryName;
  String? get subSubCategoryNameValue => subSubCategoryName ?? occupation?.specializationSubSubCategoryName;
}
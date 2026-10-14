class GetJobAppliedMembersData {
  String? memberJobAppliedId;
  String? memberId;
  String? jobId;
  String? applicationStatus;
  String? appliedDate;
  String? appliedBy;
  String? remarks;

  String? memberCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? whatsappNumber;
  String? email;
  String? profileImage;
  String? dob;
  String? genderId;
  String? membershipTypeId;
  String? memberStatusId;

  String? name;
  String? profileImagePath;

  // ✅ NEW
  String? fatherName;
  String? motherName;
  AppliedMemberAddress? address;
  List<AppliedMemberQualification>? qualification;

  GetJobAppliedMembersData({
    this.memberJobAppliedId,
    this.memberId,
    this.jobId,
    this.applicationStatus,
    this.appliedDate,
    this.appliedBy,
    this.remarks,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.profileImage,
    this.dob,
    this.genderId,
    this.membershipTypeId,
    this.memberStatusId,
    this.name,
    this.profileImagePath,
    this.fatherName,
    this.motherName,
    this.address,
    this.qualification,
  });

  GetJobAppliedMembersData.fromJson(Map<String, dynamic> json) {
    memberJobAppliedId = json['member_job_applied_id']?.toString();
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    applicationStatus = json['application_status']?.toString();
    appliedDate = json['applied_date']?.toString();
    appliedBy = json['applied_by']?.toString();
    remarks = json['remarks']?.toString();

    memberCode = json['member_code']?.toString();
    firstName = json['first_name']?.toString();
    middleName = json['middle_name']?.toString();
    lastName = json['last_name']?.toString();
    mobile = json['mobile']?.toString();
    whatsappNumber = json['whatsapp_number']?.toString();
    email = json['email']?.toString();
    profileImage = json['profile_image']?.toString();
    dob = json['dob']?.toString();
    genderId = json['gender_id']?.toString();
    membershipTypeId = json['membership_type_id']?.toString();
    memberStatusId = json['member_status_id']?.toString();

    name = json['name']?.toString();
    profileImagePath = json['profile_image_path']?.toString();

    // ✅ NEW — parse nested objects
    fatherName = json['father_name']?.toString();
    motherName = json['mother_name']?.toString();

    if (json['address'] != null && json['address'] is Map) {
      address = AppliedMemberAddress.fromJson(
        Map<String, dynamic>.from(json['address']),
      );
    }

    if (json['qualification'] != null && json['qualification'] is List) {
      qualification = (json['qualification'] as List)
          .where((e) => e is Map)
          .map((e) =>
          AppliedMemberQualification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'member_job_applied_id': memberJobAppliedId,
      'member_id': memberId,
      'job_id': jobId,
      'application_status': applicationStatus,
      'applied_date': appliedDate,
      'applied_by': appliedBy,
      'remarks': remarks,
      'member_code': memberCode,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'profile_image': profileImage,
      'dob': dob,
      'gender_id': genderId,
      'membership_type_id': membershipTypeId,
      'member_status_id': memberStatusId,
      'name': name,
      'profile_image_path': profileImagePath,
      'father_name': fatherName,
      'mother_name': motherName,
      'address': address?.toJson(),
      'qualification': qualification?.map((e) => e.toJson()).toList(),
    };
  }
}

// ✅ NEW nested class
class AppliedMemberAddress {
  String? memberAddressId;
  String? memberId;
  String? addressType;
  String? flatNo;
  String? buildingNameId;
  String? address;
  String? areaName;
  String? cityId;
  String? stateId;
  String? countryId;
  String? zoneId;
  String? pincode;
  String? zoneName;
  String? cityName;
  String? countryName;
  String? stateName;
  String? buildingName;

  AppliedMemberAddress({
    this.memberAddressId,
    this.memberId,
    this.addressType,
    this.flatNo,
    this.buildingNameId,
    this.address,
    this.areaName,
    this.cityId,
    this.stateId,
    this.countryId,
    this.zoneId,
    this.pincode,
    this.zoneName,
    this.cityName,
    this.countryName,
    this.stateName,
    this.buildingName,
  });

  AppliedMemberAddress.fromJson(Map<String, dynamic> json) {
    memberAddressId = json['member_address_id']?.toString();
    memberId = json['member_id']?.toString();
    addressType = json['address_type']?.toString();
    flatNo = json['flat_no']?.toString();
    buildingNameId = json['building_name_id']?.toString();
    address = json['address']?.toString();
    areaName = json['area_name']?.toString();
    cityId = json['city_id']?.toString();
    stateId = json['state_id']?.toString();
    countryId = json['country_id']?.toString();
    zoneId = json['zone_id']?.toString();
    pincode = json['pincode']?.toString();
    zoneName = json['zone_name']?.toString();
    cityName = json['city_name']?.toString();
    countryName = json['country_name']?.toString();
    stateName = json['state_name']?.toString();
    buildingName = json['building_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_address_id': memberAddressId,
      'member_id': memberId,
      'address_type': addressType,
      'flat_no': flatNo,
      'building_name_id': buildingNameId,
      'address': address,
      'area_name': areaName,
      'city_id': cityId,
      'state_id': stateId,
      'country_id': countryId,
      'zone_id': zoneId,
      'pincode': pincode,
      'zone_name': zoneName,
      'city_name': cityName,
      'country_name': countryName,
      'state_name': stateName,
      'building_name': buildingName,
    };
  }
}

// ✅ NEW nested class
class AppliedMemberQualification {
  String? memberQualificationId;
  String? memberId;
  String? qualification;
  String? qualificationName;
  String? qualificationMainName;
  String? qualificationCategoryName;

  AppliedMemberQualification({
    this.memberQualificationId,
    this.memberId,
    this.qualification,
    this.qualificationName,
    this.qualificationMainName,
    this.qualificationCategoryName,
  });

  AppliedMemberQualification.fromJson(Map<String, dynamic> json) {
    memberQualificationId = json['member_qualification_id']?.toString();
    memberId = json['member_id']?.toString();
    qualification = json['qualification']?.toString();
    qualificationName =
        (json['qualification_name'] ?? json['qualification'])?.toString();
    qualificationMainName = json['qualification_main_name']?.toString();
    qualificationCategoryName = json['qualification_category_name']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_qualification_id': memberQualificationId,
      'member_id': memberId,
      'qualification': qualification,
      'qualification_name': qualificationName,
      'qualification_main_name': qualificationMainName,
      'qualification_category_name': qualificationCategoryName,
    };
  }
}
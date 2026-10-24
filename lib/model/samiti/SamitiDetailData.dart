class SamitiDetailData{

 var memberSamitiRoleMappingId;
  var memberId;
 var samitiSubCategoryId;
 var samitiRoleId;
 var startsFrom;
 var endTo;
 var status;
 var createdBy;
 var createdAt;
  var updatedBy;
  var updatedAt;
  var firstName;
  var middleName;
  var lastName;
  var mobile;
  var memberCode;
  var email;
 var samitiRolesName;
 var profileImagePath;
 var encryptedMemberId;
 var presidentName;
 var presidentSatra;
 var genderId;
 var maritalStatusId;
 var salutation;

  SamitiDetailData(
      {
        this.memberSamitiRoleMappingId,
        this.memberId,
        this.samitiSubCategoryId,
        this.samitiRoleId,
        this.startsFrom,
        this.endTo,
        this.status,
        this.createdBy,
        this.createdAt,
        this.updatedBy,
        this.updatedAt,
        this.firstName,
        this.middleName,
        this.lastName,
        this.mobile,
        this.memberCode,
        this.email,
        this.samitiRolesName,
        this.profileImagePath,
        this.encryptedMemberId,
        this.presidentName,
        this.presidentSatra,
        this.genderId,
        this.maritalStatusId,
        this.salutation});

  SamitiDetailData.fromJson(Map<String, dynamic> json) {
    memberSamitiRoleMappingId = json['member_samiti_role_mapping_id'];
    memberId = json['member_id'];
    samitiSubCategoryId = json['samiti_sub_category_id'];
    samitiRoleId = json['samiti_role_id'];
    startsFrom = json['starts_from'];
    endTo = json['end_to'];
    status = json['status'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    memberCode = json['member_code'];
    email = json['email'];
    samitiRolesName = json['samiti_roles_name'];
    profileImagePath = json['profile_image_path'];
    encryptedMemberId = json['encrypted_member_id'];
    presidentName = json['president_name'];
    presidentSatra = json['president_satra'];
    genderId = json['gender_id'];
    maritalStatusId = json['marital_status_id'];
    salutation = json['salutation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_samiti_role_mapping_id'] = this.memberSamitiRoleMappingId;
    data['member_id'] = this.memberId;
    data['samiti_sub_category_id'] = this.samitiSubCategoryId;
    data['samiti_role_id'] = this.samitiRoleId;
    data['starts_from'] = this.startsFrom;
    data['end_to'] = this.endTo;
    data['status'] = this.status;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['mobile'] = this.mobile;
    data['member_code'] = this.memberCode;
    data['email'] = this.email;
    data['samiti_roles_name'] = this.samitiRolesName;
    data['profile_image_path'] = this.profileImagePath;
    data['encrypted_member_id'] = this.encryptedMemberId;
    data['president_name'] = this.presidentName;
    data['president_satra'] = this.presidentSatra;
    data['gender_id'] = this.genderId;
    data['marital_status_id'] = this.maritalStatusId;
    data['salutation'] = this.salutation;
    return data;
  }

  /// Shri for male, Smt for female, Ms for unmarried female (marital status 2)
  String get displaySalutation {
    final gender = genderId?.toString().trim() ?? "";
    final maritalStatus = maritalStatusId?.toString().trim() ?? "";
    if (gender == "1") return "Shri";
    if (gender == "2") return maritalStatus == "2" ? "Ms" : "Smt";
    final apiSalutation = salutation?.toString().trim() ?? "";
    return apiSalutation.toLowerCase() == "null" ? "" : apiSalutation;
  }
}



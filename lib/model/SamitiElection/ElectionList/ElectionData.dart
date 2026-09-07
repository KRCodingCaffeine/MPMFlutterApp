class ElectionData {
  String? electionId;
  String? candidateType;
  String? memberId;

  String? firstName;
  String? middleName;
  String? lastName;

  String? mobile;
  String? email;
  String? memberCode;

  String? samitiId;
  String? samitiSubCategoryId;
  String? samitiRoleId;

  String? startYear;
  String? endYear;

  String? status;
  String? consentRespondedAt;

  String? adminConfirmedBy;
  String? adminConfirmedAt;

  String? createdBy;
  String? createdAt;

  String? updatedBy;
  String? updatedAt;

  String? samitiName;
  String? samitiSubCategoryName;
  String? samitiRolesName;

  ElectionData({
    this.electionId,
    this.candidateType,
    this.memberId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.email,
    this.memberCode,
    this.samitiId,
    this.samitiSubCategoryId,
    this.samitiRoleId,
    this.startYear,
    this.endYear,
    this.status,
    this.consentRespondedAt,
    this.adminConfirmedBy,
    this.adminConfirmedAt,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.samitiName,
    this.samitiSubCategoryName,
    this.samitiRolesName,
  });

  factory ElectionData.fromJson(Map<String, dynamic> json) {
    return ElectionData(
      electionId: json['election_id']?.toString(),

      candidateType: json['candidate_type']?.toString(),

      memberId: json['member_id']?.toString(),

      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),

      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      memberCode: json['member_code']?.toString(),

      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryId:
      json['samiti_sub_category_id']?.toString(),
      samitiRoleId: json['samiti_role_id']?.toString(),

      startYear: json['start_year']?.toString(),
      endYear: json['end_year']?.toString(),

      status: json['status']?.toString(),

      consentRespondedAt:
      json['consent_responded_at']?.toString(),

      adminConfirmedBy:
      json['admin_confirmed_by']?.toString(),

      adminConfirmedAt:
      json['admin_confirmed_at']?.toString(),

      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),

      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),

      samitiName: json['samiti_name']?.toString(),

      samitiSubCategoryName:
      json['samiti_sub_category_name']?.toString(),

      samitiRolesName:
      json['samiti_roles_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
      'candidate_type': candidateType,
      'member_id': memberId,

      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,

      'mobile': mobile,
      'email': email,
      'member_code': memberCode,

      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_role_id': samitiRoleId,

      'start_year': startYear,
      'end_year': endYear,

      'status': status,
      'consent_responded_at': consentRespondedAt,

      'admin_confirmed_by': adminConfirmedBy,
      'admin_confirmed_at': adminConfirmedAt,

      'created_by': createdBy,
      'created_at': createdAt,

      'updated_by': updatedBy,
      'updated_at': updatedAt,

      'samiti_name': samitiName,
      'samiti_sub_category_name': samitiSubCategoryName,
      'samiti_roles_name': samitiRolesName,
    };
  }

  String get fullName {
    return [
      firstName,
      middleName,
      lastName,
    ]
        .where((name) => name != null && name!.trim().isNotEmpty)
        .join(' ');
  }
}
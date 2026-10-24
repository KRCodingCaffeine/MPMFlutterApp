class AddNONMElectionData {
  String? candidateType;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? email;
  String? whatsappNumber;
  String? samitiId;
  String? samitiSubCategoryId;
  String? samitiRoleId;
  String? startYear;
  String? endYear;
  String? createdBy;

  AddNONMElectionData({
    this.candidateType,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.email,
    this.whatsappNumber,
    this.samitiId,
    this.samitiSubCategoryId,
    this.samitiRoleId,
    this.startYear,
    this.endYear,
    this.createdBy,
  });

  factory AddNONMElectionData.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddNONMElectionData(
      candidateType: json['candidate_type']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryId: json['samiti_sub_category_id']?.toString(),
      samitiRoleId: json['samiti_role_id']?.toString(),
      startYear: json['start_year']?.toString(),
      endYear: json['end_year']?.toString(),
      createdBy: json['created_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidate_type': candidateType,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'email': email,
      'whatsapp_number': whatsappNumber,
      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_role_id': samitiRoleId,
      'start_year': startYear,
      'end_year': endYear,
      'created_by': createdBy,
    };
  }
}

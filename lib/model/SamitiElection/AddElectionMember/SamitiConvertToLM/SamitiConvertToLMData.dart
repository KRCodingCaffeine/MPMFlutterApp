class SamitiConvertToLMData {
  String? memberId;
  String? mobile;
  String? whatsappNumber;
  String? email;
  String? genderId;
  String? bloodGroupId;
  String? maritalStatusId;
  String? marriageAnniversaryDate;

  String? samitiId;
  String? samitiSubCategoryId;
  String? samitiRoleId;
  String? startYear;
  String? endYear;

  SamitiConvertToLMData({
    this.memberId,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.genderId,
    this.bloodGroupId,
    this.maritalStatusId,
    this.marriageAnniversaryDate,
    this.samitiId,
    this.samitiSubCategoryId,
    this.samitiRoleId,
    this.startYear,
    this.endYear,
  });

  factory SamitiConvertToLMData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SamitiConvertToLMData(
      memberId: json['member_id']?.toString(),
      mobile: json['mobile']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      email: json['email']?.toString(),
      genderId: json['gender_id']?.toString(),
      bloodGroupId: json['blood_group_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      marriageAnniversaryDate: json['marriage_anniversary_date']?.toString(),
      samitiId: json['samiti_id']?.toString(),
      samitiSubCategoryId: json['samiti_sub_category_id']?.toString(),
      samitiRoleId: json['samiti_role_id']?.toString(),
      startYear: json['start_year']?.toString(),
      endYear: json['end_year']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'mobile': mobile,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'gender_id': genderId,
      'blood_group_id': bloodGroupId,
      'marital_status_id': maritalStatusId,
      'marriage_anniversary_date': marriageAnniversaryDate,
      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_role_id': samitiRoleId,
      'start_year': startYear,
      'end_year': endYear,
    };
  }
}

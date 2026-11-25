class ConvertToLMData {
  String? memberId;
  String? mobile;
  String? whatsappNumber;
  String? email;
  String? genderId;
  String? bloodGroupId;
  String? maritalStatusId;
  String? marriageAnniversaryDate;

  ConvertToLMData({
    this.memberId,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.genderId,
    this.bloodGroupId,
    this.maritalStatusId,
    this.marriageAnniversaryDate,
  });

  factory ConvertToLMData.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConvertToLMData(
      memberId: json['member_id']?.toString(),
      mobile: json['mobile']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      email: json['email']?.toString(),
      genderId: json['gender_id']?.toString(),
      bloodGroupId: json['blood_group_id']?.toString(),
      maritalStatusId: json['marital_status_id']?.toString(),
      marriageAnniversaryDate: json['marriage_anniversary_date']?.toString(),
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
    };
  }
}

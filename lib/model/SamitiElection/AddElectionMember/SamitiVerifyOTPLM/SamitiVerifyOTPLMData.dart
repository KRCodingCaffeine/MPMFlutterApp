// Update the model class
class SamitiVerifyOTPLMData {
  String? memberId;
  String? otp;
  String? samitiId;
  String? samitiSubCategoryId;
  String? samitiRoleId;
  String? startYear;
  String? endYear;

  SamitiVerifyOTPLMData({
    this.memberId,
    this.otp,
    this.samitiId,
    this.samitiSubCategoryId,
    this.samitiRoleId,
    this.startYear,
    this.endYear,
  });

  factory SamitiVerifyOTPLMData.fromJson(
    Map<String, dynamic> json,
  ) {
    return SamitiVerifyOTPLMData(
      memberId: json['member_id']?.toString(),
      otp: json['otp']?.toString(),
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
      'otp': otp,
      'samiti_id': samitiId,
      'samiti_sub_category_id': samitiSubCategoryId,
      'samiti_role_id': samitiRoleId,
      'start_year': startYear,
      'end_year': endYear,
    };
  }
}

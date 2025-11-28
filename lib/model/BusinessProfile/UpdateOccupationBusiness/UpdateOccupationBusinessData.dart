class UpdateOccupationBusinessData {
  String? memberBusinessOccupationProfileId;
  String? memberId;
  String? memberOccupationId;
  String? businessName;
  String? businessMobile;
  String? businessLandline;
  String? businessEmail;
  String? businessWebsite;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  UpdateOccupationBusinessData({
    this.memberBusinessOccupationProfileId,
    this.memberId,
    this.memberOccupationId,
    this.businessName,
    this.businessMobile,
    this.businessLandline,
    this.businessEmail,
    this.businessWebsite,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory UpdateOccupationBusinessData.fromJson(Map<String, dynamic> json) {
    return UpdateOccupationBusinessData(
      memberBusinessOccupationProfileId:
      json['member_business_occupation_profile_id']?.toString(),
      memberId: json['member_id']?.toString(),
      memberOccupationId: json['member_occupation_id']?.toString(),
      businessName: json['business_name'],
      businessMobile: json['business_mobile'],
      businessLandline: json['business_landline'],
      businessEmail: json['business_email'],
      businessWebsite: json['business_website'],
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_business_occupation_profile_id':
      memberBusinessOccupationProfileId,
      'member_id': memberId,
      'member_occupation_id': memberOccupationId,
      'business_name': businessName,
      'business_mobile': businessMobile,
      'business_landline': businessLandline,
      'business_email': businessEmail,
      'business_website': businessWebsite,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}

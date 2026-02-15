class AddUpdateFamilyData {
  String? shikshaApplicantFamilyId;
  String? shikshaApplicantId;
  String? familyMemberId;
  String? relationshipWithApplicantId;
  String? familyMemberOccupationType;
  String? familyMemberOccupationName;
  String? familyMemberStandard;
  String? familyMemberInstitute;
  String? familyMemberAnnualIncome;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  AddUpdateFamilyData({
    this.shikshaApplicantFamilyId,
    this.shikshaApplicantId,
    this.familyMemberId,
    this.relationshipWithApplicantId,
    this.familyMemberOccupationType,
    this.familyMemberOccupationName,
    this.familyMemberStandard,
    this.familyMemberInstitute,
    this.familyMemberAnnualIncome,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory AddUpdateFamilyData.fromJson(Map<String, dynamic> json) {
    return AddUpdateFamilyData(
      shikshaApplicantFamilyId:
      json['shiksha_applicant_family_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      familyMemberId:
      json['family_member_id']?.toString(),
      relationshipWithApplicantId:
      json['relationship_with_applicant_id']?.toString(),
      familyMemberOccupationType:
      json['family_member_occupation_type']?.toString(),
      familyMemberOccupationName:
      json['family_member_occupation_name']?.toString(),
      familyMemberStandard:
      json['family_member_standard']?.toString(),
      familyMemberInstitute:
      json['family_member_institute']?.toString(),
      familyMemberAnnualIncome:
      json['family_member_anual_income']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_id": shikshaApplicantId,
      "family_member_id": familyMemberId,
      "relationship_with_applicant_id": relationshipWithApplicantId,
      "family_member_occupation_type": familyMemberOccupationType,
      "family_member_occupation_name": familyMemberOccupationName,
      "family_member_standard": familyMemberStandard,
      "family_member_institute": familyMemberInstitute,
      "family_member_anual_income": familyMemberAnnualIncome,
      "created_by": createdBy,
      "updated_by": updatedBy,
    };
  }
}

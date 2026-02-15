class FamilyMember {
  final String? shikshaApplicantFamilyId;
  final String? shikshaApplicantId;
  final String? familyMemberId;
  final String? relationshipWithApplicantId;

  final String? relationshipName;

  final String? familyMemberCode;
  final String? familyMemberFullName;
  final String? familyMemberEmail;
  final String? familyMemberMobile;

  final String? familyMemberOccupationType;
  final String? familyMemberOccupationName;
  final String? familyMemberStandard;
  final String? familyMemberInstitute;
  final String? familyMemberAnnualIncome;

  FamilyMember({
    this.shikshaApplicantFamilyId,
    this.shikshaApplicantId,
    this.familyMemberId,
    this.relationshipWithApplicantId,
    this.relationshipName,
    this.familyMemberCode,
    this.familyMemberFullName,
    this.familyMemberEmail,
    this.familyMemberMobile,
    this.familyMemberOccupationType,
    this.familyMemberOccupationName,
    this.familyMemberStandard,
    this.familyMemberInstitute,
    this.familyMemberAnnualIncome,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      shikshaApplicantFamilyId:
      json['shiksha_applicant_family_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      familyMemberId:
      json['family_member_id']?.toString(),
      relationshipWithApplicantId:
      json['relationship_with_applicant_id']?.toString(),
      relationshipName:
      json['relationship_name']?.toString(),
      familyMemberCode:
      json['family_member_code']?.toString(),
      familyMemberFullName:
      json['family_member_full_name']?.toString(),
      familyMemberEmail:
      json['family_member_email']?.toString(),
      familyMemberMobile:
      json['family_member_mobile']?.toString(),
      familyMemberOccupationType:
      json['family_member_occupation_type']?.toString(),
      familyMemberOccupationName:
      json['family_member_occupation_name']?.toString(),
      familyMemberStandard:
      json['family_member_standard']?.toString(),
      familyMemberInstitute:
      json['family_member_institute']?.toString(),
      familyMemberAnnualIncome:
      json['family_member_annual_income']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_family_id": shikshaApplicantFamilyId,
      "shiksha_applicant_id": shikshaApplicantId,
      "family_member_id": familyMemberId,
      "relationship_with_applicant_id": relationshipWithApplicantId,
      "relationship_name": relationshipName,
      "family_member_code": familyMemberCode,
      "family_member_full_name": familyMemberFullName,
      "family_member_email": familyMemberEmail,
      "family_member_mobile": familyMemberMobile,
      "family_member_occupation_type": familyMemberOccupationType,
      "family_member_occupation_name": familyMemberOccupationName,
      "family_member_standard": familyMemberStandard,
      "family_member_institute": familyMemberInstitute,
      "family_member_annual_income": familyMemberAnnualIncome,
    };
  }
}

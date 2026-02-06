class FamilyMember {
  final String? relationshipName;
  final String? familyMemberFullName;
  final String? familyMemberOccupationType;
  final String? familyMemberAnnualIncome;

  FamilyMember({
    this.relationshipName,
    this.familyMemberFullName,
    this.familyMemberOccupationType,
    this.familyMemberAnnualIncome,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      relationshipName: json['relationship_name']?.toString(),
      familyMemberFullName:
      json['family_member_full_name']?.toString(),
      familyMemberOccupationType:
      json['family_member_occupation_type']?.toString(),
      familyMemberAnnualIncome:
      json['family_member_annual_income']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relationship_name': relationshipName,
      'family_member_full_name': familyMemberFullName,
      'family_member_occupation_type': familyMemberOccupationType,
      'family_member_annual_income': familyMemberAnnualIncome,
    };
  }
}

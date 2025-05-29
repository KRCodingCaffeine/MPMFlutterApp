class ChangeFamilyHeadData {
  int? currentFamilyHeadId;
  int? newFamilyHeadId;
  int? relationshipId;
  int? memberId;

  ChangeFamilyHeadData({
    this.currentFamilyHeadId,
    this.newFamilyHeadId,
    this.relationshipId,
    this.memberId,
  });

  factory ChangeFamilyHeadData.fromJson(Map<String, dynamic> json) {
    return ChangeFamilyHeadData(
      currentFamilyHeadId: json['current_family_head_id'],
      newFamilyHeadId: json['new_family_head_id'],
      relationshipId: json['relationship_id'],
      memberId: json['member_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_family_head_id': currentFamilyHeadId,
      'new_family_head_id': newFamilyHeadId,
      'relationship_id': relationshipId,
      'member_id': memberId,
    };
  }
}

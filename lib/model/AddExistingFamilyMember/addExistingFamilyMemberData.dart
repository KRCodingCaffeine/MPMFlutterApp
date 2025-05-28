class AddExistingMemberIntoFamilyData {
  int? relationId;
  int? memberId;
  int? currentMemberId;

  AddExistingMemberIntoFamilyData({
    this.relationId,
    this.memberId,
    this.currentMemberId,
  });

factory AddExistingMemberIntoFamilyData.fromJson(Map<String, dynamic> json) {
    return AddExistingMemberIntoFamilyData(
      relationId: json['relation_id'],
      memberId: json['member_id'],
      currentMemberId: json['current_member_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'relation_id': relationId,
      'member_id': memberId,
      'current_member_id': currentMemberId,
    };
  }
}

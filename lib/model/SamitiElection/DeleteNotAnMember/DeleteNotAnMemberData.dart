class DeleteNotAnMemberData {
  String? electionId;

  DeleteNotAnMemberData({
    this.electionId,
  });

  factory DeleteNotAnMemberData.fromJson(
      Map<String, dynamic> json,
      ) {
    return DeleteNotAnMemberData(
      electionId: json['election_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'election_id': electionId,
    };
  }
}
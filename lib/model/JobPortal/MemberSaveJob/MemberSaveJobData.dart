class MemberSaveJobData {
  String? memberId;
  String? jobId;
  String? isSaved;
  String? isSavedDate;
  String? createdBy;
  String? createdAt;

  MemberSaveJobData({
    this.memberId,
    this.jobId,
    this.isSaved,
    this.isSavedDate,
    this.createdBy,
    this.createdAt,
  });

  MemberSaveJobData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    isSaved = json['is_saved']?.toString();
    isSavedDate = json['is_saved_date']?.toString();
    createdBy = json['created_by']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'job_id': jobId,
      'is_saved': isSaved,
      'is_saved_date': isSavedDate,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}

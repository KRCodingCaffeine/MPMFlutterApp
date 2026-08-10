class MemberApplyJobData {
  String? memberId;
  String? jobId;
  String? applicationStatus;
  String? appliedDate;
  String? remarks;
  String? createdBy;
  String? createdAt;

  MemberApplyJobData({
    this.memberId,
    this.jobId,
    this.applicationStatus,
    this.appliedDate,
    this.remarks,
    this.createdBy,
    this.createdAt,
  });

  MemberApplyJobData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    applicationStatus = json['application_status']?.toString();
    appliedDate = json['applied_date']?.toString();
    remarks = json['remarks']?.toString();
    createdBy = json['created_by']?.toString();
    createdAt = json['created_at']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'job_id': jobId,
      'application_status': applicationStatus,
      'applied_date': appliedDate,
      'remarks': remarks,
      'created_by': createdBy,
      'created_at': createdAt,
    };
  }
}
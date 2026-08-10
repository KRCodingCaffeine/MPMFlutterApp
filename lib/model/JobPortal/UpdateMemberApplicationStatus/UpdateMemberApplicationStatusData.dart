class UpdateMemberApplicationStatusData {
  String? memberId;
  String? jobId;
  String? applicationStatus;

  UpdateMemberApplicationStatusData({
    this.memberId,
    this.jobId,
    this.applicationStatus,
  });

  UpdateMemberApplicationStatusData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    applicationStatus = json['application_status']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_id'] = memberId;
    data['job_id'] = jobId;
    data['application_status'] = applicationStatus;

    return data;
  }
}

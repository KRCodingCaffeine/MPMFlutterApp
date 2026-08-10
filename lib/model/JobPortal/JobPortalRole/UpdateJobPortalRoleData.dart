class UpdateJobPortalRoleData {
  String? memberId;
  String? jobPortalRole;

  UpdateJobPortalRoleData({
    this.memberId,
    this.jobPortalRole,
  });

  UpdateJobPortalRoleData.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id']?.toString();
    jobPortalRole = json['job_portal_role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_id'] = memberId;
    data['job_portal_role'] = jobPortalRole;
    return data;
  }
}
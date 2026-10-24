class AppliedMemberData {
  String? memberJobAppliedId;
  String? memberId;
  String? memberCode;

  String? firstName;
  String? middleName;
  String? lastName;

  String? mobile;
  String? whatsappNumber;
  String? email;

  String? profileImage;
  String? resumePath;
  String? headline;

  String? applicationStatus;
  String? statusLabel;

  String? appliedDate;
  String? remarks;

  AppliedMemberData({
    this.memberJobAppliedId,
    this.memberId,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.profileImage,
    this.resumePath,
    this.headline,
    this.applicationStatus,
    this.statusLabel,
    this.appliedDate,
    this.remarks,
  });

  AppliedMemberData.fromJson(Map<String, dynamic> json) {
    memberJobAppliedId = json['member_job_applied_id']?.toString();

    memberId = json['member_id']?.toString();

    memberCode = json['member_code']?.toString();

    firstName = json['first_name']?.toString();

    middleName = json['middle_name']?.toString();

    lastName = json['last_name']?.toString();

    mobile = json['mobile']?.toString();

    whatsappNumber = json['whatsapp_number']?.toString();

    email = json['email']?.toString();

    profileImage = json['profile_image']?.toString();

    resumePath = json['resume_path']?.toString();

    headline = json['headline']?.toString();

    applicationStatus = json['application_status']?.toString();

    statusLabel = json['status_label']?.toString();

    appliedDate = json['applied_date']?.toString();

    remarks = json['remarks']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['member_job_applied_id'] = memberJobAppliedId;

    data['member_id'] = memberId;

    data['member_code'] = memberCode;

    data['first_name'] = firstName;

    data['middle_name'] = middleName;

    data['last_name'] = lastName;

    data['mobile'] = mobile;

    data['whatsapp_number'] = whatsappNumber;

    data['email'] = email;

    data['profile_image'] = profileImage;

    data['resume_path'] = resumePath;

    data['headline'] = headline;

    data['application_status'] = applicationStatus;

    data['status_label'] = statusLabel;

    data['applied_date'] = appliedDate;

    data['remarks'] = remarks;

    return data;
  }
}

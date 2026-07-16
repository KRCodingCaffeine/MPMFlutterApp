class GetJobAppliedMembersData {
  String? memberJobAppliedId;
  String? memberId;
  String? jobId;
  String? applicationStatus;
  String? appliedDate;
  String? remarks;

  String? memberCode;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? whatsappNumber;
  String? email;
  String? profileImage;
  String? dob;
  String? genderId;
  String? membershipTypeId;
  String? memberStatusId;

  String? name;
  String? profileImagePath;

  GetJobAppliedMembersData({
    this.memberJobAppliedId,
    this.memberId,
    this.jobId,
    this.applicationStatus,
    this.appliedDate,
    this.remarks,
    this.memberCode,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.whatsappNumber,
    this.email,
    this.profileImage,
    this.dob,
    this.genderId,
    this.membershipTypeId,
    this.memberStatusId,
    this.name,
    this.profileImagePath,
  });

  GetJobAppliedMembersData.fromJson(Map<String, dynamic> json) {
    memberJobAppliedId = json['member_job_applied_id']?.toString();
    memberId = json['member_id']?.toString();
    jobId = json['job_id']?.toString();
    applicationStatus = json['application_status']?.toString();
    appliedDate = json['applied_date']?.toString();
    remarks = json['remarks']?.toString();

    memberCode = json['member_code']?.toString();
    firstName = json['first_name']?.toString();
    middleName = json['middle_name']?.toString();
    lastName = json['last_name']?.toString();
    mobile = json['mobile']?.toString();
    whatsappNumber = json['whatsapp_number']?.toString();
    email = json['email']?.toString();
    profileImage = json['profile_image']?.toString();
    dob = json['dob']?.toString();
    genderId = json['gender_id']?.toString();
    membershipTypeId = json['membership_type_id']?.toString();
    memberStatusId = json['member_status_id']?.toString();

    name = json['name']?.toString();
    profileImagePath = json['profile_image_path']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'member_job_applied_id': memberJobAppliedId,
      'member_id': memberId,
      'job_id': jobId,
      'application_status': applicationStatus,
      'applied_date': appliedDate,
      'remarks': remarks,
      'member_code': memberCode,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'whatsapp_number': whatsappNumber,
      'email': email,
      'profile_image': profileImage,
      'dob': dob,
      'gender_id': genderId,
      'membership_type_id': membershipTypeId,
      'member_status_id': memberStatusId,
      'name': name,
      'profile_image_path': profileImagePath,
    };
  }
}

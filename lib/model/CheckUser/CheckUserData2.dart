class CheckUserData2{
  String? memberId;
  String? memberCode;
  String? memberSalutaitonId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? whatsappNumber;
  String? email;
  Null? password;
  String? dob;
  Null? proposerId;
  String? maritalStatusId;
  String? marriageAnniversaryDate;
  String? genderId;
  String? bloodGroupId;
  String? fatherName;
  String? motherName;
  String? addressProofTypeId;
  String? addressProof;
  String? profileImage;
  String? otp;
  String? verifyOtpStatus;
  String? mobileVerifyStatus;
  String? sangathanApprovalStatus;
  String? vyavasthapikaApprovalStatus;
  String? memberStatusId;
  String? membershipApprovalStatusId;
  String? membershipTypeId;
  Null? familyHeadMemberId;
  Null? tempId;
  String? isJangana;
  Null? saraswaniOptionId;
  String? createdBy;
  String? createdAt;
  Null? updatedBy;
  String? updatedAt;

  CheckUserData2(
      {this.memberId,
        this.memberCode,
        this.memberSalutaitonId,
        this.firstName,
        this.middleName,
        this.lastName,
        this.mobile,
        this.whatsappNumber,
        this.email,
        this.password,
        this.dob,
        this.proposerId,
        this.maritalStatusId,
        this.marriageAnniversaryDate,
        this.genderId,
        this.bloodGroupId,
        this.fatherName,
        this.motherName,
        this.addressProofTypeId,
        this.addressProof,
        this.profileImage,
        this.otp,
        this.verifyOtpStatus,
        this.mobileVerifyStatus,
        this.sangathanApprovalStatus,
        this.vyavasthapikaApprovalStatus,
        this.memberStatusId,
        this.membershipApprovalStatusId,
        this.membershipTypeId,
        this.familyHeadMemberId,
        this.tempId,
        this.isJangana,
        this.saraswaniOptionId,
        this.createdBy,
        this.createdAt,
        this.updatedBy,
        this.updatedAt});

  CheckUserData2.fromJson(Map<String, dynamic> json) {
    memberId = json['member_id'];
    memberCode = json['member_code'];
    memberSalutaitonId = json['member_salutaiton_id'];
    firstName = json['first_name'];
    middleName = json['middle_name'];
    lastName = json['last_name'];
    mobile = json['mobile'];
    whatsappNumber = json['whatsapp_number'];
    email = json['email'];
    password = json['password'];
    dob = json['dob'];
    proposerId = json['proposer_id'];
    maritalStatusId = json['marital_status_id'];
    marriageAnniversaryDate = json['marriage_anniversary_date'];
    genderId = json['gender_id'];
    bloodGroupId = json['blood_group_id'];
    fatherName = json['father_name'];
    motherName = json['mother_name'];
    addressProofTypeId = json['address_proof_type_id'];
    addressProof = json['address_proof'];
    profileImage = json['profile_image'];
    otp = json['otp'];
    verifyOtpStatus = json['verify_otp_status'];
    mobileVerifyStatus = json['mobile_verify_status'];
    sangathanApprovalStatus = json['sangathan_approval_status'];
    vyavasthapikaApprovalStatus = json['vyavasthapika_approval_status'];
    memberStatusId = json['member_status_id'];
    membershipApprovalStatusId = json['membership_approval_status_id'];
    membershipTypeId = json['membership_type_id'];
    familyHeadMemberId = json['family_head_member_id'];
    tempId = json['temp_id'];
    isJangana = json['is_jangana'];
    saraswaniOptionId = json['saraswani_option_id'];
    createdBy = json['created_by'];
    createdAt = json['created_at'];
    updatedBy = json['updated_by'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['member_id'] = this.memberId;
    data['member_code'] = this.memberCode;
    data['member_salutaiton_id'] = this.memberSalutaitonId;
    data['first_name'] = this.firstName;
    data['middle_name'] = this.middleName;
    data['last_name'] = this.lastName;
    data['mobile'] = this.mobile;
    data['whatsapp_number'] = this.whatsappNumber;
    data['email'] = this.email;
    data['password'] = this.password;
    data['dob'] = this.dob;
    data['proposer_id'] = this.proposerId;
    data['marital_status_id'] = this.maritalStatusId;
    data['marriage_anniversary_date'] = this.marriageAnniversaryDate;
    data['gender_id'] = this.genderId;
    data['blood_group_id'] = this.bloodGroupId;
    data['father_name'] = this.fatherName;
    data['mother_name'] = this.motherName;
    data['address_proof_type_id'] = this.addressProofTypeId;
    data['address_proof'] = this.addressProof;
    data['profile_image'] = this.profileImage;
    data['otp'] = this.otp;
    data['verify_otp_status'] = this.verifyOtpStatus;
    data['mobile_verify_status'] = this.mobileVerifyStatus;
    data['sangathan_approval_status'] = this.sangathanApprovalStatus;
    data['vyavasthapika_approval_status'] = this.vyavasthapikaApprovalStatus;
    data['member_status_id'] = this.memberStatusId;
    data['membership_approval_status_id'] = this.membershipApprovalStatusId;
    data['membership_type_id'] = this.membershipTypeId;
    data['family_head_member_id'] = this.familyHeadMemberId;
    data['temp_id'] = this.tempId;
    data['is_jangana'] = this.isJangana;
    data['saraswani_option_id'] = this.saraswaniOptionId;
    data['created_by'] = this.createdBy;
    data['created_at'] = this.createdAt;
    data['updated_by'] = this.updatedBy;
    data['updated_at'] = this.updatedAt;
    return data;
  }
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CheckUserData2 && runtimeType == other.runtimeType && memberId == other.memberId;

  @override
  int get hashCode => memberId.hashCode;
}



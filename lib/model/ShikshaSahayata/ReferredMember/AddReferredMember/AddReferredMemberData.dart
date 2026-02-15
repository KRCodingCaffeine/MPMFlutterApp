class AddReferredMemberData {
  String? shikshaApplicantReferredMemberId;
  String? shikshaApplicantId;
  String? referedMemberName;
  String? referedMemberAddress;
  String? referedMemberMobile;
  String? referedMemberEmail;
  String? referedMemberMemberCode;
  String? createdBy;

  AddReferredMemberData({
    this.shikshaApplicantReferredMemberId,
    this.shikshaApplicantId,
    this.referedMemberName,
    this.referedMemberAddress,
    this.referedMemberMobile,
    this.referedMemberEmail,
    this.referedMemberMemberCode,
    this.createdBy,
  });

  AddReferredMemberData.fromJson(Map<String, dynamic> json) {
    shikshaApplicantReferredMemberId =
        json['shiksha_applicant_referred_member_id']?.toString();
    shikshaApplicantId =
        json['shiksha_applicant_id']?.toString();
    referedMemberName =
        json['refered_member_name']?.toString();
    referedMemberAddress =
        json['refered_member_address']?.toString();
    referedMemberMobile =
        json['refered_member_mobile']?.toString();
    referedMemberEmail =
        json['refered_member_email']?.toString();
    referedMemberMemberCode =
        json['refered_member_member_code']?.toString();
    createdBy =
        json['created_by']?.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      "shiksha_applicant_id": shikshaApplicantId,
      "refered_member_name": referedMemberName,
      "refered_member_address": referedMemberAddress,
      "refered_member_mobile": referedMemberMobile,
      "refered_member_email": referedMemberEmail,
      "refered_member_member_code": referedMemberMemberCode,
      "created_by": createdBy,
    };
  }
}

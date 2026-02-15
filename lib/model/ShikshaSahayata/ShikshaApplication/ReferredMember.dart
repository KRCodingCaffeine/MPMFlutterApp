class ReferredMember {
  final String? shikshaApplicantReferredMemberId;
  final String? shikshaApplicantId;
  final String? referedMemberName;
  final String? referedMemberAddress;
  final String? referedMemberMobile;
  final String? referedMemberEmail;
  final String? referedMemberMemberCode;
  final String? referedMemberMemberAadharCardDocument;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;

  ReferredMember({
    this.shikshaApplicantReferredMemberId,
    this.shikshaApplicantId,
    this.referedMemberName,
    this.referedMemberAddress,
    this.referedMemberMobile,
    this.referedMemberEmail,
    this.referedMemberMemberCode,
    this.referedMemberMemberAadharCardDocument,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  factory ReferredMember.fromJson(Map<String, dynamic> json) {
    return ReferredMember(
      shikshaApplicantReferredMemberId:
      json['shiksha_applicant_referred_member_id']?.toString(),
      shikshaApplicantId:
      json['shiksha_applicant_id']?.toString(),
      referedMemberName:
      json['refered_member_name']?.toString(),
      referedMemberAddress:
      json['refered_member_address']?.toString(),
      referedMemberMobile:
      json['refered_member_mobile']?.toString(),
      referedMemberEmail:
      json['refered_member_email']?.toString(),
      referedMemberMemberCode:
      json['refered_member_member_code']?.toString(),
      referedMemberMemberAadharCardDocument:
      json['refered_member_member_aadhar_card_document']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiksha_applicant_referred_member_id':
      shikshaApplicantReferredMemberId,
      'shiksha_applicant_id': shikshaApplicantId,
      'refered_member_name': referedMemberName,
      'refered_member_address': referedMemberAddress,
      'refered_member_mobile': referedMemberMobile,
      'refered_member_email': referedMemberEmail,
      'refered_member_member_code': referedMemberMemberCode,
      'refered_member_member_aadhar_card_document':
      referedMemberMemberAadharCardDocument,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
    };
  }
}

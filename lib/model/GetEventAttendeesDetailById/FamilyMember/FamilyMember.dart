class FamilyMember {
  final String? eventAttendeesFamilyMappingId;
  final String? eventAttendeesId;
  final String? memberId;
  final String? familyMemberId;
  final String? createdBy;
  final String? createdAt;
  final String? updatedBy;
  final String? updatedAt;
  final String? memberCode;
  final String? fullName;
  final String? email;
  final String? mobile;

  FamilyMember({
    this.eventAttendeesFamilyMappingId,
    this.eventAttendeesId,
    this.memberId,
    this.familyMemberId,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.memberCode,
    this.fullName,
    this.email,
    this.mobile,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      eventAttendeesFamilyMappingId:
      json['event_attendees_family_mapping_id'] as String?,
      eventAttendeesId: json['event_attendees_id'] as String?,
      memberId: json['member_id'] as String?,
      familyMemberId: json['family_member_id'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String?,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] as String?,
      memberCode: json['member_code'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_family_mapping_id':
    eventAttendeesFamilyMappingId,
    'event_attendees_id': eventAttendeesId,
    'member_id': memberId,
    'family_member_id': familyMemberId,
    'created_by': createdBy,
    'created_at': createdAt,
    'updated_by': updatedBy,
    'updated_at': updatedAt,
    'member_code': memberCode,
    'full_name': fullName,
    'email': email,
    'mobile': mobile,
  };
}
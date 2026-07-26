class DetailSanyojakData {
  String? memberId;
  String? memberFirstName;
  String? memberLastName;
  String? memberMobile;
  String? memberEmail;
  String? organizerSamitiId;
  String? organizerSamitiSubCategoryName;
  String? samitiName;
  String? vitranOrganizerSamitiId;

  DetailSanyojakData({
    this.memberId,
    this.memberFirstName,
    this.memberLastName,
    this.memberMobile,
    this.memberEmail,
    this.organizerSamitiId,
    this.organizerSamitiSubCategoryName,
    this.samitiName,
    this.vitranOrganizerSamitiId,
  });

  factory DetailSanyojakData.fromJson(Map<String, dynamic> json) {
    return DetailSanyojakData(
      memberId: json['member_id']?.toString(),
      memberFirstName: json['member_first_name'],
      memberLastName: json['member_last_name'],
      memberMobile: json['member_mobile'],
      memberEmail: json['member_email'],
      organizerSamitiId: json['organizer_samiti_id']?.toString(),
      organizerSamitiSubCategoryName: json['organizer_samiti_sub_category_name'],
      samitiName: json['samiti_name'],
      vitranOrganizerSamitiId: json['vitran_organizer_samiti_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'member_first_name': memberFirstName,
      'member_last_name': memberLastName,
      'member_mobile': memberMobile,
      'member_email': memberEmail,
      'organizer_samiti_id': organizerSamitiId,
      'organizer_samiti_sub_category_name': organizerSamitiSubCategoryName,
      'samiti_name': samitiName,
      'vitran_organizer_samiti_id': vitranOrganizerSamitiId,
    };
  }
}
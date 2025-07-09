class UpdateEventByMemberData {
  String? confirmationStatus;
  String? updatedBy;
  String? dateUpdated;

  UpdateEventByMemberData({
    this.confirmationStatus,
    this.updatedBy,
    this.dateUpdated,
  });

  factory UpdateEventByMemberData.fromJson(Map<String, dynamic> json) {
    return UpdateEventByMemberData(
      confirmationStatus: json['confirmation_status'],
      updatedBy: json['member_id'],
      dateUpdated: json['date_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmation_status': confirmationStatus,
      'member_id': updatedBy,
      'date_updated': dateUpdated,
    };
  }
}

class CancelTripRegistrationData {
  String? tripRegisteredMemberId;
  String? deletedOn;

  CancelTripRegistrationData({
    this.tripRegisteredMemberId,
    this.deletedOn,
  });

  factory CancelTripRegistrationData.fromJson(Map<String, dynamic> json) {
    return CancelTripRegistrationData(
      tripRegisteredMemberId: json['trip_registered_member_id']?.toString(),
      deletedOn: json['deleted_on']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trip_registered_member_id': tripRegisteredMemberId,
      'deleted_on': deletedOn,
    };
  }
}

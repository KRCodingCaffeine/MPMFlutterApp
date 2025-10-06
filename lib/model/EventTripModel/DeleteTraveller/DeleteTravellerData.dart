class DeleteTravellerData {
  final String? tripTravellerId;
  final String? travellerName;
  final String? tripRegisteredMemberId;

  DeleteTravellerData({
    this.tripTravellerId,
    this.travellerName,
    this.tripRegisteredMemberId,
  });

  factory DeleteTravellerData.fromJson(Map<String, dynamic> json) {
    return DeleteTravellerData(
      tripTravellerId: json['trip_traveller_id']?.toString(),
      travellerName: json['traveller_name']?.toString(),
      tripRegisteredMemberId: json['trip_registered_member_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trip_traveller_id': tripTravellerId,
    'traveller_name': travellerName,
    'trip_registered_member_id': tripRegisteredMemberId,
  };
}

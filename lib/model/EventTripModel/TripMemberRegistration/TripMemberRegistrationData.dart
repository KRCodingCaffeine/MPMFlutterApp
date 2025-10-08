class TripMemberRegistrationData {
  String? memberId;
  String? tripId;
  String? addedBy;
  List<String>? travellerNames;

  TripMemberRegistrationData({
    this.memberId,
    this.tripId,
    this.addedBy,
    this.travellerNames,
  });

  factory TripMemberRegistrationData.fromJson(Map<String, dynamic> json) {
    return TripMemberRegistrationData(
      memberId: json['member_id']?.toString(),
      tripId: json['trip_id']?.toString(),
      addedBy: json['added_by']?.toString(),
      travellerNames: json['traveller_names'] != null
          ? List<String>.from(
          (json['traveller_names'] as List).map((e) => e.toString()))
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_id'] = memberId;
    data['trip_id'] = tripId;
    data['added_by'] = addedBy;
    if (travellerNames != null) {
      data['traveller_names'] = travellerNames;
    }
    return data;
  }
}

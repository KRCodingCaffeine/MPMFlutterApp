class AddTravellerData {
  String? travellerId;
  String? travellerName;
  String? tripRegisteredMemberId;
  String? addedBy;

  AddTravellerData({
    this.travellerId,
    this.travellerName,
    this.tripRegisteredMemberId,
    this.addedBy,
  });

  factory AddTravellerData.fromJson(Map<String, dynamic> json) {
    return AddTravellerData(
      travellerId: json['traveller_id']?.toString(),
      travellerName: json['traveller_name']?.toString(),
      tripRegisteredMemberId: json['trip_registered_member_id']?.toString(),
      addedBy: json['added_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> dataMap = {};
    dataMap['traveller_id'] = travellerId;
    dataMap['traveller_name'] = travellerName;
    dataMap['trip_registered_member_id'] = tripRegisteredMemberId;
    dataMap['added_by'] = addedBy;
    return dataMap;
  }
}
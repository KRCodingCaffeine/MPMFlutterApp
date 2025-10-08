class UpdateTravellerData {
  final int? tripTravellerId;
  final String? travellerName;
  final int? updatedBy;

  UpdateTravellerData({
    this.tripTravellerId,
    this.travellerName,
    this.updatedBy,
  });

  factory UpdateTravellerData.fromJson(Map<String, dynamic> json) {
    return UpdateTravellerData(
      tripTravellerId: _parseInt(json['trip_traveller_id']),
      travellerName: json['traveller_name']?.toString(),
      updatedBy: _parseInt(json['updated_by']),
    );
  }

  Map<String, dynamic> toJson() => {
    'trip_traveller_id': tripTravellerId,
    'traveller_name': travellerName,
    'updated_by': updatedBy,
  };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return int.tryParse(value.toString());
  }
}

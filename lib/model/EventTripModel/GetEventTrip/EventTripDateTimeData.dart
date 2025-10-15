class EventTripDateTimeData {
  String? tripDateTimeId;
  String? tripId;
  String? tripDate;
  String? tripStartTime;
  String? tripEndTime;
  String? createdBy;
  String? dateAdded;
  String? updatedBy;
  String? dateUpdated;

  EventTripDateTimeData({
    this.tripDateTimeId,
    this.tripId,
    this.tripDate,
    this.tripStartTime,
    this.tripEndTime,
    this.createdBy,
    this.dateAdded,
    this.updatedBy,
    this.dateUpdated,
  });

  factory EventTripDateTimeData.fromJson(Map<String, dynamic> json) {
    return EventTripDateTimeData(
      tripDateTimeId: json['trip_date_time_id']?.toString(),
      tripId: json['trip_id']?.toString(),
      tripDate: json['trip_date'],
      tripStartTime: json['trip_start_time'],
      tripEndTime: json['trip_end_time'],
      createdBy: json['created_by']?.toString(),
      dateAdded: json['date_added'],
      updatedBy: json['updated_by']?.toString(),
      dateUpdated: json['date_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events_date_time_id': tripDateTimeId,
      'trip_id': tripId,
      'trip_date': tripDate,
      'trip_start_time': tripStartTime,
      'trip_end_time': tripEndTime,
      'created_by': createdBy,
      'date_added': dateAdded,
      'updated_by': updatedBy,
      'date_updated': dateUpdated,
    };
  }
}

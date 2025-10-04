class EventDateTimeData {
  String? eventsDateTimeId;
  String? eventId;
  String? eventDate;
  String? eventStartTime;
  String? eventEndTime;
  String? createdBy;
  String? dateAdded;
  String? updatedBy;
  String? dateUpdated;

  EventDateTimeData({
    this.eventsDateTimeId,
    this.eventId,
    this.eventDate,
    this.eventStartTime,
    this.eventEndTime,
    this.createdBy,
    this.dateAdded,
    this.updatedBy,
    this.dateUpdated,
  });

  factory EventDateTimeData.fromJson(Map<String, dynamic> json) {
    return EventDateTimeData(
      eventsDateTimeId: json['events_date_time_id']?.toString(),
      eventId: json['event_id']?.toString(),
      eventDate: json['event_date'],
      eventStartTime: json['event_start_time'],
      eventEndTime: json['event_end_time'],
      createdBy: json['created_by']?.toString(),
      dateAdded: json['date_added'],
      updatedBy: json['updated_by']?.toString(),
      dateUpdated: json['date_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'events_date_time_id': eventsDateTimeId,
      'event_id': eventId,
      'event_date': eventDate,
      'event_start_time': eventStartTime,
      'event_end_time': eventEndTime,
      'created_by': createdBy,
      'date_added': dateAdded,
      'updated_by': updatedBy,
      'date_updated': dateUpdated,
    };
  }
}

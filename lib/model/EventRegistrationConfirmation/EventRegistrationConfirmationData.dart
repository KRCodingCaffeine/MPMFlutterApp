class EventRegistrationConfirmationData {
  String? attendeeId;
  List<dynamic>? allocatedSeats;

  EventRegistrationConfirmationData({
    this.attendeeId,
    this.allocatedSeats,
  });

  factory EventRegistrationConfirmationData.fromJson(
      Map<String, dynamic> json) {
    return EventRegistrationConfirmationData(
      attendeeId: json['attendee_id']?.toString(),
      allocatedSeats: json['allocated_seats'] != null
          ? List<dynamic>.from(json['allocated_seats'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendee_id': attendeeId,
      'allocated_seats': allocatedSeats,
    };
  }
}
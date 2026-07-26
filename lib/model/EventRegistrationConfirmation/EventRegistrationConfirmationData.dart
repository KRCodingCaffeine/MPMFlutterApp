class EventRegistrationConfirmationData {
  String? attendeeId;
  String? confirmationStatus;
  List<dynamic>? allocatedSeats;

  EventRegistrationConfirmationData({
    this.attendeeId,
    this.confirmationStatus,
    this.allocatedSeats,
  });

  factory EventRegistrationConfirmationData.fromJson(
      Map<String, dynamic> json) {
    return EventRegistrationConfirmationData(
      attendeeId: json['attendee_id']?.toString(),
      confirmationStatus: json['confirmation_status']?.toString(),
      allocatedSeats: json['allocated_seats'] != null
          ? List<dynamic>.from(json['allocated_seats'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'attendee_id': attendeeId,
      'confirmation_status': confirmationStatus,
      'allocated_seats': allocatedSeats,
    };
  }
}
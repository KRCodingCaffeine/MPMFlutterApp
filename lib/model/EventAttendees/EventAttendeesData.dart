class EventAttendeesData {
  String? eventAttendeesId;
  String? memberId;
  String? eventAttendeesCode;
  String? eventRegisteredData;
  String? confirmationStatus;
  String? eventQrCode;
  String? eventCancelledOn;
  String? hasAttendEvent;
  String? hasPaidForFood;
  String? hasReceivedFood;
  String? noOfFoodContainer;
  String? noOfSeatsAllocated;
  String? registrationDate;
  String? firstName;
  String? middleName;
  String? lastName;
  String? mobile;
  String? email;
  String? memberFullName;

  EventAttendeesData({
    this.eventAttendeesId,
    this.memberId,
    this.eventAttendeesCode,
    this.eventRegisteredData,
    this.confirmationStatus,
    this.eventQrCode,
    this.eventCancelledOn,
    this.hasAttendEvent,
    this.hasPaidForFood,
    this.hasReceivedFood,
    this.noOfFoodContainer,
    this.noOfSeatsAllocated,
    this.registrationDate,
    this.firstName,
    this.middleName,
    this.lastName,
    this.mobile,
    this.email,
    this.memberFullName,
  });

  factory EventAttendeesData.fromJson(Map<String, dynamic> json) {
    return EventAttendeesData(
      eventAttendeesId: json['event_attendees_id']?.toString(),
      memberId: json['member_id']?.toString(),
      eventAttendeesCode: json['event_attendees_code'],
      eventRegisteredData: json['event_registered_data'],
      confirmationStatus: json['confirmation_status'],
      eventQrCode: json['event_qr_code'],
      eventCancelledOn: json['event_cancelled_on'],
      hasAttendEvent: json['has_attend_event']?.toString(),
      hasPaidForFood: json['has_paid_for_food']?.toString(),
      hasReceivedFood: json['has_received_food']?.toString(),
      noOfFoodContainer: json['no_of_food_container']?.toString(),
      noOfSeatsAllocated: json['no_of_seats_allocated']?.toString(),
      registrationDate: json['registration_date'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      mobile: json['mobile'],
      email: json['email'],
      memberFullName: json['member_full_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_attendees_id': eventAttendeesId,
      'member_id': memberId,
      'event_attendees_code': eventAttendeesCode,
      'event_registered_data': eventRegisteredData,
      'confirmation_status': confirmationStatus,
      'event_qr_code': eventQrCode,
      'event_cancelled_on': eventCancelledOn,
      'has_attend_event': hasAttendEvent,
      'has_paid_for_food': hasPaidForFood,
      'has_received_food': hasReceivedFood,
      'no_of_food_container': noOfFoodContainer,
      'no_of_seats_allocated': noOfSeatsAllocated,
      'registration_date': registrationDate,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'email': email,
      'member_full_name': memberFullName,
    };
  }
}
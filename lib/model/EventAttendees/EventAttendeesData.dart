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
  String? memberCode;
  String? email;
  String? memberFullName;
  String? eventId;
  String? eventName;
  String? eventDescription;
  String? eventOrganiserName;
  String? eventOrganiserMobile;
  String? dateStartsFrom;
  String? dateEndTo;
  String? eventImage;
  String? eventCostType;
  String? eventAmount;
  String? eventRegistrationLastDate;
  String? approvalStatus;
  String? eventsTypeId;
  String? hasFood;
  String? hasSeatAllocate;
  String? noOfFamilyMemberAllowed;

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
    this.memberCode,
    this.eventId,
    this.eventName,
    this.eventDescription,
    this.eventOrganiserName,
    this.eventOrganiserMobile,
    this.dateStartsFrom,
    this.dateEndTo,
    this.eventImage,
    this.eventCostType,
    this.eventAmount,
    this.eventRegistrationLastDate,
    this.approvalStatus,
    this.eventsTypeId,
    this.hasFood,
    this.hasSeatAllocate,
    this.noOfFamilyMemberAllowed,
  });

  factory EventAttendeesData.fromJson(Map<String, dynamic> json) {
    return EventAttendeesData(
      eventAttendeesId: json['event_attendees_id']?.toString(),
      memberId: json['member_id']?.toString(),
      eventAttendeesCode: json['event_attendees_code']?.toString(),
      eventRegisteredData: json['event_registered_data']?.toString(),
      confirmationStatus: json['confirmation_status']?.toString(),
      eventQrCode: json['event_qr_code']?.toString(),
      eventCancelledOn: json['event_cancelled_on']?.toString(),
      hasAttendEvent: json['has_attend_event']?.toString(),
      hasPaidForFood: json['has_paid_for_food']?.toString(),
      hasReceivedFood: json['has_received_food']?.toString(),
      noOfFoodContainer: json['no_of_food_container']?.toString(),
      noOfSeatsAllocated: json['no_of_seats_allocated']?.toString(),
      registrationDate: json['registration_date']?.toString(),
      firstName: json['first_name']?.toString(),
      middleName: json['middle_name']?.toString(),
      lastName: json['last_name']?.toString(),
      mobile: json['mobile']?.toString(),
      email: json['email']?.toString(),
      memberFullName: json['member_full_name']?.toString(),
      memberCode: json['member_code']?.toString(),
      eventId: json['event_id']?.toString(),
      eventName: json['event_name']?.toString(),
      eventDescription: json['event_description']?.toString(),
      eventOrganiserName: json['event_organiser_name']?.toString(),
      eventOrganiserMobile: json['event_organiser_mobile']?.toString(),
      dateStartsFrom: json['date_starts_from']?.toString(),
      dateEndTo: json['date_end_to']?.toString(),
      eventImage: json['event_image']?.toString(),
      eventCostType: json['event_cost_type']?.toString(),
      eventAmount: json['event_amount']?.toString(),
      eventRegistrationLastDate:
          json['event_registration_last_date']?.toString(),
      approvalStatus: json['approval_status']?.toString(),
      eventsTypeId: json['events_type_id']?.toString(),
      hasFood: json['has_food']?.toString(),
      hasSeatAllocate: json['has_seat_allocate']?.toString(),
      noOfFamilyMemberAllowed: json['no_of_family_member_allowed']?.toString(),
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
      'member_code': memberCode,
      'event_id': eventId,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_organiser_name': eventOrganiserName,
      'event_organiser_mobile': eventOrganiserMobile,
      'date_starts_from': dateStartsFrom,
      'date_end_to': dateEndTo,
      'event_image': eventImage,
      'event_cost_type': eventCostType,
      'event_amount': eventAmount,
      'event_registration_last_date': eventRegistrationLastDate,
      'approval_status': approvalStatus,
      'events_type_id': eventsTypeId,
      'has_food': hasFood,
      'has_seat_allocate': hasSeatAllocate,
      'no_of_family_member_allowed': noOfFamilyMemberAllowed,
    };
  }
}

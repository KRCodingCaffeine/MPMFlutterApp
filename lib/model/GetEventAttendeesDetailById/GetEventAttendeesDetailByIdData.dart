import 'package:mpm/model/GetEventsList/GetEventsListData.dart';

class GetEventAttendeesDetailByIdData {
  final String? eventAttendeesId;
  final String? memberId;
  final String? eventAttendeesCode;
  final String? eventRegisteredData;
  final String? registrationDate;
  String? cancelledDate;
  final String? eventQrCode;
  final String? noOfFoodContainer;
  final EventData? event;
  PriceMember? priceMember;
  final SeatAllotment? seatAllotment;

  GetEventAttendeesDetailByIdData({
    this.eventAttendeesId,
    this.memberId,
    this.eventAttendeesCode,
    this.eventRegisteredData,
    this.registrationDate,
    this.cancelledDate,
    this.eventQrCode,
    this.noOfFoodContainer,
    this.event,
    this.priceMember,
    this.seatAllotment,
  });

  factory GetEventAttendeesDetailByIdData.fromJson(Map<String, dynamic> json) {
    return GetEventAttendeesDetailByIdData(
      eventAttendeesId: json['event_attendees_id'] as String?,
      memberId: json['member_id'] as String?,
      eventAttendeesCode: json['event_attendees_code'] as String?,
      eventRegisteredData: json['event_registered_data'] as String?,
      registrationDate: json['registration_date'] as String?,
      cancelledDate: json['cancelled_date'] as String?,
      eventQrCode: json['event_qr_code'] as String?,
      noOfFoodContainer: json['no_of_food_container'] as String?,
      event: json['event'] != null ? EventData.fromJson(json['event']) : null,
      priceMember: json['price_member'] != null
          ? PriceMember.fromJson(json['price_member'])
          : null,
      seatAllotment: json['seat_allotment'] != null
          ? SeatAllotment.fromJson(json['seat_allotment'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_id': eventAttendeesId,
    'member_id': memberId,
    'event_attendees_code': eventAttendeesCode,
    'event_registered_data': eventRegisteredData,
    'registration_date': registrationDate,
    'cancelled_date': cancelledDate,
    'event_qr_code': eventQrCode,
    'no_of_food_container': noOfFoodContainer,
    'event': event?.toJson(),
    'price_member': priceMember?.toJson(),
    'seat_allotment': seatAllotment?.toJson(),
  };
}

class EventData {
  final String? eventId;
  final String? eventName;
  final String? eventDescription;
  final String? eventOrganiserName;
  final String? eventOrganiserMobile;
  final String? dateStartsFrom;
  final String? dateEndTo;
  final String? eventImage;
  final String? eventTermsAndConditionDocument;
  final String? eventCostType;
  final String? eventAmount;
  final String? eventRegistrationLastDate;
  final String? approvalStatus;
  final String? eventsTypeId;
  final String? hasFood;
  final String? hasSeatAllocate;

  EventData({
    this.eventId,
    this.eventName,
    this.eventDescription,
    this.eventOrganiserName,
    this.eventOrganiserMobile,
    this.dateStartsFrom,
    this.dateEndTo,
    this.eventImage,
    this.eventTermsAndConditionDocument,
    this.eventCostType,
    this.eventAmount,
    this.eventRegistrationLastDate,
    this.approvalStatus,
    this.eventsTypeId,
    this.hasFood,
    this.hasSeatAllocate,
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventId: json['event_id'] as String?,
      eventName: json['event_name'] as String?,
      eventDescription: json['event_description'] as String?,
      eventOrganiserName: json['event_organiser_name'] as String?,
      eventOrganiserMobile: json['event_organiser_mobile'] as String?,
      dateStartsFrom: json['date_starts_from'] as String?,
      dateEndTo: json['date_end_to'] as String?,
      eventImage: json['event_image'] as String?,
      eventTermsAndConditionDocument:
      json['event_terms_and_condition_document'] as String?,
      eventCostType: json['event_cost_type'] as String?,
      eventAmount: json['event_amount'] as String?,
      eventRegistrationLastDate: json['event_registration_last_date'] as String?,
      approvalStatus: json['approval_status'] as String?,
      eventsTypeId: json['events_type_id'] as String?,
      hasFood: json['has_food'] as String?,
      hasSeatAllocate: json['has_seat_allocate'] as String?
    );
  }

  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'event_name': eventName,
    'event_description': eventDescription,
    'event_organiser_name': eventOrganiserName,
    'event_organiser_mobile': eventOrganiserMobile,
    'date_starts_from': dateStartsFrom,
    'date_end_to': dateEndTo,
    'event_image': eventImage,
    'event_terms_and_condition_document': eventTermsAndConditionDocument,
    'event_cost_type': eventCostType,
    'event_amount': eventAmount,
    'event_registration_last_date': eventRegistrationLastDate,
    'approval_status': approvalStatus,
    'events_type_id': eventsTypeId,
    'has_food': hasFood,
    'has_seat_allocate': hasSeatAllocate,
  };
}

class PriceMember {
  final String? eventAttendeesPriceMemberId;
  final String? priceMemberId;
  final String? studentName;
  final String? schoolName;
  final String? standardPassed;
  final String? yearOfPassed;
  final String? grade;
  final String? markSheetAttachment;

  PriceMember({
    this.eventAttendeesPriceMemberId,
    this.priceMemberId,
    this.studentName,
    this.schoolName,
    this.standardPassed,
    this.yearOfPassed,
    this.grade,
    this.markSheetAttachment,
  });

  factory PriceMember.fromJson(Map<String, dynamic> json) {
    return PriceMember(
      eventAttendeesPriceMemberId:
      json['event_attendees_price_member_id'] as String?,
      priceMemberId: json['price_member_id'] as String?,
      studentName: json['student_name'] as String?,
      schoolName: json['school_name'] as String?,
      standardPassed: json['standard_passed'] as String?,
      yearOfPassed: json['year_of_passed'] as String?,
      grade: json['grade'] as String?,
      markSheetAttachment: json['mark_sheet_attachment'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_price_member_id': eventAttendeesPriceMemberId,
    'price_member_id': priceMemberId,
    'student_name': studentName,
    'school_name': schoolName,
    'standard_passed': standardPassed,
    'year_of_passed': yearOfPassed,
    'grade': grade,
    'mark_sheet_attachment': markSheetAttachment,
  };
}

class SeatAllotment {
  final String? eventSeatAllotmentId;
  final String? seatNo;
  final String? isReserved;
  final String? reservedBy;
  final String? dateReserved;

  SeatAllotment({
    this.eventSeatAllotmentId,
    this.seatNo,
    this.isReserved,
    this.reservedBy,
    this.dateReserved,
  });

  factory SeatAllotment.fromJson(Map<String, dynamic> json) {
    return SeatAllotment(
      eventSeatAllotmentId: json['event_seat_allotment_id'] as String?,
      seatNo: json['seat_no'] as String?,
      isReserved: json['is_reserved'] as String?,
      reservedBy: json['reserved_by'] as String?,
      dateReserved: json['date_reserved'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'event_seat_allotment_id': eventSeatAllotmentId,
    'seat_no': seatNo,
    'is_reserved': isReserved,
    'reserved_by': reservedBy,
    'date_reserved': dateReserved,
  };
}
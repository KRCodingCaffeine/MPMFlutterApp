import 'package:mpm/utils/urls.dart';

class EventAttendeeData {
  int? eventAttendeesId;
  String? eventAttendeesCode;
  String? eventRegisteredData;
  String? registrationDate;
  String? cancelledDate;
  int? eventId;
  String? eventName;
  String? eventDescription;
  String? eventOrganiserName;
  String? eventOrganiserMobile;
  String? dateStartsFrom;
  String? dateEndTo;
  String? eventImage;
  String? eventTermsAndConditionDocument;
  String? eventCostType;
  int? eventAmount;
  String? eventRegistrationLastDate;
  String? approvalStatus;
  int? eventsTypeId;

  EventAttendeeData({
    this.eventAttendeesId,
    this.eventAttendeesCode,
    this.eventRegisteredData,
    this.registrationDate,
    this.cancelledDate,
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
  });

  factory EventAttendeeData.fromJson(Map<String, dynamic> json) {
    return EventAttendeeData(
      eventAttendeesId: _toInt(json['event_attendees_id']),
      eventAttendeesCode: json['event_attendees_code'],
      eventRegisteredData: json['event_registered_data'],
      registrationDate: json['registration_date'],
      cancelledDate: json['cancelled_date'],
      eventId: _toInt(json['event_id']),
      eventName: json['event_name'],
      eventDescription: json['event_description'],
      eventOrganiserName: json['event_organiser_name'],
      eventOrganiserMobile: json['event_organiser_mobile'],
      dateStartsFrom: json['date_starts_from'],
      dateEndTo: json['date_end_to'],
      eventImage: json['event_image']?.isNotEmpty == true
          ? Urls.imagePathUrl + json['event_image']
          : null,
      eventTermsAndConditionDocument:
      json['event_terms_and_condition_document']?.isNotEmpty == true
          ? Urls.imagePathUrl + json['event_terms_and_condition_document']
          : null,
      eventCostType: json['event_cost_type'],
      eventAmount: _toInt(json['event_amount']),
      eventRegistrationLastDate: json['event_registration_last_date'],
      approvalStatus: json['approval_status'],
      eventsTypeId: _toInt(json['events_type_id']),
    );
  }

  Map<String, dynamic> toJson() => {
    'event_attendees_id': eventAttendeesId,
    'event_attendees_code': eventAttendeesCode,
    'event_registered_data': eventRegisteredData,
    'registration_date': registrationDate,
    'cancelled_date': cancelledDate,
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
  };

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

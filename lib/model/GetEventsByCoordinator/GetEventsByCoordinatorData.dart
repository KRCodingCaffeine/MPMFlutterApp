import 'package:mpm/utils/urls.dart';

class GetEventsByCoordinatorData {
  String? eventId;
  String? eventName;
  String? eventDescription;
  String? eventOrganiserName;
  String? eventOrganiserMobile;
  String? dateStartsFrom;
  String? dateEndTo;
  String? timeStartsFrom;
  String? timeEndTo;
  String? eventImage;
  String? eventTermsAndConditionDocument;
  String? approvalStatus;
  String? approvedBy;
  String? approvedDate;
  String? eventCostType;
  String? eventAmount;
  String? eventUpiCode;
  String? eventAmountQrCode;
  String? eventRegistrationLastDate;
  String? isRegistrationVisible;
  String? eventsTypeId;
  String? hasFood;
  String? hasFoodPaid;
  String? eventFoodAmount;
  String? hasSeatAllocate;
  String? hasGatepassEntry;
  String? noOfFamilyMemberAllowed;

  GetEventsByCoordinatorData({
    this.eventId,
    this.eventName,
    this.eventDescription,
    this.eventOrganiserName,
    this.eventOrganiserMobile,
    this.dateStartsFrom,
    this.dateEndTo,
    this.timeStartsFrom,
    this.timeEndTo,
    this.eventImage,
    this.eventTermsAndConditionDocument,
    this.approvalStatus,
    this.approvedBy,
    this.approvedDate,
    this.eventCostType,
    this.eventAmount,
    this.eventUpiCode,
    this.eventAmountQrCode,
    this.eventRegistrationLastDate,
    this.isRegistrationVisible,
    this.eventsTypeId,
    this.hasFood,
    this.hasFoodPaid,
    this.eventFoodAmount,
    this.hasSeatAllocate,
    this.hasGatepassEntry,
    this.noOfFamilyMemberAllowed,
  });

  factory GetEventsByCoordinatorData.fromJson(Map<String, dynamic> json) {
    return GetEventsByCoordinatorData(
      eventId: json['event_id']?.toString(),
      eventName: json['event_name']?.toString(),
      eventDescription: json['event_description']?.toString(),
      eventOrganiserName: json['event_organiser_name']?.toString(),
      eventOrganiserMobile: json['event_organiser_mobile']?.toString(),
      dateStartsFrom: json['date_starts_from']?.toString(),
      dateEndTo: json['date_end_to']?.toString(),
      timeStartsFrom: json['time_starts_from']?.toString(),
      timeEndTo: json['time_end_to']?.toString(),
      eventImage: json['event_image'] != null
          ? Urls.imagePathUrl + json['event_image']
          : null,
      eventTermsAndConditionDocument:
      json['event_terms_and_condition_document'] != null
          ? Urls.imagePathUrl +
          json['event_terms_and_condition_document']
          : null,
      approvalStatus: json['approval_status']?.toString(),
      approvedBy: json['approved_by']?.toString(),
      approvedDate: json['approved_date']?.toString(),
      eventCostType: json['event_cost_type']?.toString(),
      eventAmount: json['event_amount']?.toString(),
      eventUpiCode: json['event_upi_code']?.toString(),
      eventAmountQrCode: json['event_amount_qr_code'] != null
          ? Urls.imagePathUrl + json['event_amount_qr_code']
          : null,
      eventRegistrationLastDate:
      json['event_registration_last_date']?.toString(),
      isRegistrationVisible:
      json['is_registration_visible']?.toString(),
      eventsTypeId: json['events_type_id']?.toString(),
      hasFood: json['has_food']?.toString(),
      hasFoodPaid: json['has_food_paid']?.toString(),
      eventFoodAmount: json['event_food_amount']?.toString(),
      hasSeatAllocate: json['has_seat_allocate']?.toString(),
      hasGatepassEntry: json['has_gatepass_entry']?.toString(),
      noOfFamilyMemberAllowed:
      json['no_of_family_member_allowed']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'event_name': eventName,
      'event_description': eventDescription,
      'event_organiser_name': eventOrganiserName,
      'event_organiser_mobile': eventOrganiserMobile,
      'date_starts_from': dateStartsFrom,
      'date_end_to': dateEndTo,
      'time_starts_from': timeStartsFrom,
      'time_end_to': timeEndTo,
      'event_image': eventImage,
      'event_terms_and_condition_document':
      eventTermsAndConditionDocument,
      'approval_status': approvalStatus,
      'approved_by': approvedBy,
      'approved_date': approvedDate,
      'event_cost_type': eventCostType,
      'event_amount': eventAmount,
      'event_upi_code': eventUpiCode,
      'event_amount_qr_code': eventAmountQrCode,
      'event_registration_last_date':
      eventRegistrationLastDate,
      'is_registration_visible': isRegistrationVisible,
      'events_type_id': eventsTypeId,
      'has_food': hasFood,
      'has_food_paid': hasFoodPaid,
      'event_food_amount': eventFoodAmount,
      'has_seat_allocate': hasSeatAllocate,
      'has_gatepass_entry': hasGatepassEntry,
      'no_of_family_member_allowed':
      noOfFamilyMemberAllowed,
    };
  }
}
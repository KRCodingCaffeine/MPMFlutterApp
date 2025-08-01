import 'package:mpm/model/GetEventsList/EventDateTimeData.dart';
import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/utils/urls.dart';

class GetEventDetailsByIdData {
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
  String? eventRegistrationLastDate;
  String? eventsTypeId;
  String? isAllZone;
  String? youtubeUrl;
  String? addedBy;
  String? dateAdded;
  String? updatedBy;
  String? dateUpdated;
  List<ZoneData>? zones;
  List<EventDateTimeData>? allEventDates;

  GetEventDetailsByIdData({
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
    this.eventRegistrationLastDate,
    this.eventsTypeId,
    this.isAllZone,
    this.youtubeUrl,
    this.addedBy,
    this.dateAdded,
    this.updatedBy,
    this.dateUpdated,
    this.zones,
    this.allEventDates,
  });

  factory GetEventDetailsByIdData.fromJson(Map<String, dynamic> json) {
    return GetEventDetailsByIdData(
      eventId: json['event_id']?.toString(),
      eventName: json['event_name'],
      eventDescription: json['event_description'],
      eventOrganiserName: json['event_organiser_name'],
      eventOrganiserMobile: json['event_organiser_mobile'],
      dateStartsFrom: json['date_starts_from'],
      dateEndTo: json['date_end_to'],
      timeStartsFrom: json['time_starts_from'],
      timeEndTo: json['time_end_to'],
      eventImage: json['event_image'] != null
          ? Urls.imagePathUrl + json['event_image']
          : null,
      eventTermsAndConditionDocument: json['event_terms_and_condition_document'] != null
          ? Urls.imagePathUrl +json['event_terms_and_condition_document']
          : null,
      approvalStatus: json['approval_status'],
      approvedBy: json['approved_by']?.toString(),
      approvedDate: json['approved_date'],
      eventCostType: json['event_cost_type'],
      eventAmount: json['event_amount']?.toString(),
      eventRegistrationLastDate: json['event_registration_last_date'],
      eventsTypeId: json['events_type_id']?.toString(),
      isAllZone: json['is_all_zone']?.toString(),
      youtubeUrl: json['youtube_url'],
      addedBy: json['added_by']?.toString(),
      dateAdded: json['date_added'],
      updatedBy: json['updated_by']?.toString(),
      dateUpdated: json['date_updated'],
      zones: json['zones'] != null
          ? (json['zones'] as List).map((zone) => ZoneData.fromJson(zone)).toList()
          : null,
      allEventDates: json['all_event_dates'] != null
          ? (json['all_event_dates'] as List)
          .map((e) => EventDateTimeData.fromJson(e))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['event_id'] = eventId;
    data['event_name'] = eventName;
    data['event_description'] = eventDescription;
    data['event_organiser_name'] = eventOrganiserName;
    data['event_organiser_mobile'] = eventOrganiserMobile;
    data['date_starts_from'] = dateStartsFrom;
    data['date_end_to'] = dateEndTo;
    data['time_starts_from'] = timeStartsFrom;
    data['time_end_to'] = timeEndTo;
    data['event_image'] = eventImage;
    data['event_terms_and_condition_document'] = eventTermsAndConditionDocument;
    data['approval_status'] = approvalStatus;
    data['approved_by'] = approvedBy;
    data['approved_date'] = approvedDate;
    data['event_cost_type'] = eventCostType;
    data['event_amount'] = eventAmount;
    data['event_registration_last_date'] = eventRegistrationLastDate;
    data['events_type_id'] = eventsTypeId;
    data['is_all_zone'] = isAllZone;
    data['youtube_url'] = youtubeUrl;
    data['added_by'] = addedBy;
    data['date_added'] = dateAdded;
    data['updated_by'] = updatedBy;
    data['date_updated'] = dateUpdated;
    if (zones != null) {
      data['zones'] = zones!.map((zone) => zone.toJson()).toList();
    }
    if (allEventDates != null) {
      data['all_event_dates'] = allEventDates!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
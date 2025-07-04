import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/utils/urls.dart';

class EventData {
  String? eventId;
  String? eventName;
  String? eventDescription;
  String? eventOrganiserName;
  String? eventOrganiserMobile;
  String? dateStartsFrom;
  String? dateEndTo;
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
  });

  factory EventData.fromJson(Map<String, dynamic> json) {
    return EventData(
      eventId: json['event_id']?.toString(),
      eventName: json['event_name'],
      eventDescription: json['event_description'],
      eventOrganiserName: json['event_organiser_name'],
      eventOrganiserMobile: json['event_organiser_mobile'],
      dateStartsFrom: json['date_starts_from'],
      dateEndTo: json['date_end_to'],
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
    return data;
  }
}
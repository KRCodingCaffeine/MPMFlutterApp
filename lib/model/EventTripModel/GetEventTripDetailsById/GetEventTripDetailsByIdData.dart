import 'package:mpm/model/EventTripModel/GetEventTrip/EventTripDateTimeData.dart';
import 'package:mpm/model/GetEventsList/EventDateTimeData.dart';
import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/utils/urls.dart';

import '../GetEventTrip/SamitiOrganiserData.dart';

class GetEventTripDetailsByIdData {
  String? tripId;
  String? tripName;
  String? tripDescription;
  String? tripOrganiserName;
  String? tripOrganiserMobile;
  String? tripStartDate;
  String? tripEndDate;
  String? tripImage;
  String? tripTermsAndConditions;
  String? approvalStatus;
  String? approvedBy;
  String? approvedDate;
  String? tripCostType;
  String? tripAmount;
  String? tripRegistrationLastDate;
  String? tripTypeId;
  String? isAllZone;
  String? addedBy;
  String? dateAdded;
  String? updatedBy;
  String? dateUpdated;
  List<ZoneData>? zones;
  List<EventTripDateTimeData>? allTripDates;
  List<SamitiOrganiser>? samitiOrganisers;

  GetEventTripDetailsByIdData({
    this.tripId,
    this.tripName,
    this.tripDescription,
    this.tripOrganiserName,
    this.tripOrganiserMobile,
    this.tripStartDate,
    this.tripEndDate,
    this.tripImage,
    this.tripTermsAndConditions,
    this.approvalStatus,
    this.approvedBy,
    this.approvedDate,
    this.tripCostType,
    this.tripAmount,
    this.tripRegistrationLastDate,
    this.tripTypeId,
    this.isAllZone,
    this.addedBy,
    this.dateAdded,
    this.updatedBy,
    this.dateUpdated,
    this.zones,
    this.allTripDates,
    this.samitiOrganisers,
  });

  factory GetEventTripDetailsByIdData.fromJson(Map<String, dynamic> json) {
    return GetEventTripDetailsByIdData(
      tripId: json['trip_id']?.toString(),
      tripName: json['trip_name'],
      tripDescription: json['trip_description'],
      tripOrganiserName: json['trip_organiser_name'],
      tripOrganiserMobile: json['trip_organiser_mobile'],
      tripStartDate: json['trip_start_date'],
      tripEndDate: json['trip_end_date'],
      tripImage: json['trip_image'] != null
          ? Urls.imagePathUrl + json['trip_image']
          : null,
      tripTermsAndConditions: json['trip_terms_and_conditions'] != null
          ? Urls.imagePathUrl + json['trip_terms_and_conditions']
          : null,
      approvalStatus: json['approval_status'],
      approvedBy: json['approved_by']?.toString(),
      approvedDate: json['approved_date'],
      tripCostType: json['trip_cost_type'],
      tripAmount: json['trip_amount']?.toString(),
      tripRegistrationLastDate: json['trip_registration_last_date'],
      tripTypeId: json['trip_type_id']?.toString(),
      isAllZone: json['is_all_zone']?.toString(),
      addedBy: json['added_by']?.toString(),
      dateAdded: json['date_added'],
      updatedBy: json['updated_by']?.toString(),
      dateUpdated: json['date_updated'],
      zones: json['zones'] != null
          ? (json['zones'] as List).map((zone) => ZoneData.fromJson(zone)).toList()
          : null,
      allTripDates: json['all_trip_dates'] != null
          ? (json['all_trip_dates'] as List)
          .map((e) => EventTripDateTimeData.fromJson(e))
          .toList()
          : null,
      samitiOrganisers: json['samiti_organisers'] != null
          ? (json['samiti_organisers'] as List).map((e) => SamitiOrganiser.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['trip_id'] = tripId;
    data['trip_name'] = tripName;
    data['trip_description'] = tripDescription;
    data['trip_organiser_name'] = tripOrganiserName;
    data['trip_organiser_mobile'] = tripOrganiserMobile;
    data['trip_start_date'] = tripStartDate;
    data['trip_end_date'] = tripEndDate;
    data['trip_image'] = tripImage;
    data['trip_terms_and_conditions'] = tripTermsAndConditions;
    data['approval_status'] = approvalStatus;
    data['approved_by'] = approvedBy;
    data['approved_date'] = approvedDate;
    data['trip_cost_type'] = tripCostType;
    data['trip_amount'] = tripAmount;
    data['trip_registration_last_date'] = tripRegistrationLastDate;
    data['trip_type_id'] = tripTypeId;
    data['is_all_zone'] = isAllZone;
    data['added_by'] = addedBy;
    data['date_added'] = dateAdded;
    data['updated_by'] = updatedBy;
    data['date_updated'] = dateUpdated;
    if (zones != null) {
      data['zones'] = zones!.map((zone) => zone.toJson()).toList();
    }
    if (allTripDates != null) {
      data['all_trip_dates'] = allTripDates!.map((e) => e.toJson()).toList();
    }
    if (samitiOrganisers != null) {
      data['samiti_organisers'] = samitiOrganisers!.map((e) => e.toJson()).toList();
    }
    return data;
  }
}
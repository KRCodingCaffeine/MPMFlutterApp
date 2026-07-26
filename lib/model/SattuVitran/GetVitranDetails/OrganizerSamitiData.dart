import 'package:mpm/model/SattuVitran/GetVitranDetails/DetailSanyojakData.dart';

class OrganizerSamitiData {
  String? vitranOrganizerSamitiId;
  String? vitranId;
  String? organizerSamitiId;
  String? vitranDistributionCenterId;
  String? organizerContactDetails;
  String? distributionDate;
  String? distributionStartDate;  // Added missing field
  String? distributionEndDate;    // Added missing field
  String? distributionStartTime;
  String? distributionEndTime;
  String? samitiZoneId;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;
  String? organizerSamitiName;
  String? samitiZoneName;
  String? vitranDistributionCenterName;
  String? vitranDistributionCenterDetails;
  String? distributionCenterZoneId;
  String? distributionCenterStatus;
  String? distributionCenterZoneName;

  // New fields from API response
  String? organizerSamitiSubCategoryName;  // Added
  String? samitiId;                        // Added

  // Sanyojak data
  List<DetailSanyojakData>? sanyojak;            // Added
  String? sanyojakName;                    // Added
  String? sanyojakMobile;                  // Added

  OrganizerSamitiData({
    this.vitranOrganizerSamitiId,
    this.vitranId,
    this.organizerSamitiId,
    this.vitranDistributionCenterId,
    this.organizerContactDetails,
    this.distributionDate,
    this.distributionStartDate,
    this.distributionEndDate,
    this.distributionStartTime,
    this.distributionEndTime,
    this.samitiZoneId,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.organizerSamitiName,
    this.samitiZoneName,
    this.vitranDistributionCenterName,
    this.vitranDistributionCenterDetails,
    this.distributionCenterZoneId,
    this.distributionCenterStatus,
    this.distributionCenterZoneName,
    this.organizerSamitiSubCategoryName,
    this.samitiId,
    this.sanyojak,
    this.sanyojakName,
    this.sanyojakMobile,
  });

  factory OrganizerSamitiData.fromJson(Map<String, dynamic> json) {
    return OrganizerSamitiData(
      vitranOrganizerSamitiId: json['vitran_organizer_samiti_id']?.toString(),
      vitranId: json['vitran_id']?.toString(),
      organizerSamitiId: json['organizer_samiti_id']?.toString(),
      vitranDistributionCenterId:
      json['vitran_distribution_center_id']?.toString(),
      organizerContactDetails: json['organizer_contact_details'],
      distributionDate: json['distribution_date'],
      distributionStartDate: json['distribution_start_date'],
      distributionEndDate: json['distribution_end_date'],
      distributionStartTime: json['distribution_start_time'],
      distributionEndTime: json['distribution_end_time'],
      samitiZoneId: json['samiti_zone_id']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at'],
      organizerSamitiName: json['organizer_samiti_name'],
      samitiZoneName: json['samiti_zone_name'],
      vitranDistributionCenterName: json['vitran_distribution_center_name'],
      vitranDistributionCenterDetails:
      json['vitran_distribution_center_details'],
      distributionCenterZoneId: json['distribution_center_zone_id']?.toString(),
      distributionCenterStatus: json['distribution_center_status']?.toString(),
      distributionCenterZoneName: json['distribution_center_zone_name'],
      organizerSamitiSubCategoryName: json['organizer_samiti_sub_category_name'],
      samitiId: json['samiti_id']?.toString(),
      sanyojak: json['sanyojak'] != null
          ? (json['sanyojak'] as List)
          .map((e) => DetailSanyojakData.fromJson(e))
          .toList()
          : [],
      sanyojakName: json['sanyojak_name'],
      sanyojakMobile: json['sanyojak_mobile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitran_organizer_samiti_id': vitranOrganizerSamitiId,
      'vitran_id': vitranId,
      'organizer_samiti_id': organizerSamitiId,
      'vitran_distribution_center_id': vitranDistributionCenterId,
      'organizer_contact_details': organizerContactDetails,
      'distribution_date': distributionDate,
      'distribution_start_date': distributionStartDate,
      'distribution_end_date': distributionEndDate,
      'distribution_start_time': distributionStartTime,
      'distribution_end_time': distributionEndTime,
      'samiti_zone_id': samitiZoneId,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'organizer_samiti_name': organizerSamitiName,
      'samiti_zone_name': samitiZoneName,
      'vitran_distribution_center_name': vitranDistributionCenterName,
      'vitran_distribution_center_details': vitranDistributionCenterDetails,
      'distribution_center_zone_id': distributionCenterZoneId,
      'distribution_center_status': distributionCenterStatus,
      'distribution_center_zone_name': distributionCenterZoneName,
      'organizer_samiti_sub_category_name': organizerSamitiSubCategoryName,
      'samiti_id': samitiId,
      'sanyojak': sanyojak?.map((e) => e.toJson()).toList(),
      'sanyojak_name': sanyojakName,
      'sanyojak_mobile': sanyojakMobile,
    };
  }
}
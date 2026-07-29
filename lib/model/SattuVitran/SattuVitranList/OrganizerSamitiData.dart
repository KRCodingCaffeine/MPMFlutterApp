import 'package:mpm/model/SattuVitran/SattuVitranList/ListSanyojakData.dart';

class OrganizerSamitiData {
  String? vitranOrganizerSamitiId;
  String? vitranId;
  String? organizerSamitiId;
  String? vitranDistributionCenterId;
  String? organizerContactDetails;
  String? distributionDate;
  String? distributionStartDate;
  String? distributionEndDate;
  String? distributionStartTime;
  String? distributionEndTime;
  String? samitiZoneId;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  // Organizer Samiti fields
  String? organizerSamitiName;
  String? organizerSamitiSubCategoryName;
  String? samitiId;

  // Zone fields
  String? samitiZoneName;
  String? distributionCenterZoneName;
  String? distributionCenterZoneId;

  // Distribution Center fields
  String? vitranDistributionCenterName;
  String? vitranDistributionCenterDetails;
  String? distributionCenterStatus;

  // Sanyojak fields
  List<ListSanyojakData>? sanyojak;
  String? sanyojakName;
  String? sanyojakMobile;

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
    this.organizerSamitiSubCategoryName,
    this.samitiId,
    this.samitiZoneName,
    this.distributionCenterZoneName,
    this.distributionCenterZoneId,
    this.vitranDistributionCenterName,
    this.vitranDistributionCenterDetails,
    this.distributionCenterStatus,
    this.sanyojak,
    this.sanyojakName,
    this.sanyojakMobile,
  });

  factory OrganizerSamitiData.fromJson(Map<String, dynamic> json) {
    return OrganizerSamitiData(
      vitranOrganizerSamitiId: json['vitran_organizer_samiti_id']?.toString(),
      vitranId: json['vitran_id']?.toString(),
      organizerSamitiId: json['organizer_samiti_id']?.toString(),
      vitranDistributionCenterId: json['vitran_distribution_center_id']?.toString(),
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
      organizerSamitiSubCategoryName: json['organizer_samiti_sub_category_name'],
      samitiId: json['samiti_id']?.toString(),
      samitiZoneName: json['samiti_zone_name'],
      distributionCenterZoneName: json['distribution_center_zone_name'],
      distributionCenterZoneId: json['distribution_center_zone_id']?.toString(),
      vitranDistributionCenterName: json['vitran_distribution_center_name'],
      vitranDistributionCenterDetails: json['vitran_distribution_center_details'],
      distributionCenterStatus: json['distribution_center_status']?.toString(),
      sanyojak: json['sanyojak'] != null
          ? (json['sanyojak'] as List)
          .map((e) => ListSanyojakData.fromJson(e))
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
      'organizer_samiti_sub_category_name': organizerSamitiSubCategoryName,
      'samiti_id': samitiId,
      'samiti_zone_name': samitiZoneName,
      'distribution_center_zone_name': distributionCenterZoneName,
      'distribution_center_zone_id': distributionCenterZoneId,
      'vitran_distribution_center_name': vitranDistributionCenterName,
      'vitran_distribution_center_details': vitranDistributionCenterDetails,
      'distribution_center_status': distributionCenterStatus,
      'sanyojak': sanyojak?.map((e) => e.toJson()).toList(),
      'sanyojak_name': sanyojakName,
      'sanyojak_mobile': sanyojakMobile,
    };
  }
}
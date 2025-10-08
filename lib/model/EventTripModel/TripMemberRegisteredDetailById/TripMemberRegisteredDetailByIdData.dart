class TripMemberRegisteredDetailByIdData {
  final String? tripRegisteredMemberId;
  final String? tripReferenceCode;
  final String? tripRegisteredData;
  final String? registrationDate;
  String? cancelledDate;
  final String? tripQrCode;
  final String? confirmationStatus;
  final String? tripId;
  final String? tripName;
  final String? tripDescription;
  final String? tripOrganiserName;
  final String? tripOrganiserMobile;
  final String? tripStartDate;
  final String? tripEndDate;
  final String? tripImage;
  final String? tripTermsAndConditions;
  final String? tripCostType;
  final String? tripAmount;
  final String? tripRegistrationLastDate;
  final String? approvalStatus;
  final String? tripTypeId;
  final List<Traveller>? travellers;

  TripMemberRegisteredDetailByIdData({
    this.tripRegisteredMemberId,
    this.tripReferenceCode,
    this.tripRegisteredData,
    this.registrationDate,
    this.cancelledDate,
    this.tripQrCode,
    this.confirmationStatus,
    this.tripId,
    this.tripName,
    this.tripDescription,
    this.tripOrganiserName,
    this.tripOrganiserMobile,
    this.tripStartDate,
    this.tripEndDate,
    this.tripImage,
    this.tripTermsAndConditions,
    this.tripCostType,
    this.tripAmount,
    this.tripRegistrationLastDate,
    this.approvalStatus,
    this.tripTypeId,
    this.travellers,
  });

  factory TripMemberRegisteredDetailByIdData.fromJson(Map<String, dynamic> json) {
    return TripMemberRegisteredDetailByIdData(
      tripRegisteredMemberId: json['trip_registered_member_id'] as String?,
      tripReferenceCode: json['trip_reference_code'] as String?,
      tripRegisteredData: json['trip_registered_data'] as String?,
      registrationDate: json['registration_date'] as String?,
      cancelledDate: json['cancelled_date'] as String?,
      tripQrCode: json['trip_qr_code'] as String?,
      confirmationStatus: json['confirmation_status'] as String?,
      tripId: json['trip_id'] as String?,
      tripName: json['trip_name'] as String?,
      tripDescription: json['trip_description'] as String?,
      tripOrganiserName: json['trip_organiser_name'] as String?,
      tripOrganiserMobile: json['trip_organiser_mobile'] as String?,
      tripStartDate: json['trip_start_date'] as String?,
      tripEndDate: json['trip_end_date'] as String?,
      tripImage: json['trip_image'] as String?,
      tripTermsAndConditions: json['trip_terms_and_conditions'] as String?,
      tripCostType: json['trip_cost_type'] as String?,
      tripAmount: json['trip_amount'] as String?,
      tripRegistrationLastDate: json['trip_registration_last_date'] as String?,
      approvalStatus: json['approval_status'] as String?,
      tripTypeId: json['trip_type_id'] as String?,
      travellers: (json['travellers'] as List<dynamic>?)
          ?.map((e) => Traveller.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'trip_registered_member_id': tripRegisteredMemberId,
    'trip_reference_code': tripReferenceCode,
    'trip_registered_data': tripRegisteredData,
    'registration_date': registrationDate,
    'cancelled_date': cancelledDate,
    'trip_qr_code': tripQrCode,
    'confirmation_status': confirmationStatus,
    'trip_id': tripId,
    'trip_name': tripName,
    'trip_description': tripDescription,
    'trip_organiser_name': tripOrganiserName,
    'trip_organiser_mobile': tripOrganiserMobile,
    'trip_start_date': tripStartDate,
    'trip_end_date': tripEndDate,
    'trip_image': tripImage,
    'trip_terms_and_conditions': tripTermsAndConditions,
    'trip_cost_type': tripCostType,
    'trip_amount': tripAmount,
    'trip_registration_last_date': tripRegistrationLastDate,
    'approval_status': approvalStatus,
    'trip_type_id': tripTypeId,
    'travellers': travellers?.map((e) => e.toJson()).toList(),
  };
}

class Traveller {
  final String? tripTravellerId;
  final String? travellerName;
  final String? createdAt;

  Traveller({this.tripTravellerId, this.travellerName, this.createdAt});

  factory Traveller.fromJson(Map<String, dynamic> json) {
    return Traveller(
      tripTravellerId: json['trip_traveller_id'] as String?,
      travellerName: json['traveller_name'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'trip_traveller_id': tripTravellerId,
    'traveller_name': travellerName,
    'created_at': createdAt,
  };
}
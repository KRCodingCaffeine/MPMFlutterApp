class AddDoctorOccupation {
  final int occupationId;
  final int? occupationProfessionId;
  final int? occupationSpecializationId;
  final int? occupationSpecializationSubCategoryId;
  final int? occupationSpecializationSubSubCategoryId;

  AddDoctorOccupation({
    required this.occupationId,
    this.occupationProfessionId,
    this.occupationSpecializationId,
    this.occupationSpecializationSubCategoryId,
    this.occupationSpecializationSubSubCategoryId,
  });

  Map<String, dynamic> toJson() {
    return {
      'occupation_id': occupationId,
      'occupation_profession_id': occupationProfessionId,
      'occupation_specialization_id': occupationSpecializationId,
      'occupation_specialization_sub_category_id': occupationSpecializationSubCategoryId,
      'occupation_specialization_sub_sub_category_id': occupationSpecializationSubSubCategoryId,
    };
  }
}

class AddDoctorAddress {
  final String addressType;
  final String? clinicName;
  final String? clinicPhone;
  final String? flatNo;
  final String? buildingNameId;
  final String? address;
  final String? areaName;
  final int? cityId;
  final int? stateId;
  final int? countryId;
  final int? zoneId;
  final int? pincode;

  AddDoctorAddress({
    required this.addressType,
    this.clinicName,
    this.clinicPhone,
    this.flatNo,
    this.buildingNameId,
    this.address,
    this.areaName,
    this.cityId,
    this.stateId,
    this.countryId,
    this.zoneId,
    this.pincode,
  });

  Map<String, dynamic> toJson() {
    return {
      'address_type': addressType,
      'clinic_name': clinicName,
      'clinic_phone': clinicPhone,
      'flat_no': flatNo,
      'building_name_id': buildingNameId,
      'address': address,
      'area_name': areaName,
      'city_id': cityId,
      'state_id': stateId,
      'country_id': countryId,
      'zone_id': zoneId,
      'pincode': pincode,
    };
  }
}

class AddDoctorRequest {
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? mobile;
  final String? email;
  final int createdBy;
  final int? memberId;
  final String status;
  final List<AddDoctorOccupation> occupations;
  final List<AddDoctorAddress> addresses;

  AddDoctorRequest({
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.mobile,
    this.email,
    required this.createdBy,
    this.memberId,
    this.status = '0',
    required this.occupations,
    required this.addresses,
  });

  static int? parseId(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return int.tryParse(text);
  }

  static String? emptyToNull(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  Map<String, dynamic> toJson() {
    final occupation = occupations.isEmpty ? null : occupations.first;
    final data = <String, dynamic>{
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'mobile': mobile,
      'email': email,
      'created_by': createdBy,
      'status': status,
      'occupation_id': occupation?.occupationId,
      'occupation_profession_id': occupation?.occupationProfessionId,
      'occupation_specialization_id': occupation?.occupationSpecializationId,
      'occupation_specialization_sub_category_id':
          occupation?.occupationSpecializationSubCategoryId,
      'occupation_specialization_sub_sub_category_id':
          occupation?.occupationSpecializationSubSubCategoryId,
      'occupations': occupations.map((item) => item.toJson()).toList(),
      'addresses': addresses.map((item) => item.toJson()).toList(),
    };
    if (memberId != null && memberId! > 0) {
      data['member_id'] = memberId;
    }
    return data;
  }
}

class AddDoctorModel {
  bool? status;
  int? code;
  String? message;

  AddDoctorModel({this.status, this.code, this.message});

  AddDoctorModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    status = rawStatus == true || rawStatus == 1 || rawStatus == '1' || rawStatus == 'true';
    code = AddDoctorRequest.parseId(json['code']);
    message = json['message']?.toString();
  }
}

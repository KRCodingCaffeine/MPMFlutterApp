class DoctorListModel {
  bool? status;
  int? code;
  String? message;
  int? totalResults;
  int? limit;
  int? offset;
  String? source;
  List<DoctorListData>? data;

  DoctorListModel({
    this.status,
    this.code,
    this.message,
    this.totalResults,
    this.limit,
    this.offset,
    this.source,
    this.data,
  });

  DoctorListModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'];
    status = rawStatus == true || rawStatus == 1 || rawStatus == '1' || rawStatus == 'true';
    code = int.tryParse('${json['code']}');
    message = json['message']?.toString();
    totalResults = int.tryParse('${json['total_results']}');
    limit = int.tryParse('${json['limit']}');
    offset = int.tryParse('${json['offset']}');
    source = json['source']?.toString();
    if (json['data'] is List) {
      data = (json['data'] as List)
          .whereType<Map>()
          .map((item) => DoctorListData.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }
}

class DoctorListData {
  String? source;
  String? memberDoctorId;
  String? memberId;
  String? firstName;
  String? middleName;
  String? lastName;
  String? fullName;
  String? mobile;
  String? email;
  String? status;
  String? profileImage;
  DoctorListOccupation? occupation;
  List<DoctorListOccupation>? occupations;
  List<DoctorListAddress>? addresses;

  DoctorListData.fromJson(Map<String, dynamic> json) {
    source = json['source']?.toString();
    memberDoctorId = json['member_doctor_id']?.toString();
    memberId = json['member_id']?.toString();
    firstName = json['first_name']?.toString();
    middleName = json['middle_name']?.toString();
    lastName = json['last_name']?.toString();
    fullName = json['full_name']?.toString();
    mobile = json['mobile']?.toString();
    email = json['email']?.toString();
    status = json['status']?.toString();
    profileImage = json['profile_image']?.toString();
    if (json['occupation'] is Map) {
      occupation = DoctorListOccupation.fromJson(
        Map<String, dynamic>.from(json['occupation'] as Map),
      );
    }
    if (json['occupations'] is List) {
      occupations = (json['occupations'] as List)
          .whereType<Map>()
          .map((item) => DoctorListOccupation.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
    if (json['addresses'] is List) {
      addresses = (json['addresses'] as List)
          .whereType<Map>()
          .map((item) => DoctorListAddress.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }
  }

  List<DoctorListOccupation> get occupationList {
    if (occupations != null && occupations!.isNotEmpty) return occupations!;
    if (occupation != null) return [occupation!];
    return const [];
  }
}

class DoctorListOccupation {
  String? occupationId;
  String? occupationName;
  String? occupationOtherName;
  String? professionId;
  String? professionName;
  String? specializationId;
  String? specializationName;
  String? specializationSubCategoryId;
  String? specializationSubCategoryName;
  String? specializationSubSubCategoryId;
  String? specializationSubSubCategoryName;

  DoctorListOccupation.fromJson(Map<String, dynamic> json) {
    occupationId = json['occupation_id']?.toString();
    occupationName = json['occupation_name']?.toString();
    occupationOtherName = json['occupation_other_name']?.toString();
    professionId = json['profession_id']?.toString();
    professionName = json['profession_name']?.toString();
    specializationId = json['specialization_id']?.toString();
    specializationName = json['specialization_name']?.toString();
    specializationSubCategoryId = json['specialization_sub_category_id']?.toString();
    specializationSubCategoryName = json['specialization_sub_category_name']?.toString();
    specializationSubSubCategoryId = json['specialization_sub_sub_category_id']?.toString();
    specializationSubSubCategoryName = json['specialization_sub_sub_category_name']?.toString();
  }
}

class DoctorListAddress {
  String? addressType;
  String? clinicName;
  String? clinicPhone;
  String? flatNo;
  String? address;
  String? areaName;
  String? cityName;
  String? stateName;
  String? zoneName;
  String? pincode;

  DoctorListAddress.fromJson(Map<String, dynamic> json) {
    addressType = json['address_type']?.toString();
    clinicName = json['clinic_name']?.toString();
    clinicPhone = json['clinic_phone']?.toString();
    flatNo = json['flat_no']?.toString();
    address = json['address']?.toString();
    areaName = json['area_name']?.toString();
    cityName = json['city_name']?.toString();
    stateName = json['state_name']?.toString();
    zoneName = json['zone_name']?.toString();
    pincode = json['pincode']?.toString();
  }
}

class PartnerLogo {
  String? orgLogo;

  PartnerLogo({this.orgLogo});

  factory PartnerLogo.fromJson(Map<String, dynamic> json) {
    return PartnerLogo(
      orgLogo: json['org_logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_logo': orgLogo,
    };
  }
}

class PartnerLogoModel {
  bool? status;
  int? code;
  String? message;
  PartnerLogo? data;

  PartnerLogoModel({this.status, this.code, this.message, this.data});

  factory PartnerLogoModel.fromJson(Map<String, dynamic> json) {
    return PartnerLogoModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? PartnerLogo.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

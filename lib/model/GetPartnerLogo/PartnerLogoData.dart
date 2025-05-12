class PartnerLogoData {
  final String? orgLogo;

  PartnerLogoData({this.orgLogo});

  // Factory constructor to parse from JSON
  factory PartnerLogoData.fromJson(Map<String, dynamic> json) {
    return PartnerLogoData(
      orgLogo: json['org_logo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_logo': orgLogo,
    };
  }

  @override
  String toString() {
    return 'PartnerLogo(orgLogo: $orgLogo)';
  }
}

class PartnerLogoResponse {
  final bool? status;
  final int? code;
  final String? message;
  final PartnerLogoData? data;

  PartnerLogoResponse({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory PartnerLogoResponse.fromJson(Map<String, dynamic> json) {
    return PartnerLogoResponse(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? PartnerLogoData.fromJson(json['data']) : null,
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

  @override
  String toString() {
    return 'Response(status: $status, code: $code, message: $message, data: $data)';
  }
}

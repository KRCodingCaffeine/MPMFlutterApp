class OverseasFatherIncomeUploadModelClass {
  final bool status;
  final int code;
  final String message;
  final OverseasFatherIncomeData? data;

  OverseasFatherIncomeUploadModelClass({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory OverseasFatherIncomeUploadModelClass.fromJson(Map<String, dynamic> json) {
    return OverseasFatherIncomeUploadModelClass(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OverseasFatherIncomeData.fromJson(json['data']) : null,
    );
  }
}

class OverseasFatherIncomeData {
  final String overseasFatherAnnualIncomeDocument;

  OverseasFatherIncomeData({required this.overseasFatherAnnualIncomeDocument});

  factory OverseasFatherIncomeData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;
    return OverseasFatherIncomeData(
      overseasFatherAnnualIncomeDocument: imageData['overseas_father_annual_income_document']?.toString() ?? '',
    );
  }
}
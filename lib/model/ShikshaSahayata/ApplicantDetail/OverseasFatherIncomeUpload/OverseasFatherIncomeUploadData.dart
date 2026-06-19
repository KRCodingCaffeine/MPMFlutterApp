class OverseasFatherIncomeUploadData {
  final String overseasFatherAnnualIncomeDocument;

  OverseasFatherIncomeUploadData({required this.overseasFatherAnnualIncomeDocument});

  factory OverseasFatherIncomeUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;
    return OverseasFatherIncomeUploadData(
      overseasFatherAnnualIncomeDocument: imageData['overseas_father_annual_income_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'overseas_father_annual_income_document': overseasFatherAnnualIncomeDocument};
}
class FatherAnnualIncomeUploadData {
  final String fatherAnnualIncomeDocument;

  FatherAnnualIncomeUploadData({required this.fatherAnnualIncomeDocument});

  factory FatherAnnualIncomeUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;
    return FatherAnnualIncomeUploadData(
      fatherAnnualIncomeDocument: imageData['father_annual_income_document']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'father_annual_income_document': fatherAnnualIncomeDocument};
}
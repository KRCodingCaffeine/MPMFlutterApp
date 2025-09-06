class GetLatestSaraswaniPublicationData {
  String? month;
  String? year;
  String? documentPath;

  GetLatestSaraswaniPublicationData({this.month, this.year, this.documentPath});

  factory GetLatestSaraswaniPublicationData.fromJson(Map<String, dynamic> json) {
    return GetLatestSaraswaniPublicationData(
      month: json['month'],
      year: json['year'],
      documentPath: json['document_path'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['month'] = month;
    data['year'] = year;
    data['document_path'] = documentPath;
    return data;
  }
}

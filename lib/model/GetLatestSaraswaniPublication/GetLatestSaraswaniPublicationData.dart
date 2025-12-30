class GetLatestSaraswaniPublicationData {
  String? month;
  String? year;
  String? documentPath;
  String? saraswaniPublicationsId;

  GetLatestSaraswaniPublicationData({this.month, this.year, this.documentPath, this.saraswaniPublicationsId});

  factory GetLatestSaraswaniPublicationData.fromJson(Map<String, dynamic> json) {
    return GetLatestSaraswaniPublicationData(
      month: json['month'],
      year: json['year'],
      documentPath: json['document_path'],
      saraswaniPublicationsId: json['saraswani_publications_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['month'] = month;
    data['year'] = year;
    data['document_path'] = documentPath;
    data['saraswani_publications_id'] = saraswaniPublicationsId;
    return data;
  }
}

import 'package:mpm/utils/urls.dart';

class SaraswaniPublicationData {
  String? documentPath;
  String? saraswaniPublicationsId;

  SaraswaniPublicationData({this.documentPath, this.saraswaniPublicationsId});

  factory SaraswaniPublicationData.fromJson(Map<String, dynamic> json) {
    return SaraswaniPublicationData(
      documentPath:
          json['document_path'] != null ? json['document_path'] : null,
      saraswaniPublicationsId: json['saraswani_publications_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['document_path'] = documentPath;
    data['saraswani_publications_id'] = saraswaniPublicationsId;
    return data;
  }
}

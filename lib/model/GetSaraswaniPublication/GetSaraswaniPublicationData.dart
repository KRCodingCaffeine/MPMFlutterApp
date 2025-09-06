import 'package:mpm/utils/urls.dart';

class SaraswaniPublicationData {
  String? documentPath;

  SaraswaniPublicationData({this.documentPath});

  factory SaraswaniPublicationData.fromJson(Map<String, dynamic> json) {
    return SaraswaniPublicationData(
      documentPath:
          json['document_path'] != null ? json['document_path'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['document_path'] = documentPath;
    return data;
  }
}

class FlightTicketUploadData {
  final String documentPath;
  final String documentUrl;

  FlightTicketUploadData({
    required this.documentPath,
    required this.documentUrl,
  });

  factory FlightTicketUploadData.fromJson(Map<String, dynamic> json) {
    return FlightTicketUploadData(
      documentPath: json['document_path']?.toString() ?? '',
      documentUrl: json['document_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'document_path': documentPath,
      'document_url': documentUrl,
    };
  }
}
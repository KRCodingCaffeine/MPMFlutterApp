class QrCodeScannerResponse {
  bool? status;
  String? message;

  QrCodeScannerResponse({
    this.status,
    this.message,
  });

  factory QrCodeScannerResponse.fromJson(Map<String, dynamic> json) {
    return QrCodeScannerResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}

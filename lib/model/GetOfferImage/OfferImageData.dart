class OfferImageData {
  final String offerImage;

  OfferImageData({required this.offerImage});

  factory OfferImageData.fromJson(Map<String, dynamic> json) {
    // Assuming the response has a nested structure with "1" as key
    final imageData = json['1'] ?? json;
    return OfferImageData(
      offerImage: imageData['offer_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
        'offer_image': offerImage,
    };
  }
}

class OfferImageResponse {
  final bool status;
  final int code;
  final String message;
  final OfferImageData? data;

  OfferImageResponse({
    required this.status,
    required this.code,
    required this.message,
    this.data,
  });

  factory OfferImageResponse.fromJson(Map<String, dynamic> json) {
    return OfferImageResponse(
      status: json['status'] ?? false,
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      data: json['data'] != null ? OfferImageData.fromJson(json['data']) : null,
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
}
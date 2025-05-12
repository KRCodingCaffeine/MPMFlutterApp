class Offerimagemodelclass {
  String? offerImage;

  Offerimagemodelclass({this.offerImage});

  factory Offerimagemodelclass.fromJson(Map<String, dynamic> json) {
    return Offerimagemodelclass(
      offerImage: "https://members.mumbaimaheshwari.com/api/public/" + json['offer_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offer_image': offerImage,
    };
  }
}

class OfferImageModel {
  bool? status;
  int? code;
  String? message;
  Offerimagemodelclass? data;

  OfferImageModel({this.status, this.code, this.message, this.data});

  factory OfferImageModel.fromJson(Map<String, dynamic> json) {
    return OfferImageModel(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? Offerimagemodelclass.fromJson(json['data']) : null,
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

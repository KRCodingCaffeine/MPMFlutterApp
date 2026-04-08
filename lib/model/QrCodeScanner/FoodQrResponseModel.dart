class FoodQrResponse {
  bool? status;
  String? message;

  FoodQrResponse({
    this.status,
    this.message,
  });

  factory FoodQrResponse.fromJson(Map<String, dynamic> json) {
    return FoodQrResponse(
      status: json['status'] == true || json['status'] == 'true',
      message: json['message'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "status": status,
      "message": message,
    };
  }
}
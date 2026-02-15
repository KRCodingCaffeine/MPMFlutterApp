class AadhaarUploadData {
  final String aadhaarImage;

  AadhaarUploadData({required this.aadhaarImage});

  factory AadhaarUploadData.fromJson(Map<String, dynamic> json) {
    final imageData = json['1'] ?? json;

    return AadhaarUploadData(
      aadhaarImage: imageData['aadhaar_image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'aadhaar_image': aadhaarImage,
    };
  }
}

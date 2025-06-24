class EnquiryData {
  String? memberId;
  String? message;
  String? enquiryStatus;
  String? addedBy;
  String? createdBy;
  String? createdAt;

  EnquiryData({
    this.memberId,
    this.message,
    this.enquiryStatus,
    this.addedBy,
    this.createdBy,
    this.createdAt,
  });

  factory EnquiryData.fromJson(Map<String, dynamic> json) {
    return EnquiryData(
      memberId: json['member_id']?.toString(),
      message: json['message'],
      enquiryStatus: json['enquiry_status'],
      addedBy: json['added_by']?.toString(),
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['member_id'] = memberId;
    data['message'] = message;
    data['enquiry_status'] = enquiryStatus;
    data['added_by'] = addedBy;
    data['created_by'] = createdBy;
    data['created_at'] = createdAt;
    return data;
  }
}
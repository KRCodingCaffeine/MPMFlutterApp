class AddOfferDiscountData {
  int? memberId;
  int? orgSubcategoryId;
  List<Medicine>? medicines;
  int? createdBy;
  String? prescriptionImage;

  AddOfferDiscountData({
    this.memberId,
    this.orgSubcategoryId,
    this.medicines,
    this.createdBy,
    this.prescriptionImage,
  });

  factory AddOfferDiscountData.fromJson(Map<String, dynamic> json) {
    return AddOfferDiscountData(
      memberId: json['member_id'],
      orgSubcategoryId: json['org_subcategory_id'],
      medicines: json['medicines'] != null
          ? List<Medicine>.from(
          json['medicines'].map((x) => Medicine.fromJson(x)))
          : null,
      createdBy: json['created_by'],
      prescriptionImage: json['prescription_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'org_subcategory_id': orgSubcategoryId,
      'medicines': medicines?.map((x) => x.toJson()).toList(),
      'created_by': createdBy,
      'prescription_image': prescriptionImage,
    };
  }
}

class Medicine {
  String? medicineName;
  int? medicineContainerId;
  int? quantity;

  Medicine({
    this.medicineName,
    this.medicineContainerId,
    this.quantity,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      medicineName: json['medicine_name'],
      medicineContainerId: json['medicine_container_id'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicine_name': medicineName,
      'medicine_container_id': medicineContainerId,
      'quantity': quantity,
    };
  }
}

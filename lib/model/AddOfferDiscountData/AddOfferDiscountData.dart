class AddOfferDiscountData {
  int? memberId;
  int? orgSubcategoryId;
  List<Medicine>? medicines;
  int? createdBy;
  String? prescriptionImage;
  int? orgDetailsID;

  AddOfferDiscountData({
    this.memberId,
    this.orgSubcategoryId,
    this.medicines,
    this.createdBy,
    this.prescriptionImage,
    this.orgDetailsID,
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
      orgDetailsID: json['org_details_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'org_subcategory_id': orgSubcategoryId,
      'medicines': medicines?.map((x) => x.toJson()).toList(),
      'created_by': createdBy,
      'prescription_image': prescriptionImage,
      'org_details_id': orgDetailsID
    };
  }
}

class Medicine {
  int? orgDetailsID;
  String? medicineName;
  int? medicineContainerId;
  String? medicineContainerName;
  int? quantity;

  Medicine({
    this.orgDetailsID,
    this.medicineName,
    this.medicineContainerId,
    this.medicineContainerName,
    this.quantity,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      orgDetailsID: json['org_details_id'],
      medicineName: json['medicine_name']?.toString() ?? '',
      medicineContainerId: json['medicine_container_id'],
      medicineContainerName: json['medicine_container_name'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'org_details_id': orgDetailsID,
      'medicine_name': medicineName,
      'medicine_container_id': medicineContainerId,
      'medicine_container_name': medicineContainerName,
      'quantity': quantity,
    };
  }
}

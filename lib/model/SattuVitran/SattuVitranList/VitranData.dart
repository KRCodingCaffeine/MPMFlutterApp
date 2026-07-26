import 'package:mpm/model/SattuVitran/SattuVitranList/OrganizerSamitiData.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/ProductData.dart';
import 'package:mpm/model/SattuVitran/SattuVitranList/SamitiOrganiserListData.dart';
import 'package:mpm/utils/urls.dart';

class VitranData {
  String? vitranId;
  String? vitranName;
  String? vitranDescription;
  String? vitranDocument;
  String? status;
  String? startDateOfOrder;
  String? lastDateToOrder;
  String? lastDateToCancel;
  String? createdBy;
  String? createdAt;
  String? updatedBy;
  String? updatedAt;

  List<OrganizerSamitiData>? organizerSamiti;
  List<ProductData>? products;
  List<SamitiOrganiserListData>? samitiOrganisers;

  VitranData({
    this.vitranId,
    this.vitranName,
    this.vitranDescription,
    this.vitranDocument,
    this.status,
    this.startDateOfOrder,
    this.lastDateToOrder,
    this.lastDateToCancel,
    this.createdBy,
    this.createdAt,
    this.updatedBy,
    this.updatedAt,
    this.organizerSamiti,
    this.products,
    this.samitiOrganisers,
  });

  factory VitranData.fromJson(Map<String, dynamic> json) {
    return VitranData(
      vitranId: json['vitran_id']?.toString(),
      vitranName: json['vitran_name'],
      vitranDescription: json['vitran_description'],
      vitranDocument: json['vitran_document'] != null
          ? Urls.imagePathUrl + json['vitran_document']
          : null,
      status: json['status'],
      startDateOfOrder: json['start_date_of_order'],
      lastDateToOrder: json['last_date_to_order'],
      lastDateToCancel: json['last_date_to_cancel'],
      createdBy: json['created_by']?.toString(),
      createdAt: json['created_at'],
      updatedBy: json['updated_by']?.toString(),
      updatedAt: json['updated_at'],
      organizerSamiti: json['organizer_samiti'] != null
          ? (json['organizer_samiti'] as List)
              .map((e) => OrganizerSamitiData.fromJson(e))
              .toList()
          : [],
      products: json['products'] != null
          ? (json['products'] as List)
              .map((e) => ProductData.fromJson(e))
              .toList()
          : [],
      samitiOrganisers: json['samiti_organisers'] != null
          ? (json['samiti_organisers'] as List)
          .map((e) => SamitiOrganiserListData.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vitran_id': vitranId,
      'vitran_name': vitranName,
      'vitran_description': vitranDescription,
      'vitran_document': vitranDocument,
      'status': status,
      'start_date_of_order': startDateOfOrder,
      'last_date_to_order': lastDateToOrder,
      'last_date_to_cancel': lastDateToCancel,
      'created_by': createdBy,
      'created_at': createdAt,
      'updated_by': updatedBy,
      'updated_at': updatedAt,
      'organizer_samiti': organizerSamiti?.map((e) => e.toJson()).toList(),
      'products': products?.map((e) => e.toJson()).toList(),
      'samiti_organisers': samitiOrganisers?.map((e) => e.toJson()).toList(),
    };
  }
}

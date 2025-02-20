class DocumentTypeModel {
  bool? status;
  String? message;
  List<DocumentTypeData>? data;

  DocumentTypeModel({this.status, this.message, this.data});

  DocumentTypeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <DocumentTypeData>[];
      json['data'].forEach((v) {
        data!.add(new DocumentTypeData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class DocumentTypeData{
  String? id;
  String? documentType;
  String? status;
  String? createdAt;
  String? updatedAt;

  DocumentTypeData({this.id, this.documentType, this.status, this.createdAt, this.updatedAt});

  DocumentTypeData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    documentType = json['document_type'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['document_type'] = this.documentType;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}

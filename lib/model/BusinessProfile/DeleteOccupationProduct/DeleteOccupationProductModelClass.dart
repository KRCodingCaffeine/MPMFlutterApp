class DeleteOccupationProductModelClass {
  bool? status;
  int? code;
  String? message;

  DeleteOccupationProductModelClass({
    this.status,
    this.code,
    this.message,
  });

  DeleteOccupationProductModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    code = json['code'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    map['status'] = status;
    map['code'] = code;
    map['message'] = message;
    return map;
  }
}

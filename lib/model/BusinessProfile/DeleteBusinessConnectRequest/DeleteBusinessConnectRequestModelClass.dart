class DeleteBusinessConnectRequestModelClass {
  bool? status;
  int? code;
  String? message;

  DeleteBusinessConnectRequestModelClass({
    this.status,
    this.code,
    this.message,
  });

  DeleteBusinessConnectRequestModelClass.fromJson(Map<String, dynamic> json) {
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

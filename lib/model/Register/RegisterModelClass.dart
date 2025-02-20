class RegisterModelClass {
  bool? status;
  String? message;
  var data;

  RegisterModelClass({this.status, this.message,this.data});

  RegisterModelClass.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['msg'];
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.message;
    data['data'] = this.data;
    return data;
  }
}
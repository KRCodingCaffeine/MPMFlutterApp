class AddNONMElectionModelClass {
  bool? status;
  int? code;
  String? message;
  dynamic data;

  AddNONMElectionModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
  });

  factory AddNONMElectionModelClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return AddNONMElectionModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',
      code: json['code'] is int
          ? json['code']
          : int.tryParse(
              json['code']?.toString() ?? '',
            ),
      message: json['message']?.toString(),
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'code': code,
      'message': message,
      'data': data,
    };
  }
}

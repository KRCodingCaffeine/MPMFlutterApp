class SamitiConvertToLMModelClass {
  bool? status;
  String? memberId;
  String? msg;

  SamitiConvertToLMModelClass({
    this.status,
    this.memberId,
    this.msg,
  });

  factory SamitiConvertToLMModelClass.fromJson(
    Map<String, dynamic> json,
  ) {
    return SamitiConvertToLMModelClass(
      status: json['status'] is bool
          ? json['status']
          : json['status']?.toString() == 'true',
      memberId: json['member_id']?.toString(),
      msg: json['msg']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'member_id': memberId,
      'msg': msg,
    };
  }
}

class AddBusinessConnectRequestData {
  String? requestId;

  AddBusinessConnectRequestData({
    this.requestId,
  });

  AddBusinessConnectRequestData.fromJson(Map<String, dynamic> json) {
    requestId = json['request_id']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['request_id'] = requestId;
    return json;
  }
}

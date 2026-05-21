class AdminAccessData {
  String? adminAccessId;
  String? moduleName;
  String? moduleKey;
  String? status;

  AdminAccessData({
    this.adminAccessId,
    this.moduleName,
    this.moduleKey,
    this.status,
  });

  factory AdminAccessData.fromJson(Map<String, dynamic> json) {
    return AdminAccessData(
      adminAccessId: json['admin_access_id']?.toString(),
      moduleName: json['module_name'],
      moduleKey: json['module_key'],
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_access_id': adminAccessId,
      'module_name': moduleName,
      'module_key': moduleKey,
      'status': status,
    };
  }
}
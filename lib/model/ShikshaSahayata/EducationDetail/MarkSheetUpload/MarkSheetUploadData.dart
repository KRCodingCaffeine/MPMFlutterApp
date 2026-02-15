class MarkSheetUploadData {
  final String markSheetPath;

  MarkSheetUploadData({
    required this.markSheetPath,
  });

  factory MarkSheetUploadData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;

    return MarkSheetUploadData(
      markSheetPath: data['mark_sheet_attachment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mark_sheet_attachment': markSheetPath,
    };
  }
}

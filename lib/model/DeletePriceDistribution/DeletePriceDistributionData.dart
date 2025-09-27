class DeletePriceDistributionData {
  final int? deletedId;
  DeletePriceDistributionData({this.deletedId});

  factory DeletePriceDistributionData.fromJson(Map<String, dynamic> json) {
    return DeletePriceDistributionData(
      deletedId: json['deleted_id'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'deleted_id': deletedId,
      };
}

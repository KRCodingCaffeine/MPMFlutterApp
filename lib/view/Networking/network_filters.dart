class NetworkFilters {
  final int? occupationId;
  final int? professionId;
  final List<int> specializationIds;
  final List<int> subCategoryIds;

  const NetworkFilters({
    this.occupationId,
    this.professionId,
    this.specializationIds = const [],
    this.subCategoryIds = const [],
  });

  NetworkFilters copyWith({
    int? occupationId,
    int? professionId,
    List<int>? specializationIds,
    List<int>? subCategoryIds,
  }) {
    return NetworkFilters(
      occupationId: occupationId ?? this.occupationId,
      professionId: professionId ?? this.professionId,
      specializationIds: specializationIds ?? this.specializationIds,
      subCategoryIds: subCategoryIds ?? this.subCategoryIds,
    );
  }

  static const empty = NetworkFilters();
}

// lib/view/Networking/network_filters.dart
class NetworkFilters {
  final List<String> occupations;
  final List<String> professions;
  final List<String> specializations;
  final List<String> subcategories;
  final List<String> subSubcategories;
  final List<String> productCategories;
  final List<String> productSubcategories;

  const NetworkFilters({
    this.occupations = const [],
    this.professions = const [],
    this.specializations = const [],
    this.subcategories = const [],
    this.subSubcategories = const [],
    this.productCategories = const [],
    this.productSubcategories = const [],
  });

  factory NetworkFilters.empty() => const NetworkFilters();

  NetworkFilters copyWith({
    List<String>? occupations,
    List<String>? professions,
    List<String>? specializations,
    List<String>? subcategories,
    List<String>? subSubcategories,
    List<String>? productCategories,
    List<String>? productSubcategories,
  }) {
    return NetworkFilters(
      occupations: occupations ?? this.occupations,
      professions: professions ?? this.professions,
      specializations: specializations ?? this.specializations,
      subcategories: subcategories ?? this.subcategories,
      subSubcategories: subSubcategories ?? this.subSubcategories,
      productCategories: productCategories ?? this.productCategories,
      productSubcategories: productSubcategories ?? this.productSubcategories,
    );
  }

  bool get hasFilters =>
      occupations.isNotEmpty ||
          professions.isNotEmpty ||
          specializations.isNotEmpty ||
          subcategories.isNotEmpty ||
          subSubcategories.isNotEmpty ||
          productCategories.isNotEmpty ||
          productSubcategories.isNotEmpty;

  // Convert to query string for GET requests
  String toQueryString() {
    final params = <String>[];

    if (occupations.isNotEmpty) {
      for (var occupation in occupations) {
        params.add('occupations[]=${Uri.encodeComponent(occupation)}');
      }
    }
    if (professions.isNotEmpty) {
      for (var profession in professions) {
        params.add('professions[]=${Uri.encodeComponent(profession)}');
      }
    }
    if (specializations.isNotEmpty) {
      for (var specialization in specializations) {
        params.add('specializations[]=${Uri.encodeComponent(specialization)}');
      }
    }
    if (subcategories.isNotEmpty) {
      for (var subcategory in subcategories) {
        params.add('subcategories[]=${Uri.encodeComponent(subcategory)}');
      }
    }
    if (subSubcategories.isNotEmpty) {
      for (var subSubcategory in subSubcategories) {
        params.add('sub_subcategories[]=${Uri.encodeComponent(subSubcategory)}');
      }
    }
    if (productCategories.isNotEmpty) {
      for (var category in productCategories) {
        params.add('product_categories[]=${Uri.encodeComponent(category)}');
      }
    }
    if (productSubcategories.isNotEmpty) {
      for (var subcategory in productSubcategories) {
        params.add('product_subcategories[]=${Uri.encodeComponent(subcategory)}');
      }
    }

    return params.join('&');
  }

  // For POST requests
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (occupations.isNotEmpty) {
      json['occupations'] = occupations;
    }
    if (professions.isNotEmpty) {
      json['professions'] = professions;
    }
    if (specializations.isNotEmpty) {
      json['specializations'] = specializations;
    }
    if (subcategories.isNotEmpty) {
      json['subcategories'] = subcategories;
    }
    if (subSubcategories.isNotEmpty) {
      json['sub_subcategories'] = subSubcategories;
    }
    if (productCategories.isNotEmpty) {
      json['product_categories'] = productCategories;
    }
    if (productSubcategories.isNotEmpty) {
      json['product_subcategories'] = productSubcategories;
    }

    return json;
  }
}
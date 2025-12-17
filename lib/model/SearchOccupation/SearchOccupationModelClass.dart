// lib/model/SearchOccupation/SearchOccupationModelClass.dart
import 'package:mpm/model/SearchOccupation/SearchOccupationData.dart';

class FilterOptions {
  final List<String> occupations;
  final List<String> professions;
  final List<String> specializations;
  final List<String> subcategories;
  final List<String> subSubcategories;
  final List<Map<String, dynamic>> zones;

  FilterOptions({
    this.occupations = const [],
    this.professions = const [],
    this.specializations = const [],
    this.subcategories = const [],
    this.subSubcategories = const [],
    this.zones = const [],
  });

  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    // Helper to extract string from filter item (handles objects and strings)
    // Exclude 'Other' as per requirement
    String? extractFilterValue(dynamic x) {
      if (x == null) return null;
      if (x is String) {
        if (x.isEmpty || x.toLowerCase() == 'other') return null;
        return x;
      }
      if (x is Map) {
        // If it's an object, extract the name field
        final value = x['name']?.toString() ?? 
               x['occupation_name']?.toString() ?? 
               x['occupation']?.toString();
        if (value == null || value.isEmpty || value.toLowerCase() == 'other') return null;
        return value;
      }
      final str = x.toString();
      if (str.isEmpty || str == 'null' || str.toLowerCase() == 'other') return null;
      return str;
    }

    // Helper to extract zones
    List<Map<String, dynamic>> extractZones(dynamic zonesData) {
      if (zonesData == null || zonesData is! List) return [];
      return zonesData
          .where((zone) => zone != null && zone is Map)
          .map((zone) => Map<String, dynamic>.from(zone as Map))
          .toList();
    }

    return FilterOptions(
      occupations: json['occupations'] != null && (json['occupations'] as List).isNotEmpty
          ? json['occupations'].map(extractFilterValue).whereType<String>().toList()
          : [],
      professions: json['professions'] != null && (json['professions'] as List).isNotEmpty
          ? json['professions'].map(extractFilterValue).whereType<String>().toList()
          : [],
      specializations: json['specializations'] != null && (json['specializations'] as List).isNotEmpty
          ? json['specializations'].map(extractFilterValue).whereType<String>().toList()
          : [],
      subcategories: json['subcategories'] != null && (json['subcategories'] as List).isNotEmpty
          ? json['subcategories'].map(extractFilterValue).whereType<String>().toList()
          : (json['specialization_sub_categories'] != null && (json['specialization_sub_categories'] as List).isNotEmpty
              ? json['specialization_sub_categories'].map(extractFilterValue).whereType<String>().toList()
              : []),
      subSubcategories: json['sub_subcategories'] != null && (json['sub_subcategories'] as List).isNotEmpty
          ? json['sub_subcategories'].map(extractFilterValue).whereType<String>().toList()
          : (json['specialization_sub_sub_categories'] != null && (json['specialization_sub_sub_categories'] as List).isNotEmpty
              ? json['specialization_sub_sub_categories'].map(extractFilterValue).whereType<String>().toList()
              : []),
      zones: json['zones'] != null && (json['zones'] as List).isNotEmpty
          ? extractZones(json['zones'])
          : [],
    );
  }
}

class SearchOccupationModelClass {
  bool? status;
  int? code;
  String? message;
  List<SearchOccupationData>? data;
  int? totalResults;
  int? totalPages;
  FilterOptions? filters;
  String? searchQuery;
  String? matchedLevel;
  String? matchedValue;

  SearchOccupationModelClass({
    this.status,
    this.code,
    this.message,
    this.data,
    this.totalResults,
    this.totalPages,
    this.filters,
    this.searchQuery,
    this.matchedLevel,
    this.matchedValue,
  });

  factory SearchOccupationModelClass.fromJson(Map<String, dynamic> json) {
    // Handle both 'members' and 'data' keys for backward compatibility
    final membersData = json['members'] ?? json['data'];
    
    return SearchOccupationModelClass(
      status: json['status'],
      code: json['code'],
      message: json['message'],
      data: membersData != null
          ? List<SearchOccupationData>.from(
              membersData.map((x) => SearchOccupationData.fromJson(x)))
          : null,
      totalResults: json['total_results'] ?? json['result_count'] ?? json['pagination']?['total'],
      totalPages: json['total_pages'] ?? json['pagination']?['pages'],
      filters: json['filters'] != null
          ? FilterOptions.fromJson(json['filters'])
          : null,
      searchQuery: json['search_query']?.toString(),
      matchedLevel: json['matched_level']?.toString(),
      matchedValue: json['matched_value']?.toString(),
    );
  }
}
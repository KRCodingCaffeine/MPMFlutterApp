// lib/repository/search_occupation_repository/search_occupation_repo.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class SearchSuggestion {
  final String name;
  final String type;
  final String displayText;
  final String searchTerm;
  final String id;
  final Map<String, dynamic>? hierarchy;

  SearchSuggestion({
    required this.name,
    required this.type,
    required this.displayText,
    required this.searchTerm,
    required this.id,
    this.hierarchy,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      displayText: json['display_text']?.toString() ?? json['name']?.toString() ?? '',
      searchTerm: json['search_term']?.toString() ?? json['name']?.toString() ?? '',
      id: json['id']?.toString() ?? '',
      hierarchy: json['hierarchy'] is Map ? Map<String, dynamic>.from(json['hierarchy']) : null,
    );
  }

  // For backward compatibility
  String get label => displayText;
  String get value => searchTerm;
}

class SearchOccupationRepository {

  Future<SearchOccupationModelClass> searchOccupation({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
    NetworkFilters? filters,
  }) async {
    try {
      // Build the URL - using 'search_term' parameter (API expects this)
      String url = '${Urls.searchOccupation_url}?search_term=${Uri.encodeComponent(searchTerm)}&limit=$limit&offset=$offset';
      
      // Calculate page from offset
      final page = (offset / limit).floor() + 1;
      url += '&page=$page';

      // Add filters if provided
      if (filters != null && filters.hasFilters) {
        if (filters.occupations.isNotEmpty) {
          for (var occupation in filters.occupations) {
            url += '&occupations[]=${Uri.encodeComponent(occupation)}';
          }
        }
        if (filters.professions.isNotEmpty) {
          for (var profession in filters.professions) {
            url += '&professions[]=${Uri.encodeComponent(profession)}';
          }
        }
        if (filters.specializations.isNotEmpty) {
          for (var specialization in filters.specializations) {
            url += '&specializations[]=${Uri.encodeComponent(specialization)}';
          }
        }
        if (filters.subcategories.isNotEmpty) {
          for (var subcategory in filters.subcategories) {
            url += '&subcategories[]=${Uri.encodeComponent(subcategory)}';
          }
        }
        if (filters.subSubcategories.isNotEmpty) {
          for (var subSubcategory in filters.subSubcategories) {
            url += '&sub_subcategories[]=${Uri.encodeComponent(subSubcategory)}';
          }
        }
        if (filters.productCategories.isNotEmpty) {
          for (var category in filters.productCategories) {
            url += '&product_categories[]=${Uri.encodeComponent(category)}';
          }
        }
        if (filters.productSubcategories.isNotEmpty) {
          for (var subcategory in filters.productSubcategories) {
            url += '&product_subcategories[]=${Uri.encodeComponent(subcategory)}';
          }
        }
      }

      final uri = Uri.parse(url);
      debugPrint("Search URL: $uri");

      // Make API call
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        debugPrint("Search Response received: ${jsonResponse['status']}");
        debugPrint("Message: ${jsonResponse['message']}");
        debugPrint("Response keys: ${jsonResponse.keys.toList()}");
        
        // Debug filters in response
        if (jsonResponse['filters'] != null) {
          debugPrint("Filters in response: ${jsonResponse['filters']}");
        } else {
          debugPrint("No 'filters' key in response");
        }

        if (jsonResponse['status'] == true || jsonResponse['members'] != null) {
          final model = SearchOccupationModelClass.fromJson(jsonResponse);
          debugPrint("Parsed filters: ${model.filters != null ? 'Present' : 'Null'}");
          if (model.filters != null) {
            debugPrint("Filter counts - Occupations: ${model.filters!.occupations.length}, Professions: ${model.filters!.professions.length}");
          }
          return model;
        } else {
          throw Exception('API Error: ${jsonResponse['message'] ?? 'Unknown error'}');
        }
      } else {
        debugPrint("Error response body: ${response.body}");
        throw Exception('Failed to load search results: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("Error searching occupation: $e");
      rethrow;
    }
  }

  /// Search suggestions - Uses suggestions_only=true parameter
  /// API: /api/search_occupation?search_term=card&suggestions_only=true&limit=20
  Future<List<SearchSuggestion>> searchSuggestions({
    required String keyword,
  }) async {
    try {
      // Minimum 2 characters
      if (keyword.isEmpty || keyword.length < 2) {
        return [];
      }

      // Use search API with suggestions_only=true parameter
      final url = '${Urls.searchOccupation_url}?search_term=${Uri.encodeComponent(keyword)}&suggestions_only=true&limit=20';
      final uri = Uri.parse(url);
      
      debugPrint("Search Suggestions URL: $uri");

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("Suggestions API Status: ${response.statusCode}");
      debugPrint("Suggestions API Response: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['status'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'] as List;
          final suggestions = data
              .map((x) => SearchSuggestion.fromJson(x))
              .toList();
          
          debugPrint("Found ${suggestions.length} suggestions");
          return suggestions;
        } else {
          debugPrint("No data in suggestions response");
          return [];
        }
      } else {
        debugPrint("Error response body: ${response.body}");
        debugPrint("Error status code: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      debugPrint("Error getting search suggestions: $e");
      return [];
    }
  }

  // Test method to verify API connection
  Future<void> testApiConnection() async {
    try {
      final testUri = Uri.parse('${Urls.searchOccupation_url}?search_term=service&limit=5&offset=0&page=1');
      debugPrint("Testing API URL: $testUri");

      final response = await http.get(testUri);
      debugPrint("Test response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Test successful! Status: ${data['status']}, Message: ${data['message']}");
        if (data['members'] != null || data['data'] != null) {
          final members = data['members'] ?? data['data'];
          debugPrint("Found ${members.length} results");
        }
      } else {
        debugPrint("Test failed with status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }
    } catch (e) {
      debugPrint("Test error: $e");
    }
  }
}
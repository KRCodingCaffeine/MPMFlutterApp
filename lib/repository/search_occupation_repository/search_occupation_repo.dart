// lib/repository/search_occupation_repository/search_occupation_repo.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/SearchOccupation/SearchOccupationModelClass.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/Networking/network_filters.dart';

class SearchOccupationRepository {

  Future<SearchOccupationModelClass> searchOccupation({
    required String searchTerm,
    int limit = 20,
    int offset = 0,
    NetworkFilters? filters,
  }) async {
    try {
      // Build the URL based on your API documentation
      String url = '${Urls.searchOccupation_url}?search_term=${Uri.encodeComponent(searchTerm)}&limit=$limit&offset=$offset';

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

        if (jsonResponse['status'] == true) {
          return SearchOccupationModelClass.fromJson(jsonResponse);
        } else {
          throw Exception('API Error: ${jsonResponse['message']}');
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

  // Test method to verify API connection
  Future<void> testApiConnection() async {
    try {
      final testUri = Uri.parse('${Urls.searchOccupation_url}?search_term=service&limit=5&offset=0');
      debugPrint("Testing API URL: $testUri");

      final response = await http.get(testUri);
      debugPrint("Test response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint("Test successful! Status: ${data['status']}, Message: ${data['message']}");
        if (data['data'] != null) {
          debugPrint("Found ${data['data'].length} results");
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
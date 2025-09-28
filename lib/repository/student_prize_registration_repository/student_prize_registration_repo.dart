import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/data/network/network_api_service.dart';
import 'package:mpm/model/StudentPrizeRegistration/StudentPrizeRegistrationData.dart';
import 'package:mpm/utils/urls.dart';

class StudentPrizeRegistrationRepository {
  final api = NetWorkApiService();

  Future<dynamic> registerForStudentPrize(StudentPrizeRegistrationData dataModel) async {
    try {
      final uri = Uri.parse(Urls.student_prize_register_url);
      var request = http.MultipartRequest('POST', uri);

      _addFormFields(request, dataModel);
      await _addFileIfExists(request, dataModel);
      _logRequestDetails(request);

      final response = await _sendRequest(request);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("Error registering for student prize: ${e.toString()}");
      rethrow;
    }
  }

  void _addFormFields(http.MultipartRequest request, StudentPrizeRegistrationData dataModel) {
    request.fields.addAll({
      'event_id': dataModel.eventId?.toString() ?? '',
      'member_id': dataModel.memberId?.toString() ?? '',
      'added_by': dataModel.addedBy?.toString() ?? '',
      'event_attendees_id': dataModel.eventAttendeesId?.toString() ?? '',
      'price_member_id': dataModel.priceMemberId?.toString() ?? '',
      'student_name': dataModel.studentName ?? '',
      'school_name': dataModel.schoolName ?? '',
      'standard_passed': dataModel.standardPassed ?? '',
      'year_of_passed': dataModel.yearOfPassed ?? '',
      'grade': dataModel.grade ?? '',
      'added_by': dataModel.addBy?.toString() ?? ''
    });
  }

  Future<void> _addFileIfExists(http.MultipartRequest request, StudentPrizeRegistrationData dataModel) async {
    if (dataModel.markSheetAttachment != null && dataModel.markSheetAttachment!.isNotEmpty) {
      final file = File(dataModel.markSheetAttachment!);
      if (await file.exists()) {
        request.files.add(await http.MultipartFile.fromPath('mark_sheet_attachment', file.path));
      }
    }
  }

  void _logRequestDetails(http.MultipartRequest request) {
    debugPrint('--- Student Prize Registration Request ---');
    debugPrint('Endpoint: ${request.url}');
    debugPrint('Fields: ${request.fields}');
    debugPrint('Files: ${request.files.map((f) => f.filename).join(", ")}');
    debugPrint('-----------------------------------------');
  }

  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response;
    } catch (e) {
      debugPrint('Error sending request: ${e.toString()}');
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final decoded = jsonDecode(response.body);

    if (response.statusCode == 400) {
      return {
        "status": true,
        // "message": decoded["message"] ?? "Student already registered for this prize.",
        "message": "Student already registered for this prize distribution.",
        "already_registered": true
      };
    }

    if (response.statusCode == 200) {
      return decoded;
    }

    throw HttpException(
      'Request failed with status ${response.statusCode}',
      uri: Uri.parse(Urls.student_prize_register_url),
    );
  }
}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mpm/model/ShikshaSahayata/CurrentYearEducationDetail/FlightTicketUpload/FlightTicketUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class FlightTicketUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<FlightTicketUploadModelClass> uploadFlightTicket({
    required String shikshaApplicantId,
    required String educationId,
    required String filePath,
  }) async {
    try {
      // Keys matching your Postman screenshot
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'shiksha_applicant_requested_loan_education_id': educationId,
        'applicant_flight_ticket_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_flight_ticket_document,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      debugPrint("✈️ Flight Ticket Upload Response: ${response.data}");

      return FlightTicketUploadModelClass.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("❌ Flight Ticket upload error: ${e.response?.data}");
      rethrow;
    }
  }
}
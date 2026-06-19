import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/ApplicantVisaUpload/ApplicantVisaUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ApplicantVisaUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<ApplicantVisaUploadModelClass> uploadApplicantVisa({
    required String shikshaApplicantId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'applicant_visa_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_visa_document, // Update this in your Urls class
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return ApplicantVisaUploadModelClass.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
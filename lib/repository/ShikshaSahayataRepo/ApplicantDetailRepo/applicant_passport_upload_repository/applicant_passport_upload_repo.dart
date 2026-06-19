import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/ApplicantPassportUpload/ApplicantPassportUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ApplicantPassportUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<ApplicantPassportUploadModelClass> uploadApplicantPassport({
    required String shikshaApplicantId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'applicant_passport_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_passport_document, // Update this in your Urls class
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return ApplicantPassportUploadModelClass.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
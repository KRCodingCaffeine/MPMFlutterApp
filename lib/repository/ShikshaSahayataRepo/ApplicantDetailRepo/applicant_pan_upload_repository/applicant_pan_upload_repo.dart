import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/ApplicantPanUpload/ApplicantPanUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class ApplicantPanRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: Urls.base_url, headers: {'Accept': 'application/json'}));

  Future<ApplicantPanUploadModelClass> uploadApplicantPan({
    required String shikshaApplicantId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'applicant_pan_card_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_pan_card_document,
        data: formData,
      );
      return ApplicantPanUploadModelClass.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
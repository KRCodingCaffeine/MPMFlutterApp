import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/FatherPanUpload/FatherPanUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class FatherPanUploadRepository {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: Urls.base_url,
      headers: {'Accept': 'application/json'},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  Future<FatherPanUploadModelClass> uploadFatherPanCard({
    required String shikshaApplicantId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'applicant_father_pan_card_document':
        await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_father_pan_card_document,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );

      return FatherPanUploadModelClass.fromJson(response.data);
    } on DioException catch (e) {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }
}

import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/OverseasFatherIncomeUpload/OverseasFatherIncomeUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class OverseasFatherIncomeRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: Urls.base_url, headers: {'Accept': 'application/json'}));

  Future<OverseasFatherIncomeUploadModelClass> uploadOverseasIncome({
    required String shikshaApplicantId,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'overseas_father_annual_income_document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _dio.post(
        Urls.upload_shiksha_applicant_overseas_father_annual_income_document,
        data: formData,
      );
      return OverseasFatherIncomeUploadModelClass.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}
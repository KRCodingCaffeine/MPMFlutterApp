import 'package:dio/dio.dart';
import 'package:mpm/model/ShikshaSahayata/ApplicantDetail/FatherAnnualIncomeUpload/FatherAnnualIncomeUploadModelClass.dart';
import 'package:mpm/utils/urls.dart';

class FatherAnnualIncomeUploadRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: Urls.base_url, headers: {'Accept': 'application/json'}));

  Future<FatherAnnualIncomeUploadModelClass> uploadFatherAnnualIncome({required String shikshaApplicantId, required String filePath}) async {
    try {
      final formData = FormData.fromMap({
        'shiksha_applicant_id': shikshaApplicantId,
        'father_annual_income_document': await MultipartFile.fromFile(filePath, filename: filePath.split('/').last),
      });
      final response = await _dio.post(Urls.upload_shiksha_applicant_father_annual_income_document, data: formData);
      return FatherAnnualIncomeUploadModelClass.fromJson(response.data);
    } catch (e) { rethrow; }
  }
}
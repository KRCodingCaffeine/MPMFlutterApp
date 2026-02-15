import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ReceivedLoan/UpdateReceivedLoan/UpdateReceivedLoanModelClass.dart';
import 'package:mpm/utils/urls.dart';

class UpdateReceivedLoanRepository {
  final api = NetWorkApiService();

  Future<UpdateReceivedLoanModelClass> updateReceivedLoan(
      Map<String, dynamic> body) async {
    final url = Urls.update_shiksha_applicant_received_loan;

    final response = await api.postApi(
      body.map((k, v) => MapEntry(k, v?.toString() ?? "")),
      url,
      "",
      "1",
    );

    return UpdateReceivedLoanModelClass.fromJson(response);
  }
}

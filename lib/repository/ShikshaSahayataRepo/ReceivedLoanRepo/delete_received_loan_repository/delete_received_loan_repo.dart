import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ReceivedLoan/DeleteReceivedLoan/DeleteReceivedLoanModelClass.dart';
import 'package:mpm/utils/urls.dart';

class DeleteReceivedLoanRepository {
  final api = NetWorkApiService();

  Future<DeleteReceivedLoanModelClass> deleteReceivedLoan(
      Map<String, dynamic> body) async {
    final url = Urls.delete_shiksha_applicant_received_loan;

    final response = await api.postApi(
      body.map((k, v) => MapEntry(k, v?.toString() ?? "")),
      url,
      "",
      "1",
    );

    return DeleteReceivedLoanModelClass.fromJson(response);
  }
}

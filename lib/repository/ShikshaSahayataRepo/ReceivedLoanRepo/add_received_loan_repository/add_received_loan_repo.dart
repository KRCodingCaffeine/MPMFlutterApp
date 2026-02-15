import 'package:mpm/data/network/network_api_Service.dart';
import 'package:mpm/model/ShikshaSahayata/ReceivedLoan/AddReceivedLoan/AddReceivedLoanModelClass.dart';
import 'package:mpm/utils/urls.dart';

class AddReceivedLoanRepository {
  final api = NetWorkApiService();

  Future<AddReceivedLoanModelClass> addReceivedLoan(
      Map<String, dynamic> body) async {
    final url = Urls.add_shiksha_applicant_received_loan;

    final response = await api.postApi(
      body.map((k, v) => MapEntry(k, v?.toString() ?? "")),
      url,
      "",
      "1",
    );

    return AddReceivedLoanModelClass.fromJson(response);
  }
}

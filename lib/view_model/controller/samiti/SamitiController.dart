import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/samiti/SamitiDetailData.dart';
import 'package:mpm/model/samiti/SamitiDetailModel.dart';
import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/model/search/SearchLMCodeModel.dart';
import 'package:mpm/repository/samiti_repository/samiti_repo.dart';

class SamitiController extends GetxController {
  final api = SamitiRepository();
  final rxStatusLoading = Status.IDLE.obs;
  var samitiData = "".obs;
  var loading = false.obs;
  var loading2 = false.obs;
  Map<String, dynamic>? parsedJson;
  Rxn<Map<String, dynamic>> getSamitidata = Rxn<Map<String, dynamic>>();
  var samitiName = "".obs;
  var samitiId = "".obs;
  var samitiDetailList = <SamitiDetailData>[].obs;
  var searchDataList = <SearchData>[].obs;

  void getSamitiType() async {
    loading.value = true;
    try {
      dynamic _value = await api.userSamitiApi();
      loading.value = false;
      parsedJson = _value;
      getSamitidata.value = parsedJson!['data'];
      print("dfddf" + parsedJson.toString());
    } catch (error) {
      loading.value = false;
      print("errorooooo" + error.toString());
    }
  }

  void getSamitiTypeDeatils() async {
    loading2.value = true;
    try {
      var response =
          await api.userSamitiDetailsApi(samitiId.value); // Await the response
      loading2.value = false;
      print("Response: " + response.toString());
      var data = SamitiDetailModel.fromJson(response);
      samitiDetailList.value = data.data!;
    } catch (error) {
      loading2.value = false;
      print("Error: " + error.toString());
    }
  }

  void getSearchLPM(String query) async {
    if (query.trim().isEmpty || query.trim().length < 4) {
      searchDataList.clear();
      return;
    }

    loading2.value = true;

    try {
      var response = await api.searchMember(query);
      var data = SearchLMCodeModel.fromJson(response);

      if (data.data != null && data.data!.isNotEmpty) {
        final searchText = query.toLowerCase().trim();

        var filteredList = data.data!.where((member) {
          final first = member.firstName?.toLowerCase() ?? '';
          final middle = member.middleName?.toLowerCase() ?? '';
          final last = member.lastName?.toLowerCase() ?? '';
          final mobile = member.mobile?.toLowerCase() ?? '';

          final nameCombos = [
            "$first $middle $last",
            "$first $last $middle",
            "$middle $first $last",
            "$middle $last $first",
            "$last $middle $first",
            "$last $first $middle",
            "$first $middle",
            "$middle $last",
            "$first $last",
            "$middle $first",
            "$last $first",
            "$last $middle",
          ];

          return nameCombos.any((combo) => combo.contains(searchText)) ||
              mobile.contains(searchText);
        }).toList();

        searchDataList.value.assignAll(filteredList);
      } else {
        searchDataList.value.clear();
      }
    } catch (error) {
      print("Error: $error");
      searchDataList.value.clear();
    } finally {
      loading2.value = false;
    }
  }
}

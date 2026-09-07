import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/GetProfile/GetProfileData.dart';
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
  var selectedMember = RxString('');

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
      var response = await api.userSamitiDetailsApi(samitiId.value);
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

  // In SamitiController.dart

  // LM Search
  void getSearchLM(String query) async {
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

        // Filter for LM members - Convert to int for comparison
        var membershipFilteredList = data.data!.where((member) {
          // Convert membershipTypeId to int, handling both String and int
          int typeId = 0;
          if (member.membershipTypeId != null) {
            if (member.membershipTypeId is String) {
              typeId = int.tryParse(member.membershipTypeId.toString()) ?? 0;
            } else if (member.membershipTypeId is int) {
              typeId = member.membershipTypeId as int;
            }
          }
          return typeId == 1; // 1 for LM members
        }).toList();

        var filteredList = membershipFilteredList.where((member) {
          final first = member.firstName?.toLowerCase() ?? '';
          final middle = member.middleName?.toLowerCase() ?? '';
          final last = member.lastName?.toLowerCase() ?? '';
          final mobile = member.mobile?.toLowerCase() ?? '';
          final code = member.memberCode?.toLowerCase() ?? '';

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
              mobile.contains(searchText) ||
              code.contains(searchText);
        }).toList();

        print('LM Filtered results: ${filteredList.length}');
        searchDataList.value.assignAll(filteredList);
      } else {
        searchDataList.value.clear();
      }
    } catch (error) {
      print("LM Search Error: $error");
      searchDataList.value.clear();
    } finally {
      loading2.value = false;
    }
  }

  // NM Search
  void getSearchNM(String query) async {
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

        // Filter for NM members - Convert to int for comparison
        var membershipFilteredList = data.data!.where((member) {
          // Convert membershipTypeId to int, handling both String and int
          int typeId = 0;
          if (member.membershipTypeId != null) {
            if (member.membershipTypeId is String) {
              typeId = int.tryParse(member.membershipTypeId.toString()) ?? 0;
            } else if (member.membershipTypeId is int) {
              typeId = member.membershipTypeId as int;
            }
          }
          return typeId == 2; // 2 for NM members
        }).toList();

        var filteredList = membershipFilteredList.where((member) {
          final first = member.firstName?.toLowerCase() ?? '';
          final middle = member.middleName?.toLowerCase() ?? '';
          final last = member.lastName?.toLowerCase() ?? '';
          final mobile = member.mobile?.toLowerCase() ?? '';
          final code = member.memberCode?.toLowerCase() ?? '';

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
              mobile.contains(searchText) ||
              code.contains(searchText);
        }).toList();

        print('NM Filtered results: ${filteredList.length}');
        searchDataList.value.assignAll(filteredList);
      } else {
        searchDataList.value.clear();
      }
    } catch (error) {
      print("NM Search Error: $error");
      searchDataList.value.clear();
    } finally {
      loading2.value = false;
    }
  }
}

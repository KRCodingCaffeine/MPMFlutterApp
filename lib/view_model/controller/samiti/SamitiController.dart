import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/samiti/SamitiDetailData.dart';
import 'package:mpm/model/samiti/SamitiDetailModel.dart';
import 'package:mpm/model/search/SearchData.dart';
import 'package:mpm/model/search/SearchLMCodeModel.dart';
import 'package:mpm/repository/samiti_repository/samiti_repo.dart';

class SamitiController extends  GetxController {
  final api = SamitiRepository();
  final rxStatusLoading = Status.IDLE.obs;
 var samitiData="".obs;
  var loading=false.obs;
  var loading2=false.obs;
  Map<String, dynamic>? parsedJson;
  Rxn<Map<String, dynamic>> getSamitidata = Rxn<Map<String, dynamic>>();
  var samitiName="".obs;
  var samitiId="".obs;
  var samitiDetailList=<SamitiDetailData>[].obs;
  var searchDataList=<SearchData>[].obs;

  void getSamitiType() async {
   loading.value=true;
   try {
      dynamic _value = await api.userSamitiApi();
       loading.value = false;
       parsedJson= _value;
       getSamitidata.value = parsedJson!['data'];
       print("dfddf" + parsedJson.toString());
   } catch (error) {
       loading.value = false;
       print("errorooooo" + error.toString());
   }

  }
  void getSamitiTypeDeatils() async {
    loading2.value=true;
    try {
      var response = await api.userSamitiDetailsApi(samitiId.value); // Await the response
      loading2.value = false;
      print("Response: " + response.toString());
      var data=SamitiDetailModel.fromJson(response);
      samitiDetailList.value = data.data!;
    } catch (error) {
      loading2.value = false;
      print("Error: " + error.toString());
    }
  }
  void getSearchLPM(var query) async {
    loading2.value=true;
    try {
      var response = await api.searchMember(query);

      print("Response: " + response.toString());
      var data=SearchLMCodeModel.fromJson(response);
    //  searchDataList.value = data.data!;
      if (response != null && response.isNotEmpty) {
        searchDataList.value.assignAll(data.data!);
      } else {
        searchDataList.value.clear();
      }
      loading2.value = false;
    } catch (error) {
      loading2.value = false;
      print("Error: " + error.toString());
    }
  }
}







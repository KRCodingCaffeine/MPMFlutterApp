import 'package:get/get.dart';
class DashBoardController extends GetxController{

  var currentIndex = 0.obs;
  var showAppBar = false.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
  void toggleAppBar(bool value) {
    showAppBar.value = value;
  }
   var userName = 'Karthika K Rajesh'.obs;
  var mobileNumber = '8898085105'.obs;
  var lmCode = 'LM0001'.obs;

}
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  var currentIndex = 0.obs;
  var showAppBar = false.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void toggleAppBar(bool value, {bool fromDrawer = false}) {
    showAppBar.value = value;
  }

  // User Data Variables (Only for Viewing)
  var userName = ''.obs;
  var memberId = ''.obs;
  var mobileNumber = ''.obs;
  var lmCode = ''.obs;
  var profileImage = ''.obs;
}

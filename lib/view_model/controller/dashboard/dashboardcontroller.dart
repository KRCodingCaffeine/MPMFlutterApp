import 'package:get/get.dart';
class DashBoardController extends GetxController{

  var currentIndex = 0.obs;

  // Update the tab index
  void changeTab(int index) {
    currentIndex.value = index;
  }
}
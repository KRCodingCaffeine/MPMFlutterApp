import 'package:get/get.dart';
import 'package:mpm/data/response/status.dart';
import 'package:mpm/model/Zone/ZoneData.dart';
import 'package:mpm/repository/zone_repository/zone_repo.dart';

class ZoneController extends GetxController {
  final ZoneRepository api = ZoneRepository();

  var rxRequestStatus = Status.INITIAL.obs;
  var zoneList = <ZoneData>[].obs;

  void setRxRequestState(Status status) {
    rxRequestStatus.value = status;
  }

  void getZone() {
    setRxRequestState(Status.LOADING);

    api.ZoneApi().then((_value) {
      setRxRequestState(Status.COMPLETE);
      zoneList.value = _value.data ?? [];
    }).onError((error, stackTrace) {
      setRxRequestState(Status.ERROR);
      print("Zone API Error: $error");
    });
  }
}

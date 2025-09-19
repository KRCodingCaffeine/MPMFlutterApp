import 'package:get/get.dart';
import 'package:mpm/model/Offer/OfferData.dart';
import 'package:mpm/model/Offer/OfferModelClass.dart';
import 'package:mpm/repository/offer_repository/offer_repo.dart';

class OfferController extends GetxController {
  var isLoading = true.obs;
  var offerList = <OfferData>[].obs;

  final OfferRepository _offerRepo = OfferRepository();

  @override
  void onInit() {
    super.onInit();
    fetchOffers();
  }

  void fetchOffers() async {
    try {
      isLoading(true);
      final response = await _offerRepo.fetchOfferDiscounts();
      OfferModelClass model = OfferModelClass.fromJson(response);

      if (model.status == true && model.data != null) {
        offerList.value = model.data!;
      } else {
        offerList.clear();
      }
    } catch (e) {
      offerList.clear();
    } finally {
      isLoading(false);
    }
  }
}

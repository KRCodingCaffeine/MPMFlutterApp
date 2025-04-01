import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/view/payment/PaymentScreen.dart';
import 'package:mpm/view/payment/PaymentService.dart';

class PaymentController extends GetxController {
  var isLoading = false.obs;
  void startICICIPayment(double amount) async {

      try {
        isLoading(true);
        String orderId = "ORDER" + DateTime.now().millisecondsSinceEpoch.toString();
        String paymentUrl = await PaymentService.initiateICICIPayment(amount, orderId);

        // Navigate to Payment Screen
        var result = await Get.to(() => PaymentScreen(paymentUrl: paymentUrl));

        if (result == "Success") {
          Get.snackbar("Payment Success", "Your transaction was successful!",
              backgroundColor: Colors.green, colorText: Colors.white);
        } else {
          Get.snackbar("Payment Failed", "Your transaction could not be completed.",
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        Get.snackbar("Error", e.toString(),
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading(false);
      }
    }






}
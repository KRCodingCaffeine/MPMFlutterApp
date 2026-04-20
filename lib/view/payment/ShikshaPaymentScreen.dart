import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/utils/color_helper.dart';
import 'package:mpm/utils/color_resources.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/payment/CustomDialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ShikshaPaymentScreen extends StatefulWidget {
  final String shikshaApplicantId;
  final String loanAmount;
  final String paymentAmount;

  ShikshaPaymentScreen({
    super.key,
    required this.shikshaApplicantId,
    required this.loanAmount,
    required this.paymentAmount,
  });

  @override
  _ShikshaPaymentScreenState createState() => _ShikshaPaymentScreenState();
}

class _ShikshaPaymentScreenState extends State<ShikshaPaymentScreen> {
  late final WebViewController controller;
  bool isControllerReady = false;
  @override
  void initState() {
    super.initState();
    loadWebview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor:
            ColorHelperClass.getColorFromHex(ColorResources.logo_color),
        title: Builder(
          builder: (context) {
            double fontSize = MediaQuery.of(context).size.width * 0.045;
            return Text(
              "ICICI Payment",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            );
          },
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isControllerReady
          ? WebViewWidget(controller: controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }

  void loadWebview() async {
    final paymentUri = Uri.parse(Urls.shiksha_payment_url).replace(
      queryParameters: {
        'shiksha_applicant_id': widget.shikshaApplicantId,
        'loan_amount': widget.loanAmount,
        'loan_repayment_amount': widget.paymentAmount,
      },
    );

    final webViewController = WebViewController();
    webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'PaymentStatusChannel',
        onMessageReceived: (JavaScriptMessage message) {
          print("Payment response: ${message.message}");

          // Parse the message to JSON
          final jsonResponse = jsonDecode(message.message);
          final paymentStatus = jsonResponse['payment_status'];
          print("ffffff" + jsonResponse.toString() + "pay" + paymentStatus);

          if (paymentStatus == "completed") {
            Get.back(result: "Success");
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                title: "Success",
                description: "Payment Successfully",
                buttonText: "Okay",
                image: Image.asset(Images.sucess),
              ),
            );
          } else {
            Get.back(result: "Failed");
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                title: "Cancel",
                description: "Payment failed",
                buttonText: "Okay",
                image: Image.asset(Images.cancel),
              ),
            );
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            print("Page loaded: $url");
            await webViewController.runJavaScript("""
            try {
              var bodyText = document.body.innerText;
              PaymentStatusChannel.postMessage(bodyText);
            } catch (e) {
              PaymentStatusChannel.postMessage("ERROR: " + e.toString());
            }
          """);
          },
        ),
      )
      ..loadRequest(paymentUri);

    setState(() {
      controller = webViewController;
      isControllerReady = true;
    });
  }
}

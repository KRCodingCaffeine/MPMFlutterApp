import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mpm/model/CheckUser/CheckUserData2.dart';
import 'package:mpm/utils/Session.dart';
import 'package:mpm/utils/images.dart';
import 'package:mpm/utils/urls.dart';
import 'package:mpm/view/payment/CustomDialog.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String paymentAmount;

  PaymentScreen({required this.paymentAmount});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController controller;
  var memberid="";
  bool isControllerReady = false;
  @override
  void initState() {
    super.initState();
    loadWebview();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ICICI Payment")),
      body: isControllerReady
          ? WebViewWidget(controller: controller!)
          : Center(child: CircularProgressIndicator()),
    );
  }
  void loadWebview() async{
    CheckUserData2? userData = await SessionManager.getSession();
    var memberid=userData!.memberId.toString();

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
          print("ffffff"+jsonResponse.toString()+"pay"+paymentStatus);

          if (paymentStatus == "completed") {
            Get.back(result: "Success");
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                title: "Success",
                description:
                "Payment Successfully",
                buttonText: "Okay", image: Image.asset(Images.sucess),
              ),
            );
          } else {
            Get.back(result: "Failed");
            showDialog(
              context: context,
              builder: (BuildContext context) => CustomDialog(
                title: "Cancel",
                description:
                "Payment failed",
                buttonText: "Okay", image: Image.asset(Images.cancel),
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
      ..loadRequest(Uri.parse("${Urls.payment_url}?member_id=$memberid&&amount=${widget.paymentAmount}"));

    setState(() {
      controller = webViewController;
      isControllerReady = true;
    });
  }
}

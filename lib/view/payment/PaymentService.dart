import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mpm/utils/urls.dart';
class PaymentService {

  static Future<String> initiateICICIPayment(double amount, String orderId) async {
    final String apiUrl = "https://payuatrbac.icicibank.com/payment-capture/";
    print("api:::"+apiUrl.toString());

    Map<String, String> headers = {
      "Content-Type": "application/json",

    };

    Map<String, String> requestBody = {
      "merchantId": "100000000005859",
      "ENC_KEY":"1FF49170C8CCECFF1345B38F971CABBD",
      "SECURE_SECRET":"5FF1003BD85EC13EDDE106AC235F58AD",
      "CURRENCY_CODE":"356",
      "TERMINALID":"EG000488",
      "PASSCODE":"ABCD1234",
      "BANKID":"24520",
      "MCC":"8641",
      "VERSION":"1",
      "amount": amount.toString(),
      "TxnRefNo":"or123",
      "TxnType":"Pay",
      "FirstName":"Shivani",
      "LastName":"Singh",
      "redirectUrl": Urls.base_url+"payment/paymentResponse",
      "cancelUrl": "https://payuatrbac.icicibank.com/accesspoint/v1/24520/checkStatusMerchantKit",
      "customerEmail": "user@example.com",
      "customerPhone": "9876543210",
    };
    print("datasend:"+requestBody.toString());


    final response = await http.post(Uri.parse(apiUrl),
        headers: headers, body: jsonEncode(requestBody));
    print("vnbv"+response.statusCode.toString());

    if (response.statusCode == 200) {
      var responseData = jsonDecode(response.body);
      return responseData["paymentUrl"]; // URL to redirect user
    } else {
      throw Exception("Failed to initiate payment");
    }
  }

}
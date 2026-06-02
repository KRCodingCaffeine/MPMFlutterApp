import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mpm/model/PaymentTransactionId/PaymentTransactionIdModelClass.dart';
import 'package:mpm/utils/urls.dart';

class PaymentTransactionRepository {
  Future<PaymentTransactionIdModelClass> updatePaymentTransaction({
    required String eventId,
    required String memberId,
    required String paymentTransactionId,
  }) async {
    try {
      final uri = Uri.parse(
        Urls.updateEventPaymentTransactionUrl,
      );

      final response = await http.post(
        uri,
        body: {
          'event_id': eventId,
          'member_id': memberId,
          'payment_transaction_id': paymentTransactionId,
        },
      );

      debugPrint(
          'Update Payment Transaction Response: ${response.body}');

      if (response.statusCode == 200) {
        return PaymentTransactionIdModelClass.fromJson(
          jsonDecode(response.body),
        );
      }

      throw HttpException(
        'Failed with status code ${response.statusCode}',
      );
    } catch (e) {
      debugPrint(
        'Update Payment Transaction Error: ${e.toString()}',
      );
      rethrow;
    }
  }
}
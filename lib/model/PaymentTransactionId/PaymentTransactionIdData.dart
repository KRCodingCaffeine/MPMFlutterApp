class PaymentTransactionIdData {
  String? eventId;
  String? memberId;
  String? paymentTransactionId;

  PaymentTransactionIdData({
    this.eventId,
    this.memberId,
    this.paymentTransactionId,
  });

  factory PaymentTransactionIdData.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionIdData(
      eventId: json['event_id']?.toString(),
      memberId: json['member_id']?.toString(),
      paymentTransactionId: json['payment_transaction_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'member_id': memberId,
      'payment_transaction_id': paymentTransactionId,
    };
  }
}
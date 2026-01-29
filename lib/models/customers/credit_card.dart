import 'dart:convert';

class CreditCard {
  CreditCard({
    required this.creditCardId,
    required this.type,
    required this.token,
    required this.automatic,
    required this.customerFk,
  });

  int creditCardId;
  String type;
  String token;
  bool automatic;
  int customerFk;

  String get last4Digits => token.substring(token.length - 4);

  factory CreditCard.fromJson(String str) => CreditCard.fromMap(json.decode(str));

  factory CreditCard.fromMap(Map<String, dynamic> json) {
    CreditCard creditCard = CreditCard(
      creditCardId: json["credit_card_id"],
      type: json['type'] ?? 'Credit Card',
      token: json['token'],
      automatic: json['automatic'] ?? true,
      customerFk: json['customer_fk'],
    );

    return creditCard;
  }
}

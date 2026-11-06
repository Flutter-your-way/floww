import 'package:floww/config/entities/subscription_entity.dart';

class StoreOffer {
  const StoreOffer({
    required this.term,
    required this.productId,
    required this.price,
    required this.priceLabel,
    required this.currencyCode,
    this.freeTrialLabel,
  });

  final SubscriptionTerm term;
  final String productId;
  final double price;
  final String priceLabel;
  final String currencyCode;
  final String? freeTrialLabel;
}

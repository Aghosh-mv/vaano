import 'package:flutter/foundation.dart';
import '../models/subscription_plan.dart';

class SubscriptionService extends ChangeNotifier {
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  static const List<SubscriptionPlan> plans = [
    SubscriptionPlan(
      name: 'Free',
      price: '₹0',
      period: 'forever',
      features: [
        'Basic Photo & Video Editing',
        'Limited AI Usage (5/day)',
        'Watermarked Export',
        '720p Export',
        'Basic Filters & Effects',
      ],
    ),
    SubscriptionPlan(
      name: 'Premium',
      price: '₹299',
      period: '/month',
      features: [
        'Unlimited AI Features',
        'No Watermark',
        '4K Export',
        'Premium Malayalam Music Library',
        'AI Voice Cloning',
        'Priority Support',
        'Cloud Backup',
        'Ad-Free Experience',
      ],
      isPopular: true,
    ),
    SubscriptionPlan(
      name: 'Yearly',
      price: '₹2,999',
      period: '/year',
      features: [
        'Everything in Premium',
        '2 Months Free',
        'Early Access to New Features',
        'Exclusive Templates',
      ],
    ),
  ];

  Future<bool> purchasePremium() async {
    await Future.delayed(const Duration(seconds: 2));
    _isPremium = true;
    notifyListeners();
    return true;
  }

  Future<bool> purchaseYearly() async {
    await Future.delayed(const Duration(seconds: 2));
    _isPremium = true;
    notifyListeners();
    return true;
  }

  void restorePurchase() {
    _isPremium = false;
    notifyListeners();
  }
}

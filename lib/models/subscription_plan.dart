class SubscriptionPlan {
  final String name;
  final String price;
  final String period;
  final List<String> features;
  final bool isPopular;
  final bool isCurrent;

  const SubscriptionPlan({
    required this.name,
    required this.price,
    required this.period,
    required this.features,
    this.isPopular = false,
    this.isCurrent = false,
  });
}

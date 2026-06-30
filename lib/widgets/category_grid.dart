import 'package:flutter/material.dart';
import '../models/feature_item.dart';
import 'feature_card.dart';

class CategoryGrid extends StatelessWidget {
  final List<FeatureItem> features;
  final int crossAxisCount;

  const CategoryGrid({
    super.key,
    required this.features,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.85,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final item = features[index];
          return FeatureCard(
            icon: item.icon,
            title: item.title,
            color: item.color,
            isPremium: item.isPremium,
            onTap: () {
              if (item.route.isNotEmpty) {
                Navigator.pushNamed(context, item.route);
              }
            },
          );
        },
      ),
    );
  }
}

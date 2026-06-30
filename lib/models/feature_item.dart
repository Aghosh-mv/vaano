import 'package:flutter/material.dart';

class FeatureItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;
  final bool isPremium;

  const FeatureItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
    this.isPremium = false,
  });
}

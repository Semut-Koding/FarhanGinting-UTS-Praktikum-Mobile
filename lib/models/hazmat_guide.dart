import 'package:flutter/material.dart';

class HazmatGuide {
  HazmatGuide({
    required this.unClass,
    required this.title,
    required this.icon,
    required this.color,
    required this.rules,
    this.isExpanded = false,
  });

  final String unClass;
  final String title;
  final IconData icon;
  final Color color;
  final List<String> rules;
  bool isExpanded;
}

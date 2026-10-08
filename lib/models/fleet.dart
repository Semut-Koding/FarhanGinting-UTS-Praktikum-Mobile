import 'package:flutter/material.dart';

class Fleet {
  const Fleet({
    required this.id,
    required this.name,
    required this.type,
    required this.plateNumber,
    required this.maxCapacityTon,
    required this.ratePerTon,
    required this.baseRate,
    required this.dimension,
    required this.available,
    required this.color,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final String type;
  final String plateNumber;
  final double maxCapacityTon;
  final int ratePerTon;
  final int baseRate;
  final String dimension;
  final int available;
  final Color color;

  final String imageAsset;

  String get heroTag => 'fleet-photo-$id';
}

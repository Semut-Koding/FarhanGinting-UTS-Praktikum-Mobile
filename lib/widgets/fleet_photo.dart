import 'package:flutter/material.dart';

import '../models/fleet.dart';

class FleetPhoto extends StatelessWidget {
  const FleetPhoto({
    super.key,
    required this.fleet,
    this.size = 68,
    this.radius = 14,
    this.iconSize,
  });

  final Fleet fleet;
  final double size;
  final double radius;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          fleet.imageAsset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) =>
              _Illustration(fleet: fleet, iconSize: iconSize ?? size * 0.5),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.fleet, required this.iconSize});

  final Fleet fleet;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [fleet.color, Color.lerp(fleet.color, Colors.black, 0.35)!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -iconSize * 0.3,
            top: -iconSize * 0.3,
            child: Container(
              width: iconSize * 1.2,
              height: iconSize * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.local_shipping_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
        ],
      ),
    );
  }
}

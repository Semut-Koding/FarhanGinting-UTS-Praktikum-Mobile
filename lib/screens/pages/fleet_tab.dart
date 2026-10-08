import 'package:flutter/material.dart';

import '../../data/dummy_data.dart';
import '../../models/fleet.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/fleet_photo.dart';

class FleetTab extends StatelessWidget {
  const FleetTab({super.key, required this.onSelectFleet});

  final ValueChanged<Fleet> onSelectFleet;

  @override
  Widget build(BuildContext context) {
    const fleets = DummyData.fleets;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: fleets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const FadeSlideIn(child: _SummaryBanner());
        }
        final fleet = fleets[index - 1];
        return FadeSlideIn(
          delay: Duration(milliseconds: 120 * index),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _FleetCard(
              fleet: fleet,
              onSelect: () => onSelectFleet(fleet),
            ),
          ),
        );
      },
    );
  }
}

class _FleetCard extends StatelessWidget {
  const _FleetCard({required this.fleet, required this.onSelect});

  final Fleet fleet;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            minLeadingWidth: 80,
            leading: SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Hero(
                    tag: fleet.heroTag,
                    child: FleetPhoto(fleet: fleet, size: 72),
                  ),

                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        '${fleet.maxCapacityTon.toStringAsFixed(0)} T',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            title: Text(
              fleet.name,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppColors.navy,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(fleet.type),
                  const SizedBox(height: 2),
                  Text(
                    'Dimensi ${fleet.dimension}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            isThreeLine: true,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${fleet.available} unit',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mulai dari',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        Fmt.rupiah(fleet.baseRate),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  key: Key('pilih-${fleet.id}'),
                  onPressed: onSelect,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    backgroundColor: AppColors.navy,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    textStyle: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  icon: const Icon(Icons.add_task_rounded, size: 18),
                  label: const Text('Pilih Armada'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner();

  @override
  Widget build(BuildContext context) {
    final totalUnits = DummyData.fleets.fold<int>(
      0,
      (sum, f) => sum + f.available,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Armada siap jalan hari ini',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: totalUnits),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, _) => Text(
                    '$value Unit',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DummyData.fleets.length} jenis armada • Depo Subang',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.fire_truck_rounded,
            color: AppColors.amber,
            size: 56,
          ),
        ],
      ),
    );
  }
}

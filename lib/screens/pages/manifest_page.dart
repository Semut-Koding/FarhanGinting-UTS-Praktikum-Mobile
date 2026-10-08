import 'package:flutter/material.dart';

import '../../models/fleet.dart';
import '../../theme/app_theme.dart';
import 'fleet_tab.dart';
import 'hazmat_tab.dart';

class ManifestPage extends StatelessWidget {
  const ManifestPage({super.key, required this.onSelectFleet});

  final ValueChanged<Fleet> onSelectFleet;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: AppColors.navy,
            child: const TabBar(
              indicatorColor: AppColors.orange,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.label,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              dividerColor: Colors.transparent,
              labelStyle: TextStyle(fontWeight: FontWeight.w700),
              tabs: [
                Tab(
                  icon: Icon(Icons.local_shipping_outlined),
                  text: 'Armada Tersedia',
                ),
                Tab(
                  icon: Icon(Icons.warning_amber_rounded),
                  text: 'Syarat Muatan Berbahaya',
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                FleetTab(onSelectFleet: onSelectFleet),
                const HazmatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

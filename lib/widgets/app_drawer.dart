import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectMenu,
    required this.onLogout,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelectMenu;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            margin: EdgeInsets.zero,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '● On Duty',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  DummyData.fleetUnit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Nopol ${DummyData.fleetPlate} • ${DummyData.staffName}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _menu(
            0,
            Icons.inventory_2_outlined,
            'Manifes Muatan',
            'Armada & syarat muatan',
          ),
          _menu(
            1,
            Icons.receipt_long_outlined,
            'Rekap Resi',
            'Data surat jalan',
          ),
          _menu(
            2,
            Icons.warehouse_outlined,
            'Informasi Depo',
            'Gudang utama & API tracking',
          ),
          const Spacer(),
          const Divider(indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: AppColors.danger),
            title: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onLogout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _menu(int index, IconData icon, String title, String subtitle) {
    final selected = index == selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: ListTile(
        selected: selected,
        selectedTileColor: AppColors.orange.withValues(alpha: 0.12),
        selectedColor: AppColors.orange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: AnimatedRotation(
          turns: selected ? 0 : -0.25,
          duration: const Duration(milliseconds: 300),
          child: Icon(
            Icons.chevron_right_rounded,
            color: selected ? AppColors.orange : Colors.grey,
          ),
        ),
        onTap: () => onSelectMenu(index),
      ),
    );
  }
}

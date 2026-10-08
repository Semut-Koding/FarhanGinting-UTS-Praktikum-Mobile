import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../models/fleet.dart';
import '../models/waybill.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_drawer.dart';
import 'cargo_booking_screen.dart';
import 'login_screen.dart';
import 'pages/depot_info_page.dart';
import 'pages/manifest_page.dart';
import 'pages/receipt_recap_page.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Waybill> _waybills = DummyData.initialWaybills();
  int _selectedIndex = 0;

  static const List<String> _titles = [
    'Manifes Muatan',
    'Rekap Resi',
    'Informasi Depo',
  ];

  void _onSelectMenu(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _openBooking(Fleet fleet) async {
    final result = await Navigator.of(
      context,
    ).push<Waybill>(AppRoute.slideUp(CargoBookingScreen(fleet: fleet)));
    if (!mounted || result == null) return;

    setState(() => _waybills.insert(0, result));

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 5),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Surat jalan ${result.resiNumber} berhasil diterbitkan • '
                  '${result.fleetName} • ${Fmt.rupiah(result.totalCost)}',
                ),
              ),
            ],
          ),
          action: SnackBarAction(
            label: 'LIHAT',
            textColor: Colors.white,
            onPressed: () => _onSelectMenu(1),
          ),
        ),
      );
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    final confirm = await showAnimatedDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
        title: const Text('Keluar Aplikasi?'),
        content: const Text('Sesi staf lapangan akan diakhiri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Keluar',
              style: TextStyle(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      Navigator.of(
        context,
      ).pushReplacement(AppRoute.fadeScale(const LoginScreen()));
    }
  }

  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return ManifestPage(onSelectFleet: _openBooking);
      case 1:
        return ReceiptRecapPage(waybills: _waybills);
      default:
        return const DepotInfoPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Text(_titles[_selectedIndex], key: ValueKey(_selectedIndex)),
        ),
        actions: [
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {},
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.notifications_none_rounded),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onSelectMenu: (index) {
          Navigator.pop(context);
          _onSelectMenu(index);
        },
        onLogout: _logout,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_selectedIndex), child: _buildPage()),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onSelectMenu,
        selectedItemColor: AppColors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Manifes Muatan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Rekap Resi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warehouse_outlined),
            activeIcon: Icon(Icons.warehouse_rounded),
            label: 'Informasi Depo',
          ),
        ],
      ),
    );
  }
}

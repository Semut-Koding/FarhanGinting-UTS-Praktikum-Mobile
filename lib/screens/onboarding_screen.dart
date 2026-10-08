import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

class _OnboardingItem {
  const _OnboardingItem({
    required this.icon,
    required this.satellites,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final List<IconData> satellites;
  final String title;
  final String description;
  final Color color;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.inventory_2_rounded,
      satellites: [Icons.qr_code_2, Icons.checklist_rounded, Icons.scale],
      title: 'Catat Manifes Muatan',
      description:
          'Rekam detail kargo, kategori muatan, dan tonase langsung dari lapangan tanpa kertas.',
      color: AppColors.orange,
    ),
    _OnboardingItem(
      icon: Icons.local_shipping_rounded,
      satellites: [Icons.route_rounded, Icons.ac_unit, Icons.speed_rounded],
      title: 'Pilih Armada yang Tepat',
      description:
          'Colt Diesel, Fuso, hingga Tronton — sesuaikan armada dengan kapasitas dan jenis muatan.',
      color: Color(0xFF2A9D8F),
    ),
    _OnboardingItem(
      icon: Icons.receipt_long_rounded,
      satellites: [
        Icons.event_available,
        Icons.verified_rounded,
        Icons.payments_rounded,
      ],
      title: 'Terbitkan Surat Jalan',
      description:
          'Atur jadwal penjemputan, hitung biaya logistik, dan pantau rekap resi secara terstruktur.',
      color: Color(0xFF4F83CC),
    ),
  ];

  bool get _isLastPage => _currentPage == _items.length - 1;

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushReplacement(AppRoute.fadeScale(const LoginScreen()));
  }

  void _next() {
    if (_isLastPage) {
      _goToLogin();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _items[_currentPage].color;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.navy,
              Color.lerp(AppColors.navy, activeColor, 0.35)!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    const AppLogo(size: 40),
                    const SizedBox(width: 10),
                    const Text(
                      'CargoFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const Spacer(),
                    AnimatedOpacity(
                      opacity: _isLastPage ? 0 : 1,
                      duration: const Duration(milliseconds: 300),
                      child: TextButton(
                        onPressed: _isLastPage ? null : _goToLogin,
                        child: const Text(
                          'Lewati',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    return AnimatedBuilder(
                      animation: _pageController,
                      builder: (context, child) {
                        double delta = 0;
                        if (_pageController.position.haveDimensions) {
                          delta = (_pageController.page ?? 0) - index;
                        } else {
                          delta = (_currentPage - index).toDouble();
                        }
                        return _OnboardingPage(
                          item: _items[index],
                          delta: delta.clamp(-1.0, 1.0),
                        );
                      },
                    );
                  },
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_items.length, (index) {
                  final active = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: active ? 28 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? activeColor : Colors.white24,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(backgroundColor: activeColor),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axis: Axis.horizontal,
                        child: child,
                      ),
                    ),
                    child: Row(
                      key: ValueKey(_isLastPage),
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_isLastPage ? 'Mulai Sekarang' : 'Lanjut'),
                        const SizedBox(width: 8),
                        Icon(
                          _isLastPage
                              ? Icons.rocket_launch_rounded
                              : Icons.arrow_forward_rounded,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.item, required this.delta});

  final _OnboardingItem item;
  final double delta;

  @override
  Widget build(BuildContext context) {
    final visibility = 1 - delta.abs();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(
            offset: Offset(delta * 120, 0),
            child: Transform.scale(
              scale: 0.75 + 0.25 * visibility,
              child: Opacity(
                opacity: visibility.clamp(0.0, 1.0),
                child: _Illustration(item: item, rotation: delta),
              ),
            ),
          ),
          const SizedBox(height: 48),
          Transform.translate(
            offset: Offset(delta * 60, 0),
            child: Opacity(
              opacity: visibility.clamp(0.0, 1.0),
              child: Column(
                children: [
                  Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    item.description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.item, required this.rotation});

  final _OnboardingItem item;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    const double size = 240;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.color.withValues(alpha: 0.12),
            ),
          ),
          Container(
            width: size * 0.7,
            height: size * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.color.withValues(alpha: 0.22),
            ),
          ),
          Container(
            width: size * 0.45,
            height: size * 0.45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.color,
              boxShadow: [
                BoxShadow(
                  color: item.color.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 56),
          ),

          for (var i = 0; i < item.satellites.length; i++)
            Transform.translate(
              offset: Offset.fromDirection(
                (i * 2 * math.pi / item.satellites.length) -
                    math.pi / 2 +
                    rotation * math.pi / 2,
                size * 0.43,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Icon(item.satellites[i], color: item.color, size: 22),
              ),
            ),
        ],
      ),
    );
  }
}

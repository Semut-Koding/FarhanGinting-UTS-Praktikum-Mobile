import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/dummy_data.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/app_logo.dart';
import '../widgets/fade_slide_in.dart';
import 'main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _staffIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late final AnimationController _shakeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _staffIdController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: AppColors.background,
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.orange, width: 2),
      ),
    );
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final staffId = _staffIdController.text.trim();
    final password = _passwordController.text;

    if (staffId.isEmpty || password.isEmpty) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.navy,
            content: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.amber),
                SizedBox(width: 12),
                Expanded(child: Text('ID Staf dan Kata Sandi wajib diisi.')),
              ],
            ),
          ),
        );
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (staffId == DummyData.staffId && password == DummyData.password) {
      Navigator.of(
        context,
      ).pushReplacement(AppRoute.fadeScale(const MainNavigationScreen()));
    } else {
      _shakeController.forward(from: 0);
      showAnimatedDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.gpp_bad_rounded,
            color: AppColors.danger,
            size: 48,
          ),
          title: const Text('Login Gagal'),
          content: const Text(
            'ID Staf atau Kata Sandi yang Anda masukkan salah. '
            'Silakan periksa kembali data Anda.',
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(140, 44)),
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.height),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + 48,
                  bottom: 88,
                ),
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Column(
                  children: [
                    const AppLogo(size: 84),
                    const SizedBox(height: 18),
                    const FadeSlideIn(
                      delay: Duration(milliseconds: 200),
                      child: Text(
                        'Selamat Datang',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 300),
                      child: Text(
                        'Masuk untuk mengelola operasional kargo',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                transform: Matrix4.translationValues(0, -32, 0),
                constraints: BoxConstraints(minHeight: size.height * 0.6),
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final dx =
                        math.sin(_shakeController.value * math.pi * 6) *
                        12 *
                        (1 - _shakeController.value);
                    return Transform.translate(
                      offset: Offset(dx, 0),
                      child: child,
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FadeSlideIn(
                        delay: Duration(milliseconds: 350),
                        child: Text(
                          'Login Staf Lapangan',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 450),
                        child: TextField(
                          key: const Key('staffIdField'),
                          controller: _staffIdController,
                          textInputAction: TextInputAction.next,
                          decoration: _decoration(
                            label: 'ID Staf',
                            hint: 'Masukkan ID Staf (contoh: petugas)',
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 550),
                        child: TextField(
                          key: const Key('passwordField'),
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _login(),
                          decoration: _decoration(
                            label: 'Kata Sandi',
                            hint: 'Masukkan kata sandi',
                            icon: Icons.lock_outline_rounded,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 650),
                        child: FilledButton(
                          key: const Key('loginButton'),
                          onPressed: _isLoading ? null : _login,
                          style: FilledButton.styleFrom(
                            disabledBackgroundColor: AppColors.orange
                                .withValues(alpha: 0.7),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _isLoading
                                ? const SizedBox(
                                    key: ValueKey('loading'),
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Row(
                                    key: ValueKey('label'),
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text('Masuk'),
                                      SizedBox(width: 8),
                                      Icon(Icons.login_rounded, size: 20),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 750),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                color: AppColors.orange,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Akun demo — ID Staf: petugas, Kata Sandi: 1234',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

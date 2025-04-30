import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:photo_manager/photo_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();

    // Konfigurasi animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();

    // Periksa izin dan arahkan ke halaman utama
    _checkPermissionsAndNavigate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndNavigate() async {
    // Berikan waktu splash screen muncul sebentar
    await Future.delayed(const Duration(seconds: 2));

    // Minta izin untuk akses penyimpanan
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    setState(() {
      _permissionsChecked = true;
    });

    // Tunggu animasi selesai jika belum
    if (!_animationController.isCompleted) {
      await _animationController.forward().orCancel;
    }

    // Navigasi ke halaman utama
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.accentColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Gambar
              FadeTransition(
                opacity: _animation,
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_search,
                            size: 80,
                            color: AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Judul aplikasi
              FadeTransition(
                opacity: _animation,
                child: const Text(
                  'Pengolahan Citra',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              FadeTransition(
                opacity: _animation,
                child: Text(
                  'Praktikum Pengolahan Citra Digital',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Loading indicator
              FadeTransition(
                opacity: _animation,
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _permissionsChecked
                          ? 'Memulai aplikasi...'
                          : 'Memeriksa izin...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_edit_photo_app/constants/app_theme.dart';
import 'package:flutter_edit_photo_app/screens/home_screen.dart';
import 'package:flutter_edit_photo_app/screens/demo_screen.dart';
import 'package:flutter_edit_photo_app/screens/splash_screen.dart';
import 'package:flutter_edit_photo_app/services/image_provider.dart';
import 'package:flutter_edit_photo_app/services/demo_image_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ImageEditorProvider()),
        ChangeNotifierProvider(create: (context) => DemoImageProvider()),
      ],
      child: MaterialApp(
        title: 'Image Processing App',
        theme: AppTheme.lightTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
          '/': (context) => const HomeScreen(),
          '/demo': (context) => const DemoScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// TryOn App - Main Entry Point
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';
import 'providers/providers.dart';
import 'screens/splash/animated_splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Set system UI overlay style - edge to edge
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarContrastEnforced: false,
  ));
  
  // Enable edge-to-edge mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  
  runApp(const ProviderScope(child: TryOnApp()));
}

class TryOnApp extends ConsumerStatefulWidget {
  const TryOnApp({super.key});

  @override
  ConsumerState<TryOnApp> createState() => _TryOnAppState();
}

class _TryOnAppState extends ConsumerState<TryOnApp> {
  bool _showSplash = true;

  void _onSplashComplete() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    // Show animated splash screen
    if (_showSplash || authState.isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: AnimatedSplashScreen(onAnimationComplete: _onSplashComplete),
      );
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'TryOn',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}

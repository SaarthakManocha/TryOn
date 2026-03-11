// App Router - GoRouter navigation configuration
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../screens/auth/auth.dart';
import '../screens/onboarding/onboarding.dart';
import '../screens/main/main.dart';
import '../screens/main/settings_screen.dart';
import '../screens/main/edit_profile_screen.dart';
import '../screens/main/edit_body_info_screen.dart';
import '../screens/main/edit_preferences_screen.dart';
import '../theme/app_theme.dart';

// Main Shell for bottom navigation
class MainShell extends StatefulWidget {
  final Widget child;
  final int currentIndex;

  const MainShell({super.key, required this.child, required this.currentIndex});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/main/home');
        break;
      case 1:
        context.push('/tryon');
        break;
      case 2:
        context.go('/main/wardrobe');
        break;
      case 3:
        context.go('/main/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        height: 80 + bottomPadding,
        padding: EdgeInsets.only(bottom: bottomPadding),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.surfaceLight.withOpacity(0.3))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(0, '🏠', 'Home', widget.currentIndex == 0, () => _onItemTapped(0, context)),
            _buildTabItem(1, '📸', 'Try On', false, () => _onItemTapped(1, context)),
            _buildTabItem(2, '👗', 'Wardrobe', widget.currentIndex == 2, () => _onItemTapped(2, context)),
            _buildTabItem(3, '👤', 'Profile', widget.currentIndex == 3, () => _onItemTapped(3, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: TextStyle(fontSize: 24, color: isActive ? null : AppColors.textMuted.withOpacity(0.5))),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isActive ? AppColors.primary : AppColors.textMuted,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.isAuthenticated;
      final onboardingComplete = authState.onboardingComplete;
      final needsEmailVerification = authState.needsEmailVerification;

      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      final isOnVerificationPage = state.matchedLocation == '/verify-email';
      final isOnOnboardingPage = state.matchedLocation.startsWith('/onboarding');

      // Still loading
      if (isLoading) return null;

      // Not authenticated -> go to login
      if (!isAuthenticated) {
        if (!isOnAuthPage) return '/login';
        return null;
      }

      // Authenticated but needs email verification -> go to verification screen
      if (needsEmailVerification) {
        if (!isOnVerificationPage) return '/verify-email';
        return null;
      }

      // Authenticated, verified, but onboarding not complete -> go to onboarding
      if (!onboardingComplete) {
        if (!isOnOnboardingPage) return '/onboarding/style-preferences';
        return null;
      }

      // Authenticated, verified, and onboarding complete -> go to main
      if (isOnAuthPage || isOnOnboardingPage || isOnVerificationPage) return '/main/home';

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      // Email verification route
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      // Onboarding routes
      GoRoute(
        path: '/onboarding/style-preferences',
        builder: (context, state) => const StylePreferencesScreen(),
      ),
      GoRoute(
        path: '/onboarding/body-info',
        builder: (context, state) => const BodyInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/profile-photo',
        builder: (context, state) => const ProfilePhotoScreen(),
      ),
      // Main routes with shell
      ShellRoute(
        builder: (context, state, child) {
          int index = 0;
          if (state.matchedLocation == '/main/wardrobe') index = 2;
          if (state.matchedLocation == '/main/profile') index = 3;
          return MainShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/main/home',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/main/wardrobe',
            builder: (context, state) => const WardrobeScreen(),
          ),
          GoRoute(
            path: '/main/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      // Stack routes (no bottom nav)
      GoRoute(
        path: '/tryon',
        builder: (context, state) => const TryOnScreen(),
      ),
      GoRoute(
        path: '/shopping',
        builder: (context, state) => const ShoppingScreen(),
      ),
      // Settings and Profile Edit routes
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/edit-body-info',
        builder: (context, state) => const EditBodyInfoScreen(),
      ),
      GoRoute(
        path: '/edit-preferences',
        builder: (context, state) => const EditPreferencesScreen(),
      ),
    ],
  );
});


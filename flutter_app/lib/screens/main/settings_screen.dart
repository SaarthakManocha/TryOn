// Settings Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = true;
  bool _notifications = true;
  bool _saveHistory = true;

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: Row(
          children: [
            const Text('🚪', style: TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.sm),
            const Text('Logout', style: AppTypography.h3),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?\nYou\'ll need to sign in again.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(preferencesProvider.notifier).clearPreferences();
              await ref.read(authProvider.notifier).logout();
            },
            child: Text('Logout', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.largeRadius),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(child: Text('👗', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text('TryOn', style: AppTypography.h2),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0', style: AppTypography.body),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Virtual try-on powered by AI.\nSee how clothes look on you before you buy.',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Made with ❤️', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: const Center(child: Text('←', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Settings', style: AppTypography.h2),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Appearance Section
                    _buildSectionHeader('Appearance'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildToggleItem(
                      icon: '🌙',
                      title: 'Dark Mode',
                      subtitle: 'Use dark theme',
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Notifications Section
                    _buildSectionHeader('Notifications'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildToggleItem(
                      icon: '🔔',
                      title: 'Push Notifications',
                      subtitle: 'Get notified about new features',
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Privacy Section
                    _buildSectionHeader('Privacy'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildToggleItem(
                      icon: '💾',
                      title: 'Save Try-On History',
                      subtitle: 'Keep a record of your virtual try-ons',
                      value: _saveHistory,
                      onChanged: (v) => setState(() => _saveHistory = v),
                    ),
                    _buildNavItem(
                      icon: '🗑️',
                      title: 'Clear History',
                      subtitle: 'Delete all saved try-ons',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('History cleared!')),
                        );
                      },
                      isDestructive: true,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Support Section
                    _buildSectionHeader('Support'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildNavItem(
                      icon: '❓',
                      title: 'Help & FAQ',
                      subtitle: 'Get answers to common questions',
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: '📧',
                      title: 'Contact Us',
                      subtitle: 'Send us feedback or report issues',
                      onTap: () {},
                    ),
                    _buildNavItem(
                      icon: 'ℹ️',
                      title: 'About',
                      subtitle: 'App version and info',
                      onTap: _showAboutDialog,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Account Section
                    _buildSectionHeader('Account'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildNavItem(
                      icon: '🚪',
                      title: 'Logout',
                      subtitle: 'Sign out of your account',
                      onTap: _showLogoutDialog,
                      isDestructive: true,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl * 2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildToggleItem({
    required String icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w500)),
                Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.mediumRadius,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isDestructive ? AppColors.error : AppColors.text,
                    ),
                  ),
                  Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            Text('→', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

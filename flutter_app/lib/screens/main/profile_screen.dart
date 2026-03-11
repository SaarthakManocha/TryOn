// Profile Screen - Enhanced with navigation
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final prefsState = ref.watch(preferencesProvider);
    final tryOnState = ref.watch(tryOnProvider);

    final prefs = prefsState.preferences;
    final totalTryOns = tryOnState.tryOns.length;
    final savedOutfits = tryOnState.tryOns.where((t) => t.isFavorite).length;

    final styleNames = prefs.styles.isNotEmpty 
        ? prefs.styles.map((s) => s[0].toUpperCase() + s.substring(1)).join(', ')
        : 'Tap to set';
    final bodyInfo = [prefs.height, prefs.bodyType.isNotEmpty ? prefs.bodyType : null]
        .where((s) => s != null && s.isNotEmpty)
        .join(' • ');

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with Settings
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Profile', style: AppTypography.h1),
                    GestureDetector(
                      onTap: () => context.push('/settings'),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.mediumRadius,
                        ),
                        child: const Center(child: Text('⚙️', style: TextStyle(fontSize: 22))),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Profile Card
              GestureDetector(
                onTap: () => context.push('/edit-profile'),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface, AppColors.surfaceLight.withOpacity(0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.largeRadius,
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                        ),
                        child: prefs.profilePhotoUri != null && prefs.profilePhotoUri!.isNotEmpty
                            ? ClipOval(
                                child: prefs.profilePhotoUri!.startsWith('http')
                                    ? Image.network(prefs.profilePhotoUri!, fit: BoxFit.cover, width: 80, height: 80)
                                    : Image.file(File(prefs.profilePhotoUri!), fit: BoxFit.cover, width: 80, height: 80),
                              )
                            : const Center(child: Text('👤', style: TextStyle(fontSize: 36))),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(authState.user?.name ?? 'User', style: AppTypography.h3),
                            const SizedBox(height: 2),
                            Text(
                              authState.user?.email ?? 'email@example.com',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: AppRadius.smallRadius,
                              ),
                              child: Text('Edit Profile', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      ),
                      Text('→', style: TextStyle(fontSize: 20, color: AppColors.textMuted)),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xl),

              // Stats Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('📸', totalTryOns.toString(), 'Try-Ons')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildStatCard('❤️', savedOutfits.toString(), 'Favorites')),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildStatCard('👗', prefs.styles.length.toString(), 'Styles')),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Menu Items
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: '👕',
                      title: 'Style Preferences',
                      subtitle: styleNames,
                      onTap: () => context.push('/edit-preferences'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildMenuItem(
                      context,
                      icon: '📐',
                      title: 'Body Info',
                      subtitle: bodyInfo.isNotEmpty ? bodyInfo : 'Tap to set',
                      onTap: () => context.push('/edit-body-info'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildMenuItem(
                      context,
                      icon: '⭐',
                      title: 'Saved Outfits',
                      subtitle: '$savedOutfits outfits saved',
                      onTap: () => context.go('/main/wardrobe'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _buildMenuItem(
                      context,
                      icon: 'ℹ️',
                      title: 'About TryOn',
                      subtitle: 'Version 1.0.0',
                      onTap: () => _showAboutDialog(context),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: GestureDetector(
                  onTap: () => _showLogoutDialog(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: AppRadius.mediumRadius,
                      border: Border.all(color: AppColors.error.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🚪', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Logout', style: AppTypography.body.copyWith(color: AppColors.error, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl * 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.h2),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text('→', style: TextStyle(fontSize: 18, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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
}

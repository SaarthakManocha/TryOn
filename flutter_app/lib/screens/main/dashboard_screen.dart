// Dashboard Screen - Main Home (Enhanced)
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(tryOnProvider.notifier).loadTryOns();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final prefsState = ref.watch(preferencesProvider);
    final tryOnState = ref.watch(tryOnProvider);
    final recentTryOns = tryOnState.tryOns.take(4).toList();
    final prefs = prefsState.preferences;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Profile Photo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                        Text(
                          'Hi, ${authState.user?.name.split(' ')[0] ?? 'there'}! 👋',
                          style: AppTypography.h2,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/main/profile'),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 2),
                      ),
                      child: prefs.profilePhotoUri != null && prefs.profilePhotoUri!.isNotEmpty
                          ? ClipOval(
                              child: prefs.profilePhotoUri!.startsWith('http')
                                  ? Image.network(prefs.profilePhotoUri!, fit: BoxFit.cover, width: 50, height: 50)
                                  : Image.file(File(prefs.profilePhotoUri!), fit: BoxFit.cover, width: 50, height: 50),
                            )
                          : const Center(child: Text('👤', style: TextStyle(fontSize: 24))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Main CTA Card with Gradient
              GestureDetector(
                onTap: () => context.push('/tryon'),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.xlRadius,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const Center(child: Text('✨', style: TextStyle(fontSize: 32))),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Virtual Try-On', style: AppTypography.h2.copyWith(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              'See yourself in any outfit instantly',
                              style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.85)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('→', style: TextStyle(fontSize: 20, color: Colors.white))),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Stats Row
              Row(
                children: [
                  Expanded(child: _buildStatCard('📸', tryOnState.tryOns.length.toString(), 'Try-Ons')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildStatCard('❤️', tryOnState.tryOns.where((t) => t.isFavorite).length.toString(), 'Favorites')),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _buildStatCard('👗', prefs.styles.length.toString(), 'Styles')),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Quick Actions
              Text('Quick Actions', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: '📷',
                      label: 'Camera',
                      color: Colors.blue,
                      onTap: () => context.push('/tryon'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: '🖼️',
                      label: 'Gallery',
                      color: Colors.green,
                      onTap: () => context.push('/tryon'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      icon: '🔗',
                      label: 'From URL',
                      color: Colors.orange,
                      onTap: () => context.push('/tryon'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              
              // Recent Try-Ons
              if (recentTryOns.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Try-Ons', style: AppTypography.h3),
                    GestureDetector(
                      onTap: () => context.go('/main/wardrobe'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: AppRadius.smallRadius,
                        ),
                        child: Text('See All', style: AppTypography.caption.copyWith(color: AppColors.primary)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recentTryOns.length,
                    itemBuilder: (context, index) {
                      final item = recentTryOns[index];
                      return Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.largeRadius,
                          boxShadow: AppShadows.sm,
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: AppRadius.largeRadius,
                              child: item.resultImageUri.isNotEmpty
                                  ? Image.network(item.resultImageUri, fit: BoxFit.cover, width: 130, height: 180)
                                  : Container(color: AppColors.surfaceLight, width: 130, height: 180),
                            ),
                            // Gradient overlay
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.largeRadius,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                  ),
                                ),
                              ),
                            ),
                            if (item.isFavorite)
                              Positioned(
                                top: AppSpacing.xs,
                                right: AppSpacing.xs,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text('❤️', style: TextStyle(fontSize: 12)),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                // Empty State
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.largeRadius,
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(child: Text('👗', style: TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('No try-ons yet', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Start your first virtual try-on and discover your perfect style!',
                        style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      AppButton(
                        title: 'Try On Now',
                        onPressed: () => context.push('/tryon'),
                        fullWidth: true,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              
              // Tips Section
              Text('Style Tips', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              _buildTipCard(
                '💡',
                'Better Photos, Better Results',
                'Stand in good lighting with a plain background for the best try-on experience.',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTipCard(
                '👔',
                'Try Different Styles',
                'Experiment with styles outside your comfort zone – you might be surprised!',
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
        border: Border.all(color: AppColors.surfaceLight.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.h3),
          Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, {required String icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.largeRadius,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(label, style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String emoji, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                Text(description, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

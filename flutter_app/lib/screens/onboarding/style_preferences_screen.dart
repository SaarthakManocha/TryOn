// Style Preferences Screen - Onboarding Step 1
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class StylePreferencesScreen extends ConsumerStatefulWidget {
  const StylePreferencesScreen({super.key});

  @override
  ConsumerState<StylePreferencesScreen> createState() => _StylePreferencesScreenState();
}

class _StylePreferencesScreenState extends ConsumerState<StylePreferencesScreen> {
  List<String> _selected = [];

  static const List<Map<String, String>> _styleOptions = [
    {'id': 'casual', 'name': 'Casual', 'icon': '👕'},
    {'id': 'formal', 'name': 'Formal', 'icon': '👔'},
    {'id': 'sporty', 'name': 'Sporty', 'icon': '🏃'},
    {'id': 'bohemian', 'name': 'Bohemian', 'icon': '🌸'},
    {'id': 'minimalist', 'name': 'Minimalist', 'icon': '⬜'},
    {'id': 'streetwear', 'name': 'Streetwear', 'icon': '🔥'},
    {'id': 'ethnic', 'name': 'Ethnic', 'icon': '🪷'},
    {'id': 'party', 'name': 'Party', 'icon': '✨'},
    {'id': 'workwear', 'name': 'Workwear', 'icon': '💼'},
  ];

  @override
  void initState() {
    super.initState();
    _selected = List.from(ref.read(preferencesProvider).preferences.styles);
  }

  void _toggleStyle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else {
        _selected.add(id);
      }
    });
  }

  Future<void> _handleContinue() async {
    await ref.read(preferencesProvider.notifier).updatePreferences(styles: _selected);
    if (mounted) context.push('/onboarding/body-info');
  }

  void _handleSkip() {
    context.push('/onboarding/body-info');
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress dots
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _handleSkip,
                    child: Text(
                      'Skip →',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
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
                    const Text("What's your style?", style: AppTypography.h1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Select all that apply. This helps us personalize your experience.',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Grid
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: _styleOptions.map((style) {
                        final isSelected = _selected.contains(style['id']);
                        return GestureDetector(
                          onTap: () => _toggleStyle(style['id']!),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                            height: (MediaQuery.of(context).size.width - AppSpacing.lg * 2 - AppSpacing.md * 2) / 3,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.surfaceLight : AppColors.surface,
                              borderRadius: AppRadius.largeRadius,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isSelected ? AppShadows.sm : null,
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(style['icon']!, style: const TextStyle(fontSize: 32)),
                                      const SizedBox(height: AppSpacing.sm),
                                      Text(
                                        style['name']!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isSelected ? AppColors.text : AppColors.textSecondary,
                                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: -6,
                                    right: -6,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Center(
                                        child: Text('✓',
                                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Spacer for bottom button
                    SizedBox(height: AppSpacing.lg + 60 + bottomPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom button
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.md + bottomPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.surfaceLight.withOpacity(0.3))),
        ),
        child: AppButton(
          title: 'Continue${_selected.isNotEmpty ? ' (${_selected.length})' : ''}',
          onPressed: _handleContinue,
          fullWidth: true,
        ),
      ),
    );
  }
}

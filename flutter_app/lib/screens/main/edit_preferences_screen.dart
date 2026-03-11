// Edit Style Preferences Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class EditPreferencesScreen extends ConsumerStatefulWidget {
  const EditPreferencesScreen({super.key});

  @override
  ConsumerState<EditPreferencesScreen> createState() => _EditPreferencesScreenState();
}

class _EditPreferencesScreenState extends ConsumerState<EditPreferencesScreen> {
  late List<String> _selectedStyles;
  late List<String> _selectedColors;
  bool _hasChanges = false;

  static const styleOptions = [
    {'id': 'casual', 'emoji': '👕', 'label': 'Casual'},
    {'id': 'formal', 'emoji': '👔', 'label': 'Formal'},
    {'id': 'streetwear', 'emoji': '🧢', 'label': 'Streetwear'},
    {'id': 'sporty', 'emoji': '🏃', 'label': 'Sporty'},
    {'id': 'bohemian', 'emoji': '🌸', 'label': 'Bohemian'},
    {'id': 'vintage', 'emoji': '🎞️', 'label': 'Vintage'},
    {'id': 'minimalist', 'emoji': '◽', 'label': 'Minimalist'},
    {'id': 'trendy', 'emoji': '✨', 'label': 'Trendy'},
  ];

  static const colorOptions = [
    {'id': 'black', 'color': Colors.black, 'label': 'Black'},
    {'id': 'white', 'color': Colors.white, 'label': 'White'},
    {'id': 'blue', 'color': Colors.blue, 'label': 'Blue'},
    {'id': 'red', 'color': Colors.red, 'label': 'Red'},
    {'id': 'green', 'color': Colors.green, 'label': 'Green'},
    {'id': 'pink', 'color': Colors.pink, 'label': 'Pink'},
    {'id': 'beige', 'color': Color(0xFFF5F5DC), 'label': 'Beige'},
    {'id': 'navy', 'color': Color(0xFF000080), 'label': 'Navy'},
  ];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider).preferences;
    _selectedStyles = List.from(prefs.styles);
    _selectedColors = List.from(prefs.colors);
  }

  Future<void> _saveChanges() async {
    await ref.read(preferencesProvider.notifier).updatePreferences(
      styles: _selectedStyles,
      colors: _selectedColors,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferences updated!')),
      );
      context.pop();
    }
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
                  Text('Style Preferences', style: AppTypography.h2),
                  const Spacer(),
                  if (_hasChanges)
                    GestureDetector(
                      onTap: _saveChanges,
                      child: Text('Save', style: AppTypography.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
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
                    // Styles Section
                    Text('My Style', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Select all that apply', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.md),
                    
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: styleOptions.map((style) {
                        final isSelected = _selectedStyles.contains(style['id']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedStyles.remove(style['id']);
                              } else {
                                _selectedStyles.add(style['id'] as String);
                              }
                              _hasChanges = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                              borderRadius: AppRadius.mediumRadius,
                              border: Border.all(
                                color: isSelected ? AppColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(style['emoji'] as String, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  style['label'] as String,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isSelected ? AppColors.primary : AppColors.text,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Icon(Icons.check, size: 16, color: AppColors.primary),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Colors Section
                    Text('Favorite Colors', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.xs),
                    Text('Colors you like to wear', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                    const SizedBox(height: AppSpacing.md),

                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: colorOptions.map((colorOpt) {
                        final isSelected = _selectedColors.contains(colorOpt['id']);
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedColors.remove(colorOpt['id']);
                              } else {
                                _selectedColors.add(colorOpt['id'] as String);
                              }
                              _hasChanges = true;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: colorOpt['color'] as Color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                                    width: isSelected ? 3 : 1,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ] : null,
                                ),
                                child: isSelected
                                    ? Center(child: Icon(Icons.check, color: colorOpt['id'] == 'white' ? Colors.black : Colors.white, size: 24))
                                    : null,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                colorOpt['label'] as String,
                                style: AppTypography.caption.copyWith(
                                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl * 2),

                    // Save Button
                    if (_hasChanges)
                      AppButton(
                        title: 'Save Preferences',
                        onPressed: _saveChanges,
                        fullWidth: true,
                      ),

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

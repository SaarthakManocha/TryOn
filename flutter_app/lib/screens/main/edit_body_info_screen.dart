// Edit Body Info Screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class EditBodyInfoScreen extends ConsumerStatefulWidget {
  const EditBodyInfoScreen({super.key});

  @override
  ConsumerState<EditBodyInfoScreen> createState() => _EditBodyInfoScreenState();
}

class _EditBodyInfoScreenState extends ConsumerState<EditBodyInfoScreen> {
  late String _gender;
  late double _heightCm;
  late String _bodyType;
  String? _shirtSize;
  int? _waistInches;
  String? _dressSize;
  bool _hasChanges = false;

  static const maleShirtSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
  static const maleWaistSizes = [28, 30, 32, 34, 36, 38, 40, 42];
  static const femaleDressSizes = ['0', '2', '4', '6', '8', '10', '12', '14', '16', '18'];

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider).preferences;
    _gender = prefs.gender.isNotEmpty ? prefs.gender : 'male';
    _heightCm = _parseHeight(prefs.height);
    _bodyType = prefs.bodyType.isNotEmpty ? prefs.bodyType : 'average';
    _shirtSize = prefs.topSize.isNotEmpty ? prefs.topSize : null;
  }

  double _parseHeight(String height) {
    if (height.isEmpty) return 170;
    final match = RegExp(r'(\d+)').firstMatch(height);
    if (match != null) {
      return double.tryParse(match.group(1)!) ?? 170;
    }
    return 170;
  }

  Future<void> _saveChanges() async {
    await ref.read(preferencesProvider.notifier).updatePreferences(
      gender: _gender,
      height: '${_heightCm.round()}cm',
      bodyType: _bodyType,
      topSize: _gender == 'male' ? _shirtSize : _dressSize,
      bottomSize: _waistInches != null ? '$_waistInches"' : null,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Body info updated!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final feet = (_heightCm / 2.54 / 12).floor();
    final inches = ((_heightCm / 2.54) % 12).round();

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
                  Text('Body Info', style: AppTypography.h2),
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
                    // Gender
                    Text('Gender', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _buildGenderCard('male', '👨', 'Male'),
                        const SizedBox(width: AppSpacing.md),
                        _buildGenderCard('female', '👩', 'Female'),
                        const SizedBox(width: AppSpacing.md),
                        _buildGenderCard('other', '🧑', 'Other'),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Height
                    Text('Height', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Column(
                        children: [
                          Text(
                            "$feet'$inches\" (${_heightCm.round()}cm)",
                            style: AppTypography.h3.copyWith(color: AppColors.primary),
                          ),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: AppColors.primary,
                              inactiveTrackColor: AppColors.surfaceLight,
                              thumbColor: AppColors.primary,
                              trackHeight: 6,
                            ),
                            child: Slider(
                              value: _heightCm,
                              min: 140,
                              max: 210,
                              divisions: 70,
                              onChanged: (v) => setState(() {
                                _heightCm = v;
                                _hasChanges = true;
                              }),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Body Type
                    Text('Body Type', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    _buildBodyTypeSelector(),

                    const SizedBox(height: AppSpacing.xl),

                    // Size
                    Text(_gender == 'male' ? 'Shirt Size' : 'Dress Size', style: AppTypography.h3),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: (_gender == 'male' ? maleShirtSizes : femaleDressSizes).map((size) {
                          final isSelected = (_gender == 'male' ? _shirtSize : _dressSize) == size;
                          return Padding(
                            padding: const EdgeInsets.only(right: AppSpacing.sm),
                            child: GestureDetector(
                              onTap: () => setState(() {
                                if (_gender == 'male') {
                                  _shirtSize = size;
                                } else {
                                  _dressSize = size;
                                }
                                _hasChanges = true;
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primary : AppColors.surface,
                                  borderRadius: AppRadius.mediumRadius,
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  size,
                                  style: AppTypography.body.copyWith(
                                    color: isSelected ? Colors.white : AppColors.text,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl * 2),

                    // Save Button
                    if (_hasChanges)
                      AppButton(
                        title: 'Save Changes',
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

  Widget _buildGenderCard(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _gender = value;
          _hasChanges = true;
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBodyTypeSelector() {
    final types = [
      {'id': 'slim', 'emoji': '🏃', 'label': 'Slim'},
      {'id': 'average', 'emoji': '🧍', 'label': 'Average'},
      {'id': 'athletic', 'emoji': '💪', 'label': 'Athletic'},
      {'id': 'curvy', 'emoji': '✨', 'label': 'Curvy'},
    ];

    return Row(
      children: types.map((type) {
        final isSelected = _bodyType == type['id'];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: type['id'] != 'curvy' ? AppSpacing.sm : 0),
            child: GestureDetector(
              onTap: () => setState(() {
                _bodyType = type['id']!;
                _hasChanges = true;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Text(type['emoji']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 4),
                    Text(
                      type['label']!,
                      style: AppTypography.caption.copyWith(
                        color: isSelected ? AppColors.primary : AppColors.text,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

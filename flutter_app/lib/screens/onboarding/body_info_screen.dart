// Body Info Screen - Clean Premium Design (No Avatar)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class BodyInfoScreen extends ConsumerStatefulWidget {
  const BodyInfoScreen({super.key});

  @override
  ConsumerState<BodyInfoScreen> createState() => _BodyInfoScreenState();
}

class _BodyInfoScreenState extends ConsumerState<BodyInfoScreen> {
  // Gender controls everything
  String? _gender;
  
  // Body parameters
  double _heightCm = 170;
  String _bodyType = 'average';
  
  // Male sizes
  String? _shirtSize;
  int? _waistInches;
  
  // Female sizes
  String? _dressSize;
  int? _bustInches;
  int? _waistInchesF;
  int? _hipsInches;

  // Size options
  static const maleShirtSizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];
  static const maleWaistSizes = [28, 30, 32, 34, 36, 38, 40, 42];
  
  static const femaleDressSizes = ['0', '2', '4', '6', '8', '10', '12', '14', '16', '18'];
  static const femaleBustSizes = [30, 32, 34, 36, 38, 40, 42, 44];
  static const femaleWaistSizes = [24, 26, 28, 30, 32, 34, 36];
  static const femaleHipsSizes = [34, 36, 38, 40, 42, 44, 46];

  String _getSizeSuggestion() {
    if (_gender == null) return '';
    
    if (_gender == 'male') {
      switch (_bodyType) {
        case 'slim': return '💡 Based on your profile: Shirt S-M recommended';
        case 'athletic': return '💡 Based on your profile: Shirt M-L, fitted styles work great';
        case 'curvy': return '💡 Based on your profile: Shirt XL-XXL for comfort';
        default: return '💡 Based on your profile: Shirt M-L recommended';
      }
    } else {
      switch (_bodyType) {
        case 'slim': return '💡 Based on your profile: Dress 2-6 recommended';
        case 'athletic': return '💡 Based on your profile: Dress 4-8, structured fits work well';
        case 'curvy': return '💡 Based on your profile: Dress 10-16, A-line styles flatter';
        default: return '💡 Based on your profile: Dress 6-10 recommended';
      }
    }
  }

  Future<void> _handleContinue() async {
    await ref.read(preferencesProvider.notifier).updatePreferences(
      gender: _gender ?? 'other',
      height: '${_heightCm.round()}cm',
      bodyType: _bodyType,
      topSize: _gender == 'male' ? _shirtSize : _dressSize,
      bottomSize: _gender == 'male' 
          ? (_waistInches != null ? '$_waistInches"' : null)
          : (_hipsInches != null ? 'H$_hipsInches"' : null),
    );
    
    if (mounted) {
      context.push('/onboarding/profile-photo');
    }
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: const Center(child: Text('←', style: TextStyle(fontSize: 20))),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildDot(true),
                      const SizedBox(width: 6),
                      _buildDot(true),
                      const SizedBox(width: 6),
                      _buildDot(false),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _handleContinue,
                    child: Text('Skip →', style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
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
                    const SizedBox(height: AppSpacing.md),
                    
                    // Title with icon
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: AppRadius.mediumRadius,
                          ),
                          child: const Center(child: Text('📏', style: TextStyle(fontSize: 24))),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Your Body Profile', style: AppTypography.h2),
                              const SizedBox(height: 2),
                              Text(
                                'Helps us find your perfect fit',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // STEP 1: Gender Selection
                    _buildSectionHeader('1', 'I identify as', required: true),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        _buildGenderCard('male', '👨', 'Male'),
                        const SizedBox(width: AppSpacing.md),
                        _buildGenderCard('female', '👩', 'Female'),
                        const SizedBox(width: AppSpacing.md),
                        _buildGenderCard('other', '🧑', 'Other'),
                      ],
                    ),
                    
                    // Show rest only after gender selection
                    if (_gender != null) ...[
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.surfaceLight.withOpacity(0.5),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // STEP 2: Height
                      _buildSectionHeader('2', 'My height'),
                      const SizedBox(height: AppSpacing.md),
                      _buildHeightSelector(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // STEP 3: Body Type
                      _buildSectionHeader('3', 'My body type'),
                      const SizedBox(height: AppSpacing.md),
                      _buildBodyTypeSelector(),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Smart suggestion card
                      if (_getSizeSuggestion().isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withOpacity(0.1),
                                AppColors.primaryLight.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: AppRadius.mediumRadius,
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  _getSizeSuggestion(),
                                  style: AppTypography.body.copyWith(color: AppColors.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // Divider
                      Container(
                        height: 1,
                        color: AppColors.surfaceLight.withOpacity(0.5),
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      
                      // STEP 4: Sizes
                      _buildSectionHeader('4', 'My usual sizes', subtitle: 'Optional - helps with recommendations'),
                      const SizedBox(height: AppSpacing.md),
                      _gender == 'male' ? _buildMaleSizes() : _buildFemaleSizes(),
                      
                      SizedBox(height: 120 + bottomPadding),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Continue button
      bottomNavigationBar: _gender != null ? Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: AppSpacing.md + bottomPadding,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: AppButton(
          title: 'Continue',
          onPressed: _handleContinue,
          fullWidth: true,
        ),
      ) : null,
    );
  }

  Widget _buildDot(bool active) {
    return Container(
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.primary : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildSectionHeader(String number, String title, {bool required = false, String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(title, style: AppTypography.h3),
                  if (required)
                    Text(' *', style: AppTypography.h3.copyWith(color: AppColors.error)),
                ],
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderCard(String value, String emoji, String label) {
    final isSelected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _gender = value;
          // Reset sizes when gender changes
          _shirtSize = null;
          _waistInches = null;
          _dressSize = null;
          _bustInches = null;
          _waistInchesF = null;
          _hipsInches = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withOpacity(0.15) : AppColors.surface,
            borderRadius: AppRadius.mediumRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ] : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 32)),
              const SizedBox(height: AppSpacing.xs),
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

  Widget _buildHeightSelector() {
    final feet = (_heightCm / 2.54 / 12).floor();
    final inches = ((_heightCm / 2.54) % 12).round();
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mediumRadius,
      ),
      child: Column(
        children: [
          // Height display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: AppRadius.smallRadius,
            ),
            child: Text(
              "$feet'$inches\" (${_heightCm.round()} cm)",
              style: AppTypography.h3.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.surfaceLight,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: _heightCm,
              min: 140,
              max: 210,
              divisions: 70,
              onChanged: (v) => setState(() => _heightCm = v),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("4'7\" (140cm)", style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                Text("6'11\" (210cm)", style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyTypeSelector() {
    final types = _gender == 'female' 
      ? [
          {'id': 'slim', 'emoji': '🩰', 'label': 'Slim', 'desc': 'Lean & narrow'},
          {'id': 'average', 'emoji': '👗', 'label': 'Average', 'desc': 'Balanced proportions'},
          {'id': 'athletic', 'emoji': '🏃‍♀️', 'label': 'Athletic', 'desc': 'Toned & fit'},
          {'id': 'curvy', 'emoji': '💃', 'label': 'Curvy', 'desc': 'Full bust & hips'},
        ]
      : [
          {'id': 'slim', 'emoji': '🏃', 'label': 'Slim', 'desc': 'Lean build'},
          {'id': 'average', 'emoji': '🧍', 'label': 'Average', 'desc': 'Regular fit'},
          {'id': 'athletic', 'emoji': '💪', 'label': 'Athletic', 'desc': 'Broad & muscular'},
          {'id': 'curvy', 'emoji': '🐻', 'label': 'Stocky', 'desc': 'Fuller frame'},
        ];
    
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: types.map((type) {
        final isSelected = _bodyType == type['id'];
        return GestureDetector(
          onTap: () => setState(() => _bodyType = type['id']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: (MediaQuery.of(context).size.width - 48 - 12) / 2,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.surface,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Text(type['emoji']!, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type['label']!,
                        style: AppTypography.bodySmall.copyWith(
                          color: isSelected ? AppColors.primary : AppColors.text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        type['desc']!,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: AppColors.primary, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMaleSizes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shirt Size', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(maleShirtSizes, _shirtSize, (v) => setState(() => _shirtSize = v)),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Waist (inches)', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(
          maleWaistSizes.map((e) => '$e"').toList(),
          _waistInches != null ? '$_waistInches"' : null,
          (v) => setState(() => _waistInches = int.parse(v.replaceAll('"', ''))),
        ),
      ],
    );
  }

  Widget _buildFemaleSizes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dress Size', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(femaleDressSizes, _dressSize, (v) => setState(() => _dressSize = v)),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Bust (inches)', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(
          femaleBustSizes.map((e) => '$e"').toList(),
          _bustInches != null ? '$_bustInches"' : null,
          (v) => setState(() => _bustInches = int.parse(v.replaceAll('"', ''))),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Waist (inches)', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(
          femaleWaistSizes.map((e) => '$e"').toList(),
          _waistInchesF != null ? '$_waistInchesF"' : null,
          (v) => setState(() => _waistInchesF = int.parse(v.replaceAll('"', ''))),
        ),
        const SizedBox(height: AppSpacing.lg),
        
        Text('Hips (inches)', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.sm),
        _buildChipRow(
          femaleHipsSizes.map((e) => '$e"').toList(),
          _hipsInches != null ? '$_hipsInches"' : null,
          (v) => setState(() => _hipsInches = int.parse(v.replaceAll('"', ''))),
        ),
      ],
    );
  }

  Widget _buildChipRow(List<String> options, String? selected, Function(String) onSelect) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selected == option;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: AppRadius.smallRadius,
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                  ),
                ),
                child: Text(
                  option,
                  style: AppTypography.bodySmall.copyWith(
                    color: isSelected ? Colors.white : AppColors.text,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

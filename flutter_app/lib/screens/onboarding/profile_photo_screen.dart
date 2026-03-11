// Profile Photo Screen - Onboarding Step 3
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../services/tryon_api_service.dart';

class ProfilePhotoScreen extends ConsumerStatefulWidget {
  const ProfilePhotoScreen({super.key});

  @override
  ConsumerState<ProfilePhotoScreen> createState() => _ProfilePhotoScreenState();
}

class _ProfilePhotoScreenState extends ConsumerState<ProfilePhotoScreen> {
  String? _photoUri;
  bool _loading = false;
  String _loadingMessage = 'Processing...';
  final ImagePicker _picker = ImagePicker();

  Future<void> _handleTakePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() => _photoUri = photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open camera. Please grant camera permissions.')),
        );
      }
    }
  }

  Future<void> _handleChooseFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (photo != null) {
        setState(() => _photoUri = photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open gallery.')),
        );
      }
    }
  }

  Future<void> _handleComplete() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Analyzing your photo...';
    });
    
    try {
      final authState = ref.read(authProvider);
      final userId = authState.user?.id ?? 'anonymous';
      
      if (_photoUri != null) {
        // Save photo URI locally first
        await ref.read(preferencesProvider.notifier).updatePreferences(profilePhotoUri: _photoUri);
        
        // Step 2: Extract face and skin tone from selfie
        setState(() => _loadingMessage = 'Extracting facial features...');
        final faceResult = await tryOnApiService.extractFace(
          selfiePath: _photoUri!,
          userId: userId,
        );
        
        if (!faceResult.success) {
          // Non-blocking - continue even if face extraction fails
          debugPrint('Face extraction failed: ${faceResult.error}');
        }
        
        // Step 2A: Extract hair
        setState(() => _loadingMessage = 'Processing hair style...');
        final hairResult = await tryOnApiService.extractHair(
          selfiePath: _photoUri!,
          userId: userId,
        );
        
        if (!hairResult.success) {
          // Non-blocking - continue even if hair extraction fails
          debugPrint('Hair extraction failed: ${hairResult.error}');
        }
        
        // Step 3: Create base body
        setState(() => _loadingMessage = 'Creating your avatar...');
        final prefs = ref.read(preferencesProvider).preferences;
        final heightStr = prefs.height.replaceAll('cm', '').trim();
        final heightCm = int.tryParse(heightStr) ?? 170;
        
        final baseBodyResult = await tryOnApiService.createBaseBody(
          userId: userId,
          gender: prefs.gender.isNotEmpty ? prefs.gender : 'other',
          bodyBuild: prefs.bodyType.isNotEmpty ? prefs.bodyType : 'medium',
          heightCm: heightCm,
          skinToneRgb: faceResult.skinToneRgb ?? [200, 160, 130], // Default skin tone
        );
        
        if (!baseBodyResult.success) {
          debugPrint('Base body creation failed: ${baseBodyResult.error}');
        }
      }
      
      await ref.read(authProvider.notifier).setOnboardingComplete(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Setup completed with some issues: ${e.toString()}')),
        );
        // Still complete onboarding even if backend fails
        await ref.read(authProvider.notifier).setOnboardingComplete(true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleSkip() async {
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).setOnboardingComplete(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to continue. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _handleBack() => Navigator.of(context).pop();

  Widget _buildTip(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(text, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Scaffold(
      body: SafeArea(
        bottom: false, // We'll handle bottom padding manually
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _handleBack,
                    child: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.text)),
                  ),
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: AppSpacing.sm),
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: AppSpacing.sm),
                      Container(width: 24, height: 8, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4))),
                    ],
                  ),
                  GestureDetector(
                    onTap: _handleSkip,
                    child: Text('Skip →', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Take a selfie', style: AppTypography.h1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We need your face to personalize your try-on experience.',
                      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Photo tips
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.largeRadius,
                        border: Border.all(color: Colors.purple.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('📸 Selfie Tips', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: AppSpacing.sm),
                          _buildTip('💡', 'Good lighting - face a window'),
                          _buildTip('👤', 'Face clearly visible, look at camera'),
                          _buildTip('🎯', 'Plain background works best'),
                          _buildTip('😊', 'Neutral expression, no filters'),
                          _buildTip('📏', 'Head and shoulders in frame'),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Photo container
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            height: MediaQuery.of(context).size.width * 0.7 / 0.7,
                            constraints: const BoxConstraints(maxHeight: 280),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: AppRadius.xlRadius,
                              border: Border.all(color: AppColors.surfaceLight, width: 2, style: BorderStyle.solid),
                            ),
                            child: _photoUri != null
                                ? ClipRRect(
                                    borderRadius: AppRadius.xlRadius,
                                    child: Image.file(File(_photoUri!), fit: BoxFit.cover),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 120,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          borderRadius: AppRadius.largeRadius,
                                        ),
                                        child: const Center(
                                          child: Text('👤', style: TextStyle(fontSize: 48, color: AppColors.textMuted)),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      Text('Full face visible', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                                      Text('Face towards camera', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                    ],
                                  ),
                          ),
                          if (_photoUri != null)
                            Positioned(
                              top: AppSpacing.sm,
                              right: AppSpacing.sm,
                              child: GestureDetector(
                                onTap: () => setState(() => _photoUri = null),
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: AppShadows.sm,
                                  ),
                                  child: const Center(
                                    child: Text('✕', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    // Action buttons
                    GestureDetector(
                      onTap: _handleTakePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.largeRadius,
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          children: [
                            const Text('📷', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: AppSpacing.md),
                            Text('Take Photo', style: AppTypography.body),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GestureDetector(
                      onTap: _handleChooseFromGallery,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: AppRadius.largeRadius,
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          children: [
                            const Text('🖼️', style: TextStyle(fontSize: 24)),
                            const SizedBox(width: AppSpacing.md),
                            Text('Choose from Gallery', style: AppTypography.body),
                          ],
                        ),
                      ),
                    ),
                    // Spacer for footer button
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(_loadingMessage, style: AppTypography.caption.copyWith(color: AppColors.primary)),
              ),
            AppButton(
              title: _photoUri != null ? 'Complete Setup' : 'Skip for Now',
              onPressed: _photoUri != null ? _handleComplete : _handleSkip,
              loading: _loading,
              fullWidth: true,
              variant: _photoUri != null ? ButtonVariant.primary : ButtonVariant.outline,
            ),
          ],
        ),
      ),
    );
  }
}

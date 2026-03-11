// TryOn Screen - Main virtual try-on feature
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../services/tryon_api_service.dart';

enum TryOnStep { outfit, user, processing, result }

class TryOnScreen extends ConsumerStatefulWidget {
  const TryOnScreen({super.key});

  @override
  ConsumerState<TryOnScreen> createState() => _TryOnScreenState();
}

class _TryOnScreenState extends ConsumerState<TryOnScreen> {
  TryOnStep _step = TryOnStep.outfit;
  ProcessingStep _processingStep = ProcessingStep.analyzing;
  final ImagePicker _picker = ImagePicker();
  String _imageUrl = '';
  bool _showUrlModal = false;

  void _handleBack() {
    if (_step == TryOnStep.outfit) {
      ref.read(tryOnProvider.notifier).clearCurrentTryOn();
      context.pop();
    } else if (_step == TryOnStep.user) {
      setState(() => _step = TryOnStep.outfit);
    } else if (_step == TryOnStep.result) {
      setState(() => _step = TryOnStep.outfit);
      ref.read(tryOnProvider.notifier).clearCurrentTryOn();
    }
  }

  Future<void> _handleCameraCapture(String type) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: type == 'user' ? CameraDevice.front : CameraDevice.rear,
        imageQuality: 80,
      );
      if (photo != null) {
        if (type == 'outfit') {
          ref.read(tryOnProvider.notifier).setOutfitImage(photo.path);
          // Go directly to processing - user data already captured during onboarding
          _processImages();
        } else {
          ref.read(tryOnProvider.notifier).setUserImage(photo.path);
          _processImages();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to open camera. Please grant permissions.')),
        );
      }
    }
  }

  Future<void> _handleGalleryPick(String type) async {
    try {
      final XFile? photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        if (type == 'outfit') {
          ref.read(tryOnProvider.notifier).setOutfitImage(photo.path);
          // Go directly to processing - user data already captured during onboarding
          _processImages();
        } else {
          ref.read(tryOnProvider.notifier).setUserImage(photo.path);
          _processImages();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to open gallery.')));
      }
    }
  }

  void _handleUrlSubmit() {
    if (_imageUrl.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid URL')));
      return;
    }
    ref.read(tryOnProvider.notifier).setOutfitImage(_imageUrl);
    setState(() {
      _showUrlModal = false;
      _imageUrl = '';
    });
    // Go directly to processing - user data already captured during onboarding
    _processImages();
  }

  void _useSavedPhoto() {
    final prefs = ref.read(preferencesProvider).preferences;
    if (prefs.profilePhotoUri != null && prefs.profilePhotoUri!.isNotEmpty) {
      ref.read(tryOnProvider.notifier).setUserImage(prefs.profilePhotoUri!);
      _processImages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You haven't saved a profile photo yet.")));
    }
  }

  Future<void> _processImages() async {
    setState(() {
      _step = TryOnStep.processing;
      _processingStep = ProcessingStep.analyzing;
    });
    ref.read(tryOnProvider.notifier).setProcessing(true);

    try {
      final currentTryOn = ref.read(tryOnProvider).currentTryOn;
      final authState = ref.read(authProvider);
      final userId = authState.user?.id ?? 'anonymous';
      
      // Step 1: Segment the garment
      setState(() => _processingStep = ProcessingStep.segmenting);
      
      GarmentSegmentResult garmentResult;
      final outfitImage = currentTryOn.outfitImage!;
      
      if (outfitImage.startsWith('http')) {
        garmentResult = await tryOnApiService.segmentGarmentFromUrl(
          imageUrl: outfitImage,
          userId: userId,
        );
      } else {
        garmentResult = await tryOnApiService.segmentGarmentFromFile(
          imagePath: outfitImage,
          userId: userId,
        );
      }
      
      if (!garmentResult.success) {
        throw Exception(garmentResult.error ?? 'Garment segmentation failed');
      }
      
      // Store Cloudinary URL for shopping feature
      if (garmentResult.garmentImageUrl != null) {
        ref.read(tryOnProvider.notifier).setOutfitImage(garmentResult.garmentImageUrl!);
      }
      
      // Step 2: Generate try-on (mock mode if no API key)
      setState(() => _processingStep = ProcessingStep.creating);
      
      final tryonResult = await tryOnApiService.generateTryOn(
        userId: userId,
        garmentPath: garmentResult.garmentImagePath ?? '',
        garmentType: garmentResult.garmentType ?? 'upper_body',
      );
      
      if (!tryonResult.success) {
        throw Exception(tryonResult.error ?? 'Try-on generation failed');
      }
      
      // Step 3: Finish up
      setState(() => _processingStep = ProcessingStep.finishing);
      
      // Use the result image URL
      final resultUrl = tryonResult.tryonImageUrl;
      
      if (resultUrl != null && resultUrl.isNotEmpty) {
        ref.read(tryOnProvider.notifier).setResultImage(resultUrl);
        setState(() {
          _processingStep = ProcessingStep.completed;
          _step = TryOnStep.result;
        });
      } else {
        throw Exception('No result image returned');
      }
      
      // Show mock mode notice if applicable
      if (tryonResult.isMock == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tryonResult.message ?? 'Mock mode - showing placeholder'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      setState(() => _step = TryOnStep.outfit);
    } finally {
      ref.read(tryOnProvider.notifier).setProcessing(false);
    }
  }

  Future<void> _handleSave() async {
    final currentTryOn = ref.read(tryOnProvider).currentTryOn;
    if (currentTryOn.resultImage != null) {
      await ref.read(tryOnProvider.notifier).saveTryOn(currentTryOn.resultImage!);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Try-on saved to your wardrobe.')));
    }
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share functionality would be implemented here.')));
  }

  void _handleShopSimilar() => context.push('/shopping');

  void _handleTryAnother() {
    ref.read(tryOnProvider.notifier).clearCurrentTryOn();
    setState(() => _step = TryOnStep.outfit);
  }

  Widget _buildOptionCard(String icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.largeRadius,
          boxShadow: AppShadows.sm,
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Text('→', style: TextStyle(fontSize: 20, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsBox(String title, List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(tip, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
          )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tryOnState = ref.watch(tryOnProvider);
    final prefsState = ref.watch(preferencesProvider);

    // Processing Screen with beautiful animation
    if (_step == TryOnStep.processing) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F0F1A),
        body: SafeArea(
          child: TryOnProcessingAnimation(
            currentStep: _processingStep,
          ),
        ),
      );
    }

    // Result Screen
    if (_step == TryOnStep.result) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(onTap: _handleBack, child: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.text))),
                    Text('Result', style: AppTypography.h3),
                    const Text('⋮', style: TextStyle(fontSize: 28, color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      if (tryOnState.currentTryOn.resultImage != null)
                        ClipRRect(
                          borderRadius: AppRadius.xlRadius,
                          child: tryOnState.currentTryOn.resultImage!.startsWith('http')
                            ? Image.network(
                                tryOnState.currentTryOn.resultImage!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 400,
                                    alignment: Alignment.center,
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) => Container(
                                  height: 400,
                                  color: AppColors.surface,
                                  child: const Center(child: Text('Failed to load image', style: TextStyle(color: Colors.white))),
                                ),
                              )
                            : Image.file(
                                File(tryOnState.currentTryOn.resultImage!),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: _handleSave,
                            child: Column(children: [const Text('💾', style: TextStyle(fontSize: 28)), const SizedBox(height: AppSpacing.xs), Text('Save', style: AppTypography.caption.copyWith(color: AppColors.textSecondary))]),
                          ),
                          GestureDetector(
                            onTap: _handleShopSimilar,
                            child: Column(children: [const Text('🛒', style: TextStyle(fontSize: 28)), const SizedBox(height: AppSpacing.xs), Text('Shop', style: AppTypography.caption.copyWith(color: AppColors.textSecondary))]),
                          ),
                          GestureDetector(
                            onTap: _handleShare,
                            child: Column(children: [const Text('↗️', style: TextStyle(fontSize: 28)), const SizedBox(height: AppSpacing.xs), Text('Share', style: AppTypography.caption.copyWith(color: AppColors.textSecondary))]),
                          ),
                          GestureDetector(
                            onTap: _handleTryAnother,
                            child: Column(children: [const Text('🔄', style: TextStyle(fontSize: 28)), const SizedBox(height: AppSpacing.xs), Text('Retry', style: AppTypography.caption.copyWith(color: AppColors.textSecondary))]),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppButton(title: 'Try Another Outfit', onPressed: _handleTryAnother, fullWidth: true, variant: ButtonVariant.outline),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Outfit/User Selection Screen
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(onTap: _handleBack, child: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.text))),
                  Text(_step == TryOnStep.outfit ? 'Select Outfit' : 'Your Photo', style: AppTypography.h3),
                  const SizedBox(width: 28),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_step == TryOnStep.outfit ? 'How do you want to add the outfit?' : 'Now take a photo of yourself', style: AppTypography.h2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(_step == TryOnStep.outfit ? 'Take a photo or upload from gallery' : 'Stand straight with arms slightly out', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.md),
                    
                    // Tips section
                    if (_step == TryOnStep.outfit)
                      _buildTipsBox('📸 Outfit Photo Tips', [
                        '✨ Clear, well-lit photo of the garment',
                        '👕 Flat lay or on hanger works best',
                        '🎯 Plain/contrasting background',
                        '📐 Full garment visible in frame',
                        '🔗 Or paste a product URL from any store',
                      ])
                    else
                      _buildTipsBox('🤳 Selfie Tips', [
                        '💡 Good lighting - face a window',
                        '🧍 Stand straight, arms slightly out',
                        '📏 Full body or waist-up visible',
                        '🎯 Plain background preferred',
                        '👀 Look at camera, natural pose',
                      ]),
                    
                    const SizedBox(height: AppSpacing.lg),
                    if (_step == TryOnStep.outfit) ...[
                      _buildOptionCard('📷', 'Camera', 'Take a photo of the outfit', () => _handleCameraCapture('outfit')),
                      _buildOptionCard('🖼️', 'Gallery', 'Pick from saved images', () => _handleGalleryPick('outfit')),
                      _buildOptionCard('🔗', 'URL / Link', 'Paste Pinterest or image URL', () => setState(() => _showUrlModal = true)),
                    ] else ...[
                      if (tryOnState.currentTryOn.outfitImage != null)
                        Center(
                          child: Column(
                            children: [
                              Text('Selected Outfit:', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                              const SizedBox(height: AppSpacing.sm),
                              ClipRRect(borderRadius: AppRadius.largeRadius, child: tryOnState.currentTryOn.outfitImage!.startsWith('http') 
                                ? Image.network(tryOnState.currentTryOn.outfitImage!, width: 120, height: 160, fit: BoxFit.cover)
                                : Image.file(File(tryOnState.currentTryOn.outfitImage!), width: 120, height: 160, fit: BoxFit.cover)),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                      _buildOptionCard('🤳', 'Take Selfie', 'Use front camera', () => _handleCameraCapture('user')),
                      _buildOptionCard('🖼️', 'From Gallery', 'Pick existing photo', () => _handleGalleryPick('user')),
                      if (prefsState.preferences.profilePhotoUri != null && prefsState.preferences.profilePhotoUri!.isNotEmpty)
                        _buildOptionCard('👤', 'Use Saved Photo', 'From onboarding', _useSavedPhoto),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // URL Modal
      floatingActionButton: _showUrlModal
          ? Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.lg),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.xlRadius),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Enter Image URL', style: AppTypography.h3),
                      const SizedBox(height: AppSpacing.lg),
                      TextField(
                        onChanged: (v) => setState(() => _imageUrl = v),
                        style: const TextStyle(color: AppColors.text),
                        decoration: InputDecoration(
                          hintText: 'https://...',
                          hintStyle: TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.surfaceLight,
                          border: OutlineInputBorder(borderRadius: AppRadius.mediumRadius, borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AppButton(title: 'Cancel', onPressed: () => setState(() => _showUrlModal = false), variant: ButtonVariant.ghost),
                          const SizedBox(width: AppSpacing.md),
                          AppButton(title: 'Add', onPressed: _handleUrlSubmit),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

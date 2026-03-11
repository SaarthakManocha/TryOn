// Edit Profile Screen
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _picker = ImagePicker();
  String? _photoUri;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(preferencesProvider).preferences;
    final user = ref.read(authProvider).user;
    _nameController.text = user?.name ?? '';
    _photoUri = prefs.profilePhotoUri;
  }

  Future<void> _pickPhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (photo != null) {
        setState(() {
          _photoUri = photo.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick image')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final photo = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
      if (photo != null) {
        setState(() {
          _photoUri = photo.path;
          _hasChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to take photo')),
        );
      }
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ListTile(
              leading: const Text('📷', style: TextStyle(fontSize: 24)),
              title: const Text('Take Photo', style: AppTypography.body),
              onTap: () {
                Navigator.pop(ctx);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Text('🖼️', style: TextStyle(fontSize: 24)),
              title: const Text('Choose from Gallery', style: AppTypography.body),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto();
              },
            ),
            if (_photoUri != null)
              ListTile(
                leading: Text('🗑️', style: TextStyle(fontSize: 24)),
                title: Text('Remove Photo', style: AppTypography.body.copyWith(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _photoUri = null;
                    _hasChanges = true;
                  });
                },
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  Future<void> _saveChanges() async {
    await ref.read(preferencesProvider.notifier).updatePreferences(
      profilePhotoUri: _photoUri,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

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
                  Text('Edit Profile', style: AppTypography.h2),
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
                  children: [
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Profile Photo
                    GestureDetector(
                      onTap: _showPhotoOptions,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 3),
                            ),
                            child: _photoUri != null && _photoUri!.isNotEmpty
                                ? ClipOval(
                                    child: _photoUri!.startsWith('http')
                                        ? Image.network(_photoUri!, fit: BoxFit.cover, width: 120, height: 120)
                                        : Image.file(File(_photoUri!), fit: BoxFit.cover, width: 120, height: 120),
                                  )
                                : const Center(child: Text('👤', style: TextStyle(fontSize: 56))),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.background, width: 3),
                              ),
                              child: const Center(child: Text('📷', style: TextStyle(fontSize: 16))),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Tap to change photo', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),

                    const SizedBox(height: AppSpacing.xl * 2),

                    // Name Field (read-only for Firebase users)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        children: [
                          const Text('👤', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                Text(authState.user?.name ?? 'User', style: AppTypography.body),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Email Field (read-only)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.mediumRadius,
                      ),
                      child: Row(
                        children: [
                          const Text('📧', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Email', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                Text(authState.user?.email ?? 'email@example.com', style: AppTypography.body),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: AppRadius.smallRadius,
                            ),
                            child: Text('Verified', style: AppTypography.caption.copyWith(color: AppColors.success)),
                          ),
                        ],
                      ),
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}

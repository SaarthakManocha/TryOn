// Body Profile Provider - Stores the user's body profile for VTON
// This is created ONCE during onboarding and reused for all try-ons
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// BodyProfile - The core data model for virtual try-on
/// Created once during onboarding, reused for all future try-ons
class BodyProfile {
  // === User Input (collected during onboarding) ===
  final String gender;           // 'male', 'female', 'other'
  final int heightCm;            // Height in centimeters (140-210)
  final String bodyBuild;        // 'slim', 'regular', 'chubby', 'muscular'
  final String? selfieImagePath; // Local path to user's selfie
  
  // === Backend Generated (Firebase Storage URLs) ===
  final List<int>? skinToneRgb;       // [R, G, B] extracted from selfie
  final String? faceImageUrl;         // Firebase Storage URL for face
  final String? hairImageUrl;         // Firebase Storage URL for hair
  final String? hairMaskUrl;          // Firebase Storage URL for hair mask
  final String? baseBodyImageUrl;     // Firebase Storage URL for base body
  
  // === Metadata ===
  final DateTime? createdAt;
  final DateTime? processedAt;
  final bool isProcessed;            // True after backend has processed

  BodyProfile({
    this.gender = '',
    this.heightCm = 170,
    this.bodyBuild = '',
    this.selfieImagePath,
    this.skinToneRgb,
    this.faceImageUrl,
    this.hairImageUrl,
    this.hairMaskUrl,
    this.baseBodyImageUrl,
    this.createdAt,
    this.processedAt,
    this.isProcessed = false,
  });

  /// Check if onboarding data is complete (ready to send to backend)
  bool get isOnboardingComplete =>
      gender.isNotEmpty &&
      heightCm >= 140 &&
      heightCm <= 210 &&
      bodyBuild.isNotEmpty &&
      selfieImagePath != null &&
      selfieImagePath!.isNotEmpty;

  /// Check if profile is ready for try-on (backend has processed)
  bool get isReadyForTryOn => isProcessed && baseBodyImageUrl != null;

  /// Convert to JSON for storage/API
  Map<String, dynamic> toJson() => {
    'gender': gender,
    'height_cm': heightCm,
    'body_build': bodyBuild,
    'selfie_image_path': selfieImagePath,
    'skin_tone_rgb': skinToneRgb,
    'face_image_url': faceImageUrl,
    'hair_image_url': hairImageUrl,
    'hair_mask_url': hairMaskUrl,
    'base_body_image_url': baseBodyImageUrl,
    'created_at': createdAt?.toIso8601String(),
    'processed_at': processedAt?.toIso8601String(),
    'is_processed': isProcessed,
  };

  /// Create from JSON (from storage/API)
  factory BodyProfile.fromJson(Map<String, dynamic> json) => BodyProfile(
    gender: json['gender'] as String? ?? '',
    heightCm: json['height_cm'] as int? ?? 170,
    bodyBuild: json['body_build'] as String? ?? '',
    selfieImagePath: json['selfie_image_path'] as String?,
    skinToneRgb: json['skin_tone_rgb'] != null 
        ? List<int>.from(json['skin_tone_rgb']) 
        : null,
    faceImageUrl: json['face_image_url'] as String?,
    hairImageUrl: json['hair_image_url'] as String?,
    hairMaskUrl: json['hair_mask_url'] as String?,
    baseBodyImageUrl: json['base_body_image_url'] as String?,
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : null,
    processedAt: json['processed_at'] != null 
        ? DateTime.parse(json['processed_at']) 
        : null,
    isProcessed: json['is_processed'] as bool? ?? false,
  );

  /// Create a copy with updated fields
  BodyProfile copyWith({
    String? gender,
    int? heightCm,
    String? bodyBuild,
    String? selfieImagePath,
    List<int>? skinToneRgb,
    String? faceImageUrl,
    String? hairImageUrl,
    String? hairMaskUrl,
    String? baseBodyImageUrl,
    DateTime? createdAt,
    DateTime? processedAt,
    bool? isProcessed,
  }) => BodyProfile(
    gender: gender ?? this.gender,
    heightCm: heightCm ?? this.heightCm,
    bodyBuild: bodyBuild ?? this.bodyBuild,
    selfieImagePath: selfieImagePath ?? this.selfieImagePath,
    skinToneRgb: skinToneRgb ?? this.skinToneRgb,
    faceImageUrl: faceImageUrl ?? this.faceImageUrl,
    hairImageUrl: hairImageUrl ?? this.hairImageUrl,
    hairMaskUrl: hairMaskUrl ?? this.hairMaskUrl,
    baseBodyImageUrl: baseBodyImageUrl ?? this.baseBodyImageUrl,
    createdAt: createdAt ?? this.createdAt,
    processedAt: processedAt ?? this.processedAt,
    isProcessed: isProcessed ?? this.isProcessed,
  );

  @override
  String toString() => 'BodyProfile(gender: $gender, height: ${heightCm}cm, '
      'build: $bodyBuild, processed: $isProcessed)';
}

/// State wrapper for BodyProfile
class BodyProfileState {
  final BodyProfile profile;
  final bool isLoading;
  final String? error;

  BodyProfileState({
    BodyProfile? profile,
    this.isLoading = false,
    this.error,
  }) : profile = profile ?? BodyProfile();

  BodyProfileState copyWith({
    BodyProfile? profile,
    bool? isLoading,
    String? error,
  }) => BodyProfileState(
    profile: profile ?? this.profile,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

/// BodyProfile Notifier - Manages body profile state and persistence
class BodyProfileNotifier extends StateNotifier<BodyProfileState> {
  static const String _storageKey = '@tryon_body_profile';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  BodyProfileNotifier() : super(BodyProfileState()) {
    _loadProfile();
  }

  /// Load profile from local storage and Firestore
  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      // Try local storage first
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      
      if (jsonStr != null) {
        final profile = BodyProfile.fromJson(jsonDecode(jsonStr));
        state = state.copyWith(profile: profile, isLoading: false);
        return;
      }

      // Try Firestore if logged in
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('profile')
            .doc('body')
            .get();
        
        if (doc.exists && doc.data() != null) {
          final profile = BodyProfile.fromJson(doc.data()!);
          await _saveLocally(profile);
          state = state.copyWith(profile: profile, isLoading: false);
          return;
        }
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Save profile locally
  Future<void> _saveLocally(BodyProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }

  /// Save profile to Firestore
  Future<void> _saveToFirestore(BodyProfile profile) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('profile')
          .doc('body')
          .set(profile.toJson());
    }
  }

  // === Onboarding Methods ===

  /// Update gender selection
  void setGender(String gender) {
    state = state.copyWith(
      profile: state.profile.copyWith(gender: gender),
    );
  }

  /// Update height
  void setHeight(int heightCm) {
    state = state.copyWith(
      profile: state.profile.copyWith(heightCm: heightCm),
    );
  }

  /// Update body build
  void setBodyBuild(String bodyBuild) {
    state = state.copyWith(
      profile: state.profile.copyWith(bodyBuild: bodyBuild),
    );
  }

  /// Update selfie image path
  void setSelfieImage(String path) {
    state = state.copyWith(
      profile: state.profile.copyWith(selfieImagePath: path),
    );
  }

  /// Save completed onboarding profile
  Future<void> saveOnboardingProfile() async {
    if (!state.profile.isOnboardingComplete) {
      state = state.copyWith(error: 'Profile data incomplete');
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final profile = state.profile.copyWith(
        createdAt: DateTime.now(),
      );
      
      await _saveLocally(profile);
      await _saveToFirestore(profile);
      
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // === Backend Processing Methods (to be called after backend processes) ===

  /// Update profile with backend-generated data (Firebase Storage URLs)
  Future<void> updateWithProcessedData({
    required List<int> skinToneRgb,
    required String faceImageUrl,
    required String baseBodyImageUrl,
    String? hairImageUrl,
    String? hairMaskUrl,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      final profile = state.profile.copyWith(
        skinToneRgb: skinToneRgb,
        faceImageUrl: faceImageUrl,
        hairImageUrl: hairImageUrl,
        hairMaskUrl: hairMaskUrl,
        baseBodyImageUrl: baseBodyImageUrl,
        processedAt: DateTime.now(),
        isProcessed: true,
      );
      
      await _saveLocally(profile);
      await _saveToFirestore(profile);
      
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear profile (for logout or reset)
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    state = BodyProfileState();
  }
}

/// Provider for BodyProfile
final bodyProfileProvider = 
    StateNotifierProvider<BodyProfileNotifier, BodyProfileState>((ref) {
  return BodyProfileNotifier();
});

// === Body Build Options ===
class BodyBuildOption {
  final String id;
  final String label;
  final String emoji;
  final String description;

  const BodyBuildOption({
    required this.id,
    required this.label,
    required this.emoji,
    required this.description,
  });
}

const bodyBuildOptions = [
  BodyBuildOption(
    id: 'slim',
    label: 'Slim',
    emoji: '🏃',
    description: 'Lean and slender build',
  ),
  BodyBuildOption(
    id: 'regular',
    label: 'Regular',
    emoji: '🧍',
    description: 'Average, balanced build',
  ),
  BodyBuildOption(
    id: 'chubby',
    label: 'Chubby',
    emoji: '🧸',
    description: 'Soft, rounded build',
  ),
  BodyBuildOption(
    id: 'muscular',
    label: 'Muscular',
    emoji: '💪',
    description: 'Athletic, built physique',
  ),
];

// Preferences Provider - User style and body preferences with Firestore sync
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// User preferences model
class UserPreferences {
  final List<String> styles;
  final List<String> colors;
  final String height;
  final String bodyType;
  final String topSize;
  final String bottomSize;
  final String gender;
  final String? profilePhotoUri;

  UserPreferences({
    this.styles = const [],
    this.colors = const [],
    this.height = '',
    this.bodyType = '',
    this.topSize = '',
    this.bottomSize = '',
    this.gender = '',
    this.profilePhotoUri,
  });

  Map<String, dynamic> toJson() => {
        'styles': styles,
        'colors': colors,
        'height': height,
        'bodyType': bodyType,
        'topSize': topSize,
        'bottomSize': bottomSize,
        'gender': gender,
        'profilePhotoUri': profilePhotoUri,
      };

  factory UserPreferences.fromJson(Map<String, dynamic> json) => UserPreferences(
        styles: List<String>.from(json['styles'] ?? []),
        colors: List<String>.from(json['colors'] ?? []),
        height: json['height'] as String? ?? '',
        bodyType: json['bodyType'] as String? ?? '',
        topSize: json['topSize'] as String? ?? '',
        bottomSize: json['bottomSize'] as String? ?? '',
        gender: json['gender'] as String? ?? '',
        profilePhotoUri: json['profilePhotoUri'] as String?,
      );

  UserPreferences copyWith({
    List<String>? styles,
    List<String>? colors,
    String? height,
    String? bodyType,
    String? topSize,
    String? bottomSize,
    String? gender,
    String? profilePhotoUri,
  }) =>
      UserPreferences(
        styles: styles ?? this.styles,
        colors: colors ?? this.colors,
        height: height ?? this.height,
        bodyType: bodyType ?? this.bodyType,
        topSize: topSize ?? this.topSize,
        bottomSize: bottomSize ?? this.bottomSize,
        gender: gender ?? this.gender,
        profilePhotoUri: profilePhotoUri ?? this.profilePhotoUri,
      );
}

// Preferences state
class PreferencesState {
  final UserPreferences preferences;
  final bool isLoading;

  PreferencesState({
    UserPreferences? preferences,
    this.isLoading = true,
  }) : preferences = preferences ?? UserPreferences();

  PreferencesState copyWith({
    UserPreferences? preferences,
    bool? isLoading,
  }) =>
      PreferencesState(
        preferences: preferences ?? this.preferences,
        isLoading: isLoading ?? this.isLoading,
      );
}

// Preferences notifier with Firestore sync and auth listener
class PreferencesNotifier extends StateNotifier<PreferencesState> {
  static const String _preferencesKey = '@tryon_preferences';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  PreferencesNotifier() : super(PreferencesState()) {
    _initAuthListener();
  }

  void _initAuthListener() {
    // Listen to auth state changes and reload preferences when user logs in
    _authSubscription = _auth.authStateChanges().listen((user) {
      if (user != null) {
        // User just logged in - reload preferences from Firestore
        loadPreferences();
      } else {
        // User logged out - clear to defaults
        state = PreferencesState(isLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPreferences() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // First try to load from Firestore if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        final data = doc.data();
        if (data != null && data['preferences'] != null) {
          final preferences = UserPreferences.fromJson(
            Map<String, dynamic>.from(data['preferences']),
          );
          state = state.copyWith(preferences: preferences, isLoading: false);
          
          // Also update local cache
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_preferencesKey, jsonEncode(preferences.toJson()));
          return;
        }
      }

      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_preferencesKey);

      if (stored != null) {
        final preferences = UserPreferences.fromJson(jsonDecode(stored));
        state = state.copyWith(preferences: preferences, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updatePreferences({
    List<String>? styles,
    List<String>? colors,
    String? height,
    String? bodyType,
    String? topSize,
    String? bottomSize,
    String? gender,
    String? profilePhotoUri,
  }) async {
    try {
      final updated = state.preferences.copyWith(
        styles: styles,
        colors: colors,
        height: height,
        bodyType: bodyType,
        topSize: topSize,
        bottomSize: bottomSize,
        gender: gender,
        profilePhotoUri: profilePhotoUri,
      );

      // Save to local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_preferencesKey, jsonEncode(updated.toJson()));
      
      // Also save to Firestore if user is logged in
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'preferences': updated.toJson(),
        }, SetOptions(merge: true));
      }
      
      state = state.copyWith(preferences: updated);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_preferencesKey);
      state = state.copyWith(preferences: UserPreferences());
    } catch (e) {
      // Handle error
    }
  }
}

// Provider
final preferencesProvider =
    StateNotifierProvider<PreferencesNotifier, PreferencesState>((ref) {
  return PreferencesNotifier();
});

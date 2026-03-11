// Auth Provider - Firebase Authentication State
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/firebase_auth_service.dart';

// User model
class User {
  final String id;
  final String email;
  final String name;
  final String? profilePhotoUri;
  final bool emailVerified;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.profilePhotoUri,
    this.emailVerified = false,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? profilePhotoUri,
    bool? emailVerified,
  }) =>
      User(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        profilePhotoUri: profilePhotoUri ?? this.profilePhotoUri,
        emailVerified: emailVerified ?? this.emailVerified,
      );

  factory User.fromFirebaseUser(fb.User firebaseUser) => User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        profilePhotoUri: firebaseUser.photoURL,
        emailVerified: firebaseUser.emailVerified,
      );
}

// Auth state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool onboardingComplete;
  final bool needsEmailVerification;
  final String? error;

  AuthState({
    this.user,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.onboardingComplete = false,
    this.needsEmailVerification = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    bool? isLoading,
    bool? onboardingComplete,
    bool? needsEmailVerification,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        isLoading: isLoading ?? this.isLoading,
        onboardingComplete: onboardingComplete ?? this.onboardingComplete,
        needsEmailVerification: needsEmailVerification ?? this.needsEmailVerification,
        error: clearError ? null : (error ?? this.error),
      );
}

// Auth notifier with Firebase
class AuthNotifier extends StateNotifier<AuthState> {
  static const String _onboardingKey = '@tryon_onboarding';
  static const String _pendingVerificationKey = '@tryon_pending_verification';
  final FirebaseAuthService _authService = firebaseAuthService;
  StreamSubscription<fb.User?>? _authSubscription;

  AuthNotifier() : super(AuthState()) {
    _initAuth();
  }

  void _initAuth() {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser != null) {
        final user = User.fromFirebaseUser(firebaseUser);
        final prefs = await SharedPreferences.getInstance();
        final onboarding = prefs.getString(_onboardingKey);
        final pendingVerification = prefs.getBool(_pendingVerificationKey) ?? false;

        // Check Firestore for onboarding status
        Map<String, dynamic>? userData;
        try {
          userData = await _authService.getUserData(firebaseUser.uid);
        } catch (e) {
          // Firestore might fail, use local storage as fallback
          userData = null;
        }
        
        final onboardingComplete = userData?['onboardingComplete'] ?? (onboarding == 'true');

        // Check if email verification is needed (only for email/password users, not Google)
        final isGoogleUser = firebaseUser.providerData.any((p) => p.providerId == 'google.com');
        final needsVerification = pendingVerification || (!isGoogleUser && !firebaseUser.emailVerified);

        state = state.copyWith(
          user: user,
          isAuthenticated: true,
          onboardingComplete: onboardingComplete,
          needsEmailVerification: needsVerification,
          isLoading: false,
          clearError: true,
        );
      } else {
        state = AuthState(isLoading: false);
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // Sign up with email and password
  Future<bool> signup(String name, String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      
      // Set pending verification flag BEFORE signup
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingVerificationKey, true);
      await prefs.setString(_onboardingKey, 'false');
      
      await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );
      
      // Force the state to show verification
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        needsEmailVerification: true,
        onboardingComplete: false,
      );
      return true;
    } catch (e) {
      // Clear pending verification on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingVerificationKey, false);
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _authService.signInWithEmail(email: email, password: password);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final result = await _authService.signInWithGoogle();
      if (result == null) {
        state = state.copyWith(isLoading: false);
        return false; // User cancelled
      }
      
      // Check if this is a new Google user - they need onboarding
      final isNewUser = result['isNewUser'] as bool;
      if (isNewUser) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_onboardingKey, 'false');
        state = state.copyWith(
          isLoading: false,
          onboardingComplete: false,
        );
      }
      
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingVerificationKey, false);
      await _authService.signOut();
      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Set onboarding complete
  Future<void> setOnboardingComplete(bool complete) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_onboardingKey, complete.toString());
      
      // Update Firestore
      if (state.user != null) {
        await _authService.updateUserData(state.user!.id, {
          'onboardingComplete': complete,
        });
      }
      
      state = state.copyWith(onboardingComplete: complete);
    } catch (e) {
      // Handle error silently
    }
  }

  // Resend verification email
  Future<bool> resendVerificationEmail() async {
    try {
      await _authService.resendVerificationEmail();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // Check email verification status
  Future<bool> checkEmailVerification() async {
    try {
      final verified = await _authService.reloadAndCheckVerification();
      if (verified) {
        // Clear pending verification flag
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_pendingVerificationKey, false);
        
        if (state.user != null) {
          state = state.copyWith(
            user: state.user!.copyWith(emailVerified: true),
            needsEmailVerification: false,
          );
        }
      }
      return verified;
    } catch (e) {
      return false;
    }
  }

  // Update profile
  Future<void> updateProfile({String? name, String? profilePhotoUri}) async {
    try {
      if (state.user == null) return;

      final updatedUser = state.user!.copyWith(
        name: name,
        profilePhotoUri: profilePhotoUri,
      );

      // Update Firestore
      await _authService.updateUserData(state.user!.id, {
        if (name != null) 'name': name,
        if (profilePhotoUri != null) 'profilePhotoUri': profilePhotoUri,
      });

      state = state.copyWith(user: updatedUser);
    } catch (e) {
      // Handle error
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

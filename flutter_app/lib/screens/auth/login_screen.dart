// Login Screen with Firebase - Proper validation order
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../services/firebase_auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  String _email = '';
  String _password = '';
  bool _loading = false;
  bool _googleLoading = false;
  String? _loginError;
  Map<String, String?> _errors = {};

  // Step 1: Validate email format (before calling Firebase)
  bool _isValidEmailFormat(String email) {
    // Must have @ and proper domain
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _validate() {
    final newErrors = <String, String?>{};
    setState(() => _loginError = null);

    // Check email is not empty
    if (_email.isEmpty) {
      newErrors['email'] = 'Email is required';
    } 
    // Check email format is valid
    else if (!_isValidEmailFormat(_email)) {
      newErrors['email'] = 'Please enter a valid email (example: name@gmail.com)';
    }

    // Check password is not empty
    if (_password.isEmpty) {
      newErrors['password'] = 'Password is required';
    } else if (_password.length < 6) {
      newErrors['password'] = 'Password must be at least 6 characters';
    }

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

  // Get specific error message based on Firebase error
  String _getSpecificError(String errorMsg) {
    final lowerError = errorMsg.toLowerCase();
    
    // CHECK DISABLED ACCOUNT FIRST (before generic errors)
    if (lowerError.contains('user-disabled') ||
        lowerError.contains('user disabled') ||
        lowerError.contains('disabled') ||
        lowerError.contains('account has been disabled')) {
      return '⛔ Account Disabled\n\nThis account has been disabled and cannot sign in.\n\nPlease contact support for help.';
    }
    
    // Account doesn't exist
    if (lowerError.contains('user-not-found') || 
        lowerError.contains('no user record') ||
        lowerError.contains('no account found') ||
        lowerError.contains('user not found')) {
      return '🚫 Account Not Found\n\nNo account exists with this email address. Please check the email or sign up for a new account.';
    }
    
    // Wrong password (account exists but password is wrong)
    if (lowerError.contains('wrong-password') || 
        lowerError.contains('wrong password') ||
        lowerError.contains('incorrect password')) {
      return '🔐 Wrong Password\n\nThe password you entered is incorrect. Please try again or use "Forgot Password" to reset it.';
    }
    
    // Invalid email format (Firebase side check)
    if (lowerError.contains('invalid-email') ||
        lowerError.contains('invalid email')) {
      return '📧 Invalid Email\n\nPlease enter a valid email address (example: name@gmail.com).';
    }
    
    // Too many attempts
    if (lowerError.contains('too-many-requests') ||
        lowerError.contains('too many requests') ||
        lowerError.contains('blocked')) {
      return '⏳ Too Many Attempts\n\nYou\'ve tried too many times. Please wait a few minutes before trying again.';
    }
    
    // Network error
    if (lowerError.contains('network') ||
        lowerError.contains('connection') ||
        lowerError.contains('timeout')) {
      return '🌐 Connection Error\n\nPlease check your internet connection and try again.';
    }
    
    // Firebase's generic error (check LAST as fallback)
    if (lowerError.contains('invalid-credential') ||
        lowerError.contains('invalid_login_credentials') ||
        lowerError.contains('invalid credential') ||
        lowerError.contains('login credentials')) {
      return '🔐 Invalid Credentials\n\nThe email or password is incorrect.\n\n• If you don\'t have an account, tap "Sign Up" below\n• If you forgot your password, tap "Forgot Password?"';
    }
    
    // Default - show helpful message
    return '❌ Login Failed\n\nPlease check your email and password and try again.\n\nIf you don\'t have an account, tap "Sign Up" below.';
  }

  Future<void> _handleLogin() async {
    // Step 1: Client-side validation (email format, password length)
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _loginError = null;
    });

    try {
      // Step 2: Call Firebase - it will check if account exists and password is correct
      await firebaseAuthService.signInWithEmail(
        email: _email.trim(),
        password: _password,
      );
      // Success - auth state listener handles navigation
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = _getSpecificError(e.toString());
          _loading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _googleLoading = true;
      _loginError = null;
    });
    
    try {
      final result = await firebaseAuthService.signInWithGoogle();
      if (result == null && mounted) {
        setState(() => _googleLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loginError = 'Google sign-in failed. Please try again.';
          _googleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),
              // Header with app icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.largeRadius,
                    boxShadow: AppShadows.md,
                  ),
                  child: const Center(
                    child: Text('👗', style: TextStyle(fontSize: 40)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Center(child: Text('TryOn', style: AppTypography.h1)),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: Text(
                  'Your AI-powered virtual fitting room',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              // Error message displayed prominently
              if (_loginError != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(color: AppColors.error.withOpacity(0.5)),
                  ),
                  child: Text(
                    _loginError!,
                    style: AppTypography.body.copyWith(color: AppColors.error),
                  ),
                ),
              // Email input with inline error
              AppInput(
                label: 'Email',
                placeholder: 'Enter your email (e.g. name@gmail.com)',
                value: _email,
                onChanged: (v) => setState(() {
                  _email = v;
                  _loginError = null;
                  _errors.remove('email');
                }),
                keyboardType: TextInputType.emailAddress,
                error: _errors['email'],
                prefixIcon: const Text('✉️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Password input with inline error
              AppInput(
                label: 'Password',
                placeholder: 'Enter your password',
                value: _password,
                onChanged: (v) => setState(() {
                  _password = v;
                  _loginError = null;
                  _errors.remove('password');
                }),
                obscureText: true,
                error: _errors['password'],
                prefixIcon: const Text('🔒', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: AppSpacing.md),
              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => context.push('/forgot-password'),
                  child: Text(
                    'Forgot Password?',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Login Button
              AppButton(
                title: 'Sign In',
                onPressed: _handleLogin,
                loading: _loading,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.surfaceLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text('or', style: AppTypography.body.copyWith(color: AppColors.textMuted)),
                  ),
                  Expanded(child: Divider(color: AppColors.surfaceLight)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              // Google Sign In
              AppButton(
                title: 'Continue with Google',
                onPressed: _handleGoogleLogin,
                loading: _googleLoading,
                fullWidth: true,
                variant: ButtonVariant.outline,
                icon: const Text('G', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/signup'),
                    child: Text(
                      'Sign Up',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

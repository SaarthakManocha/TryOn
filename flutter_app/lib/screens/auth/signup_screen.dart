// Signup Screen with Firebase
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String _name = '';
  String _email = '';
  String _password = '';
  bool _agreed = false;
  bool _loading = false;
  bool _googleLoading = false;
  Map<String, String?> _errors = {};

  Map<String, dynamic> get _passwordStrength {
    int strength = 0;
    if (_password.length >= 6) strength++;
    if (_password.length >= 8) strength++;
    if (RegExp(r'[A-Z]').hasMatch(_password)) strength++;
    if (RegExp(r'[0-9]').hasMatch(_password)) strength++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(_password)) strength++;

    if (strength <= 1) {
      return {'level': 1, 'text': 'Weak', 'color': AppColors.error};
    }
    if (strength <= 3) {
      return {'level': 2, 'text': 'Medium', 'color': AppColors.warning};
    }
    return {'level': 3, 'text': 'Strong', 'color': AppColors.success};
  }

  bool _validate() {
    final newErrors = <String, String?>{};

    if (_name.trim().isEmpty) {
      newErrors['name'] = 'Name is required';
    }

    if (_email.isEmpty) {
      newErrors['email'] = 'Email is required';
    } else if (!RegExp(r'\S+@\S+\.\S+').hasMatch(_email)) {
      newErrors['email'] = 'Please enter a valid email';
    }

    if (_password.isEmpty) {
      newErrors['password'] = 'Password is required';
    } else if (_password.length < 6) {
      newErrors['password'] = 'Password must be at least 6 characters';
    }

    setState(() => _errors = newErrors);
    return newErrors.isEmpty;
  }

  Future<void> _handleSignup() async {
    if (!_validate()) return;

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please agree to the Terms and Conditions')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final success = await ref.read(authProvider.notifier).signup(_name, _email, _password);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email to verify your account.'),
            duration: Duration(seconds: 4),
          ),
        );
      } else if (!success && mounted) {
        final error = ref.read(authProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Signup failed. Please try again.')),
        );
        ref.read(authProvider.notifier).clearError();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _googleLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).signInWithGoogle();
      if (!success && mounted) {
        final error = ref.read(authProvider).error;
        if (error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error)),
          );
          ref.read(authProvider.notifier).clearError();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google sign-in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Terms and Conditions', style: AppTypography.h3),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('✕', style: TextStyle(fontSize: 20, color: AppColors.textMuted)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    '''Welcome to TryOn! By using our app, you agree to the following terms:

1. ACCEPTANCE OF TERMS
By accessing and using TryOn, you accept and agree to be bound by these Terms and Conditions.

2. DESCRIPTION OF SERVICE
TryOn provides virtual try-on services that allow users to visualize clothing on their photos using AI technology.

3. USER ACCOUNTS
• You must provide accurate information when creating an account
• You are responsible for maintaining account security
• You must be at least 13 years old to use this service

4. USER CONTENT
• You retain ownership of photos you upload
• You grant TryOn a license to process your images for the service
• Images are processed securely and not shared with third parties

5. PRIVACY
• We collect and process data as described in our Privacy Policy
• Your photos are used solely for try-on processing
• We do not sell your personal data

6. ACCEPTABLE USE
You agree not to:
• Upload inappropriate or illegal content
• Attempt to reverse engineer the service
• Use the service for commercial purposes without permission

7. INTELLECTUAL PROPERTY
All TryOn branding, technology, and content are protected by intellectual property laws.

8. DISCLAIMER
The service is provided "as is" without warranties. Virtual try-on results are approximations.

9. LIMITATION OF LIABILITY
TryOn is not liable for any indirect, incidental, or consequential damages.

10. CHANGES TO TERMS
We may update these terms at any time. Continued use constitutes acceptance.

Last updated: January 2026

Contact: support@tryonapp.com''',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppRadius.mediumRadius),
                  ),
                  child: const Text('I Understand', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = _passwordStrength;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => context.pop(),
                child: const Text('←', style: TextStyle(fontSize: 28, color: AppColors.text)),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Header
              const Text('Create Account', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Join TryOn and discover your perfect style',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Google Sign Up Button
              GestureDetector(
                onTap: _googleLoading ? null : _handleGoogleSignup,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: _googleLoading
                      ? const Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF4285F4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text('Sign up with Google', style: AppTypography.button),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Divider
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: AppColors.surfaceLight)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'or sign up with email',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  Expanded(child: Container(height: 1, color: AppColors.surfaceLight)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              // Form
              AppInput(
                label: 'Full Name',
                placeholder: 'Enter your name',
                value: _name,
                onChanged: (v) => setState(() => _name = v),
                textCapitalization: TextCapitalization.words,
                error: _errors['name'],
                prefixIcon: const Text('👤', style: TextStyle(fontSize: 18)),
              ),
              AppInput(
                label: 'Email',
                placeholder: 'Enter your email',
                value: _email,
                onChanged: (v) => setState(() => _email = v),
                keyboardType: TextInputType.emailAddress,
                error: _errors['email'],
                prefixIcon: const Text('✉️', style: TextStyle(fontSize: 18)),
              ),
              AppInput(
                label: 'Password',
                placeholder: 'Create a password',
                value: _password,
                onChanged: (v) => setState(() => _password = v),
                obscureText: true,
                error: _errors['password'],
                prefixIcon: const Text('🔒', style: TextStyle(fontSize: 18)),
              ),
              // Password Strength
              if (_password.isNotEmpty) ...[
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: List.generate(3, (index) {
                          final level = index + 1;
                          return Expanded(
                            child: Container(
                              height: 4,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: BoxDecoration(
                                color: level <= strength['level']
                                    ? strength['color'] as Color
                                    : AppColors.surfaceLight,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      strength['text'] as String,
                      style: AppTypography.caption.copyWith(
                        color: strength['color'] as Color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              // Terms Checkbox
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _agreed ? AppColors.primary : Colors.transparent,
                          borderRadius: AppRadius.smallRadius,
                          border: Border.all(
                            color: _agreed ? AppColors.primary : AppColors.surfaceLight,
                            width: 2,
                          ),
                        ),
                        child: _agreed
                            ? const Center(
                                child: Text('✓',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _agreed = !_agreed),
                        child: Text.rich(
                          TextSpan(
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              WidgetSpan(
                                child: GestureDetector(
                                  onTap: () => _showTermsDialog(context),
                                  child: Text(
                                    'Terms and Conditions',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                title: 'Create Account',
                onPressed: _handleSignup,
                loading: _loading,
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.xl),
              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'Sign In',
                      style: AppTypography.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              // Add padding for system navigation bar
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

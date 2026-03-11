// Forgot Password Screen with Firebase - Direct call with confirmation page
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../services/firebase_auth_service.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  String _email = '';
  bool _loading = false;
  bool _sent = false;
  String? _error;

  bool _validate() {
    if (_email.isEmpty) {
      setState(() => _error = 'Email is required');
      return false;
    }
    if (!RegExp(r'\S+@\S+\.\S+').hasMatch(_email)) {
      setState(() => _error = 'Please enter a valid email');
      return false;
    }
    setState(() => _error = null);
    return true;
  }

  Future<void> _handleReset() async {
    if (!_validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Call Firebase directly
      await firebaseAuthService.sendPasswordResetEmail(_email);
      if (mounted) {
        setState(() {
          _sent = true;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text, style: AppTypography.body),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // SUCCESS - Show confirmation page with instructions
    if (_sent) {
      return Scaffold(
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.xl),
                // Success icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('✅', style: TextStyle(fontSize: 50)),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                // Confirmation heading
                Text(
                  'Reset Link Sent!',
                  style: AppTypography.h1.copyWith(color: AppColors.success),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'We have sent a password reset link to:',
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: Text(
                    _email,
                    style: AppTypography.body.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                // Instructions box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.largeRadius,
                    border: Border.all(color: AppColors.surfaceLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Follow These Steps:',
                            style: AppTypography.h3,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildStep('1', 'Open your email inbox'),
                      _buildStep('2', 'Look for an email from TryOn (check Spam/Junk folder too!)'),
                      _buildStep('3', 'Click the "Reset Password" link in the email'),
                      _buildStep('4', 'Enter your new password on the page that opens'),
                      _buildStep('5', 'Come back here and sign in with your new password'),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Warning note
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Text('⏰', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Link expires in 1 hour. If you don\'t see the email, check your Spam folder.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl + bottomPadding + 100),
              ],
            ),
          ),
        ),
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
              AppButton(
                title: 'Back to Sign In',
                onPressed: () => context.go('/login'),
                fullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => setState(() => _sent = false),
                child: Text(
                  "Didn't receive the email? Try again",
                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // INPUT - Email entry screen
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Button
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.mediumRadius,
                  ),
                  child: const Center(
                    child: Text('←', style: TextStyle(fontSize: 24, color: AppColors.text)),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Header
              const Text('Reset Password', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Enter your email address and we\'ll send you a link to reset your password.',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              // How it works box
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.mediumRadius,
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        'You\'ll receive an email with a link to create a new password.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Error display
              if (_error != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: AppRadius.mediumRadius,
                    border: Border.all(color: AppColors.error.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      const Text('⚠️', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.body.copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              // Form
              AppInput(
                label: 'Email',
                placeholder: 'Enter your email address',
                value: _email,
                onChanged: (v) => setState(() {
                  _email = v;
                  _error = null;
                }),
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Text('✉️', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                title: 'Send Reset Link',
                onPressed: _handleReset,
                loading: _loading,
                fullWidth: true,
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.2 + bottomPadding),
            ],
          ),
        ),
      ),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password? ',
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
      ),
    );
  }
}

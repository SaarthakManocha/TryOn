// Email Verification Screen - Blocks until email is verified
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../providers/providers.dart';
import '../../services/firebase_auth_service.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  Timer? _timer;
  bool _isResending = false;
  bool _canResend = true;
  int _resendCooldown = 0;

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
  }

  void _startVerificationCheck() {
    // Check every 3 seconds if email is verified
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final verified = await firebaseAuthService.reloadAndCheckVerification();
      if (verified && mounted) {
        timer.cancel();
        // Update auth state to trigger navigation
        ref.read(authProvider.notifier).checkEmailVerification();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (!_canResend) return;

    setState(() {
      _isResending = true;
    });

    try {
      await firebaseAuthService.resendVerificationEmail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: AppColors.success,
          ),
        );
        // Start cooldown
        setState(() {
          _canResend = false;
          _resendCooldown = 60;
        });
        _startCooldownTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send email: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _startCooldownTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCooldown <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _canResend = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _resendCooldown--;
          });
        }
      }
    });
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final email = authState.user?.email ?? 'your email';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              // Email icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📧', style: TextStyle(fontSize: 64)),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // Title
              const Text('Verify Your Email', style: AppTypography.h1),
              const SizedBox(height: AppSpacing.md),
              // Description
              Text(
                'We sent a verification link to',
                style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                email,
                style: AppTypography.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Instructions
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.largeRadius,
                ),
                child: Column(
                  children: [
                    _buildStep('1', 'Open your email inbox'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildStep('2', 'Click the verification link'),
                    const SizedBox(height: AppSpacing.sm),
                    _buildStep('3', 'Return to this app'),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Auto-checking indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Waiting for verification...',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              const Spacer(),
              // Resend button
              AppButton(
                title: _canResend 
                    ? 'Resend Verification Email'
                    : 'Resend in ${_resendCooldown}s',
                onPressed: _canResend ? _resendEmail : () {},
                loading: _isResending,
                fullWidth: true,
                variant: _canResend ? ButtonVariant.primary : ButtonVariant.ghost,
                disabled: !_canResend,
              ),
              const SizedBox(height: AppSpacing.md),
              // Check spam note
              Text(
                "Didn't receive it? Check your spam folder.",
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              // Logout option
              GestureDetector(
                onTap: _handleLogout,
                child: Text(
                  'Use a different email',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTypography.body),
      ],
    );
  }
}

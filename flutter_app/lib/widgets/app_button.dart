// Enhanced Button Widget - Premium Design with Gradients & Animations
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum ButtonVariant { primary, secondary, outline, ghost, gradient }
enum ButtonSize { small, medium, large }

class AppButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final bool loading;
  final Widget? icon;
  final bool fullWidth;
  final List<Color>? gradientColors;

  const AppButton({
    super.key,
    required this.title,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.fullWidth = false,
    this.gradientColors,
  });

  // Convenience constructors
  const AppButton.gradient({
    super.key,
    required this.title,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.fullWidth = true,
    this.gradientColors,
  }) : variant = ButtonVariant.gradient;

  const AppButton.outline({
    super.key,
    required this.title,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.loading = false,
    this.icon,
    this.fullWidth = false,
    this.gradientColors,
  }) : variant = ButtonVariant.outline;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppAnimations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: AppAnimations.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        );
      case ButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: 18,
        );
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: 14,
        );
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case ButtonSize.small:
        return 14;
      case ButtonSize.large:
        return 18;
      case ButtonSize.medium:
        return 16;
    }
  }

  double get _borderRadius {
    switch (widget.size) {
      case ButtonSize.small:
        return AppRadius.sm;
      case ButtonSize.large:
        return AppRadius.lg;
      case ButtonSize.medium:
        return AppRadius.md;
    }
  }

  Color get _backgroundColor {
    switch (widget.variant) {
      case ButtonVariant.primary:
        return AppColors.primary;
      case ButtonVariant.secondary:
        return AppColors.secondary;
      case ButtonVariant.outline:
      case ButtonVariant.ghost:
      case ButtonVariant.gradient:
        return Colors.transparent;
    }
  }

  Color get _textColor {
    switch (widget.variant) {
      case ButtonVariant.outline:
        return AppColors.primary;
      case ButtonVariant.ghost:
        return AppColors.textSecondary;
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.gradient:
        return Colors.white;
    }
  }

  List<Color> get _gradientColors {
    return widget.gradientColors ?? AppColors.gradientPrimary;
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.disabled || widget.loading) return;
    setState(() => _isPressed = true);
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.loading;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: Opacity(
          opacity: isDisabled ? 0.5 : 1.0,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: isDisabled ? null : widget.onPressed,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              decoration: BoxDecoration(
                color: widget.variant == ButtonVariant.gradient 
                    ? null 
                    : _backgroundColor,
                gradient: widget.variant == ButtonVariant.gradient
                    ? LinearGradient(
                        colors: _gradientColors,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(_borderRadius),
                border: widget.variant == ButtonVariant.outline
                    ? Border.all(
                        color: _isPressed 
                            ? AppColors.primaryLight 
                            : AppColors.primary,
                        width: 2,
                      )
                    : null,
                boxShadow: widget.variant == ButtonVariant.gradient && !isDisabled
                    ? [
                        BoxShadow(
                          color: _gradientColors.first.withOpacity(_isPressed ? 0.4 : 0.3),
                          blurRadius: _isPressed ? 16 : 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : widget.variant == ButtonVariant.primary && !isDisabled
                        ? AppShadows.primaryGlow(_isPressed ? 0.4 : 0.2)
                        : null,
              ),
              child: Padding(
                padding: _padding,
                child: widget.loading
                    ? _buildLoader()
                    : _buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: SizedBox(
        width: _fontSize + 4,
        height: _fontSize + 4,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_textColor),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          IconTheme(
            data: IconThemeData(color: _textColor, size: _fontSize + 4),
            child: widget.icon!,
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          widget.title,
          style: TextStyle(
            color: _textColor,
            fontSize: _fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// Gradient Outline Button
class GradientOutlineButton extends StatefulWidget {
  final String title;
  final VoidCallback? onPressed;
  final List<Color>? gradientColors;
  final bool fullWidth;
  final Widget? icon;

  const GradientOutlineButton({
    super.key,
    required this.title,
    this.onPressed,
    this.gradientColors,
    this.fullWidth = false,
    this.icon,
  });

  @override
  State<GradientOutlineButton> createState() => _GradientOutlineButtonState();
}

class _GradientOutlineButtonState extends State<GradientOutlineButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradientColors ?? AppColors.gradientPrimary;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPressed?.call();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: AppAnimations.fast,
        child: Container(
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: gradient),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.md - 2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.icon != null) ...[
                  widget.icon!,
                  const SizedBox(width: AppSpacing.sm),
                ],
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: gradient,
                  ).createShader(bounds),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

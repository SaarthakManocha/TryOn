// Custom Input Widget with validation
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AppInput extends StatefulWidget {
  final String? label;
  final String? placeholder;
  final String value;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final String? error;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool multiline;
  final int maxLines;
  final bool enabled;

  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    required this.value,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.error,
    this.prefixIcon,
    this.suffixIcon,
    this.multiline = false,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  State<AppInput> createState() => _AppInputState();
}

class _AppInputState extends State<AppInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(AppInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  Color get _borderColor {
    if (widget.error != null) return AppColors.error;
    if (_isFocused) return AppColors.primary;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Text(
              widget.label!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: AppRadius.mediumRadius,
              border: Border.all(color: _borderColor),
            ),
            child: Opacity(
              opacity: widget.enabled ? 1.0 : 0.6,
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.md),
                      child: widget.prefixIcon,
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      onChanged: widget.onChanged,
                      obscureText: widget.obscureText && _isObscured,
                      keyboardType: widget.keyboardType,
                      textCapitalization: widget.textCapitalization,
                      maxLines: widget.multiline ? widget.maxLines : 1,
                      enabled: widget.enabled,
                      style: AppTypography.body.copyWith(color: AppColors.text),
                      decoration: InputDecoration(
                        hintText: widget.placeholder,
                        hintStyle: AppTypography.body.copyWith(
                          color: AppColors.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: widget.prefixIcon != null
                              ? AppSpacing.sm
                              : AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                    ),
                  ),
                  if (widget.obscureText) ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.md),
                        child: Text(
                          _isObscured ? '👁️' : '🙈',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ] else if (widget.suffixIcon != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.md),
                      child: widget.suffixIcon,
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (widget.error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.error!,
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
        ],
      ),
    );
  }
}

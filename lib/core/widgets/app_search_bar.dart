import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../app/theme/app_colors.dart';
import '../../core/feedback_service.dart';
import '../../core/widgets/voice_search_sheet.dart';

/// Unified aesthetic, premium search bar used across all tabs and screens.
/// Features smooth rounded corners, zero harsh black borders, soft elevation,
/// focus halo glow, circular icon backdrop, and micro-actions.
class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final String? voiceTitle;
  final String? voiceHint;
  final bool autofocus;
  final FocusNode? focusNode;
  final Widget? trailing;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
    this.voiceTitle,
    this.voiceHint,
    this.autofocus = false,
    this.focusNode,
    this.trailing,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _internalFocus = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocus = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocus) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _onClearTapped() {
    AppFeedback.lightImpact();
    widget.controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  void _activateVoiceSearch() {
    AppFeedback.lightImpact();
    VoiceSearchSheet.show(
      context,
      title: widget.voiceTitle ?? 'Voice Search',
      hint: widget.voiceHint ?? 'Say what you are looking for...',
      onResult: (text) {
        widget.controller.text = text;
        widget.onChanged?.call(text);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasQuery = widget.controller.text.isNotEmpty;
    final cardBg = isDark ? const Color(0xFF1E212B) : Colors.white;
    final primaryAccent = AppColors.primary;

    final activeBorderColor = _isFocused
        ? primaryAccent.withValues(alpha: isDark ? 0.75 : 0.55)
        : (hasQuery
            ? primaryAccent.withValues(alpha: 0.35)
            : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06)));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeBorderColor,
          width: _isFocused ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? primaryAccent.withValues(alpha: isDark ? 0.18 : 0.10)
                : (isDark
                    ? Colors.black.withValues(alpha: 0.28)
                    : Colors.black.withValues(alpha: 0.04)),
            blurRadius: _isFocused ? 14 : 10,
            offset: const Offset(0, 3),
            spreadRadius: _isFocused ? 1 : 0,
          ),
          BoxShadow(
            color: isDark
                ? Colors.white.withValues(alpha: 0.02)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Row(
          children: [
            // Aesthetic Search Icon with soft circular backdrop
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _isFocused
                    ? primaryAccent.withValues(alpha: isDark ? 0.20 : 0.12)
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.black.withValues(alpha: 0.04)),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  LucideIcons.search,
                  size: 17,
                  color: _isFocused
                      ? primaryAccent
                      : (isDark ? Colors.white70 : Colors.black54),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Borderless text input with zero harsh lines
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                onChanged: widget.onChanged,
                cursorColor: primaryAccent,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                    fontSize: 14.5,
                    fontWeight: FontWeight.normal,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
            // Suffix Actions: Clear and Voice
            if (hasQuery)
              IconButton(
                tooltip: 'Clear',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: isDark ? Colors.white70 : Colors.black87,
                    size: 14,
                  ),
                ),
                onPressed: _onClearTapped,
              ),
            IconButton(
              tooltip: 'Voice search',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: isDark ? 0.16 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.mic,
                  color: primaryAccent,
                  size: 17,
                ),
              ),
              onPressed: _activateVoiceSearch,
            ),
            if (widget.trailing != null) ...[
              const SizedBox(width: 4),
              widget.trailing!,
            ],
            const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}

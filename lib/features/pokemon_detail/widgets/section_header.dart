import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Color themeColor;

  const SectionHeader({
    super.key,
    required this.title,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Colors.black26, thickness: 1)),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.black12, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              color: themeColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Colors.black26, thickness: 1)),
      ],
    );
  }
}

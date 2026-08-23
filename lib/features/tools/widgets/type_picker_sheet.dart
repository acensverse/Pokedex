import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// Bottom sheet listing all 18 types; pops with the picked type name,
/// an empty string for CLEAR, or null when dismissed.
class TypePickerSheet extends StatelessWidget {
  final String title;
  final void Function(String type)? onSelected;

  const TypePickerSheet({super.key, required this.title, this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 6),
              Container(width: 64, height: 3, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 3.0,
            children: [
              for (final t in AppColors.typeColors.keys)
                Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => Navigator.pop(context, t),
                    child: Container(
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.getTypeColor(t),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${t[0].toUpperCase()}${t.substring(1)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 16),
            child: _ClearButton(onTap: () => Navigator.pop(context, '')),
          ),
        ],
        ),
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ClearButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFDD835), Color(0xFFFF9800)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.close, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'CLEAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 15,
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

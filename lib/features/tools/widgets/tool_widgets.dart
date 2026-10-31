import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/type_icons.dart';

/// Purple champions-mode accent color shared by the tools screens.
const Color championsPurple = Color(0xFF8E24AA);

/// Slim banner shown at the top of the Moves/Abilities/Items screens while
/// Champions mode is active, explaining that the list is scoped to the
/// Champions roster.
class ChampionsModeBanner extends StatelessWidget {
  final String message;

  const ChampionsModeBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: championsPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: championsPurple, width: 1.2),
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, size: 18, color: championsPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: championsPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Type pill in the app's standard style: natural colored SVG type icon on a
/// tinted background with a matching colored label.
class TypePill extends StatelessWidget {
  final String type;
  final double fontSize;

  const TypePill(this.type, {super.key, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.getTypeColor(type);
    final label = type.isEmpty
        ? ''
        : '${type[0].toUpperCase()}${type.substring(1)}';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 1.2,
        vertical: fontSize * 0.55,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(fontSize * 1.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            'assets/types/$type.svg',
            width: fontSize + 5,
            height: fontSize + 5,
          ),
          SizedBox(width: fontSize * 0.5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rounded outline section header, e.g. "Damage taken".
class SectionHeaderPill extends StatelessWidget {
  final String label;

  const SectionHeaderPill(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF26A69A), width: 1.4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF26A69A),
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

/// Big gradient action button with a faint watermark icon on the right.
class GradientToolButton extends StatelessWidget {
  final String label;
  final IconData watermarkIcon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  final double height;
  final bool enabled;

  const GradientToolButton({
    super.key,
    required this.label,
    required this.watermarkIcon,
    required this.colors,
    this.onTap,
    this.leadingIcon,
    this.height = 52,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: colors,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -4,
                  bottom: -height * 0.18,
                  child: Icon(
                    watermarkIcon,
                    size: height * 0.95,
                    color: Colors.white.withValues(alpha: 0.35),
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leadingIcon != null) ...[
                        Icon(leadingIcon, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          fontSize: 15,
                        ),
                      ),
                    ],
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

/// Decorative empty-state illustration: a tall arrow surrounded by type icons.
class ToolsIllustration extends StatelessWidget {
  const ToolsIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final accents = <Offset, (String, double)>{
      const Offset(0.72, 0.02): ('grass', 22),
      const Offset(0.30, 0.08): ('fire', 20),
      const Offset(0.52, 0.10): ('water', 24),
      const Offset(0.74, 0.16): ('electric', 20),
      const Offset(0.80, 0.24): ('steel', 18),
      const Offset(0.24, 0.38): ('psychic', 20),
      const Offset(0.82, 0.36): ('poison', 18),
      const Offset(0.20, 0.52): ('water', 22),
      const Offset(0.30, 0.62): ('fighting', 20),
      const Offset(0.70, 0.58): ('grass', 20),
      const Offset(0.78, 0.68): ('ground', 18),
      const Offset(0.26, 0.74): ('fire', 20),
      const Offset(0.66, 0.78): ('ghost', 18),
    };
    return SizedBox(
      width: 190,
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.arrow_upward,
              size: 170,
              color: Color(0xFF263238),
            ),
          ),
          for (final entry in accents.entries)
            Positioned(
              left: entry.key.dx * 190 - entry.value.$2 / 2,
              top: entry.key.dy * 210 - entry.value.$2 / 2,
              child: Container(
                width: entry.value.$2,
                height: entry.value.$2,
                decoration: BoxDecoration(
                  color: AppColors.getTypeColor(entry.value.$1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  typeIcon(entry.value.$1),
                  color: Colors.white,
                  size: entry.value.$2 * 0.55,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Two-tone donut ring showing male/female split (percentages 0-100).
class GenderDonut extends StatelessWidget {
  final double malePercent;
  final double femalePercent;
  final double size;

  const GenderDonut({
    super.key,
    required this.malePercent,
    required this.femalePercent,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _DonutPainter(malePercent / 100),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final double maleFraction;

  _DonutPainter(this.maleFraction);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(3, 3, size.width - 6, size.height - 6);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = const Color(0xFFF06292);
    canvas.drawCircle(rect.center, rect.shortestSide / 2, paint);
    paint.color = const Color(0xFF42A5F5);
    canvas.drawArc(
      rect,
      -90 * 3.14159 / 180,
      maleFraction * 360 * 3.14159 / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) =>
      oldDelegate.maleFraction != maleFraction;
}

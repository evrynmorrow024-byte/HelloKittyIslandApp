import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';

class KawaiiProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String? label;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;

  const KawaiiProgressBar({
    super.key,
    required this.progress,
    this.label,
    this.backgroundColor,
    this.progressColor,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: SanrioColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final barWidth = (constraints.maxWidth * progress).clamp(0.0, constraints.maxWidth);
            return Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor ?? SanrioColors.pastelBlue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: SanrioColors.lightShadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: height,
                    decoration: BoxDecoration(
                      color: backgroundColor ?? SanrioColors.pastelBlue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(height / 2),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: barWidth,
                    height: height,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          progressColor ?? SanrioColors.brightPink,
                          progressColor?.withValues(alpha: 0.8) ?? SanrioColors.softPink,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: (progressColor ?? SanrioColors.brightPink).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
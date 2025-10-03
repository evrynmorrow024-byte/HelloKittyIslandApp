import 'package:flutter/material.dart';
import 'package:island_trails/theme.dart';

class KawaiiCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? text;

  const KawaiiCheckbox({
    super.key,
    required this.value,
    this.onChanged,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged?.call(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: value ? SanrioColors.checklistCompleted : SanrioColors.checklistDefault,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: SanrioColors.lightShadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: value ? Colors.transparent : SanrioColors.lightText,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: SanrioColors.checklistCompleted,
                    )
                  : null,
            ),
            if (text != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: value ? Colors.white : SanrioColors.darkText,
                    decoration: value ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/checklist_item.dart';

class ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;

  const ChecklistTile({super.key, required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color:
              item.isChecked
                  ? AppColors.statusOpen.withOpacity(0.06)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                item.isChecked
                    ? AppColors.statusOpen.withOpacity(0.6)
                    : AppColors.cardBorder,
            width: item.isChecked ? 1.5 : 1,
          ),
          boxShadow:
              item.isChecked
                  ? [
                    BoxShadow(
                      color: AppColors.statusOpen.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox animado estilo iOS/Premium
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color:
                    item.isChecked ? AppColors.statusOpen : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      item.isChecked
                          ? AppColors.statusOpen
                          : AppColors.textMuted,
                  width: 2,
                ),
              ),
              child:
                  item.isChecked
                      ? const Icon(
                        CupertinoIcons.checkmark_alt,
                        color: Colors.black,
                        size: 16,
                      )
                      : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color:
                          item.isChecked
                              ? AppColors.statusOpen
                              : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight:
                          item.isChecked ? FontWeight.w800 : FontWeight.bold,
                      decoration:
                          item.isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.description,
                    style: TextStyle(
                      color:
                          item.isChecked
                              ? AppColors.textSecondary.withOpacity(0.7)
                              : AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

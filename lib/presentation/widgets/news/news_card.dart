import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/news_item.dart';
import '../../providers/repository_providers.dart';

class NewsCard extends ConsumerWidget {
  final NewsItem item;

  const NewsCard({super.key, required this.item});

  Color _getCategoryColor() {
    switch (item.category) {
      case 'oficial':
        return AppColors.secondary;
      case 'guia':
        return AppColors.primary;
      case 'comunidad':
      default:
        return AppColors.warning;
    }
  }

  String _getCategoryLabel() {
    switch (item.category) {
      case 'oficial':
        return 'FUENTE OFICIAL';
      case 'guia':
        return 'GUÍA EXPLORADOR';
      case 'comunidad':
      default:
        return 'MERCADO / DIVISAS';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catColor = _getCategoryColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.background.withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getCategoryLabel(),
                  style: TextStyle(
                    color: catColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                item.pubDate,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ref.read(newsRepositoryProvider).openArticleUrl(item.link);
                },
                icon: const Icon(
                  CupertinoIcons.compass_fill,
                  size: 16,
                  color: AppColors.primary,
                ),
                label: const Text(
                  'Explorar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/news_provider.dart';
import '../../widgets/news/news_card.dart';
import '../../widgets/news/partner_banner.dart';

class NewsScreen extends ConsumerStatefulWidget {
  const NewsScreen({super.key});

  @override
  ConsumerState<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends ConsumerState<NewsScreen> {
  Future<void> _handleRefresh() async {
    ref.invalidate(newsListProvider);
    await ref.read(newsListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final newsAsync = ref.watch(newsListProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Radar de Noticias',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.0,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.secondary,
        backgroundColor: AppColors.surface,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. Banner Afiliado (15% dto Chapka / IATI)
              const PartnerBanner().animate().fadeIn(duration: 400.ms),

              // 2. Feed de noticias en tiempo real
              newsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                error: (err, _) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: AppColors.statusClosed,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Interferencia en el Radar.\nNo se pudieron cargar los feeds en tiempo real.\n$err',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (allNews) {
                  if (allNews.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Text(
                        'Radar en silencio. No hay noticias nuevas.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    );
                  }

                  return Column(
                    children: allNews.map((item) => NewsCard(item: item)).toList(),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

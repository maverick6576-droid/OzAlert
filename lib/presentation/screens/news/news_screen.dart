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
  Future<void> _handleRefreshOfficial() async {
    ref.invalidate(newsListProvider);
    await ref.read(newsListProvider.future);
  }

  Future<void> _handleRefreshAlerts() async {
    ref.invalidate(alertNewsListProvider);
    await ref.read(alertNewsListProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/app_icon.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Radar de Noticias',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorWeight: 3,
            tabs: [
              Tab(text: 'Fuentes Oficiales'),
              Tab(text: 'Google Alerts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Pestaña 1: Oficiales (Scraper de Inmigración)
            RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              onRefresh: _handleRefreshOfficial,
              child: _buildOfficialFeed(context, ref),
            ),
            
            // Pestaña 2: Google Alerts (Firestore)
            RefreshIndicator(
              color: AppColors.secondary,
              backgroundColor: AppColors.surface,
              onRefresh: _handleRefreshAlerts,
              child: _buildAlertsFeed(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialFeed(BuildContext context, WidgetRef ref) {
    final newsAsync = ref.watch(newsListProvider);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const PartnerBanner().animate().fadeIn(duration: 400.ms),
          newsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.secondary,
                ),
              ),
            ),
            error: (err, _) => _buildErrorState(err.toString()),
            data: (allNews) {
              if (allNews.isEmpty) {
                return _buildEmptyState('Radar oficial en silencio. No hay noticias.');
              }
              return Column(
                children: allNews.map((item) => NewsCard(item: item)).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAlertsFeed(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertNewsListProvider);
    
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.bell_fill, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const Text(
                        'Alertas globales monitorizadas.',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.statusOpen,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).fade(duration: 800.ms, end: 0.2).then().fade(duration: 800.ms, end: 1.0),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(),
          alertsAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
            error: (err, _) => _buildErrorState(err.toString()),
            data: (allNews) {
              if (allNews.isEmpty) {
                return _buildEmptyState('Aún no se han capturado alertas de Google. El servidor está escaneando.');
              }
              return Column(
                children: allNews.map((item) => NewsCard(item: item)).toList(),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildErrorState(String errorText) {
    return Padding(
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
            'Interferencia en el Radar.\nNo se pudieron cargar las noticias.\n$errorText',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted),
      ),
    );
  }
}

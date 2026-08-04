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

class _NewsScreenState extends ConsumerState<NewsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
          'Avisos y Guías de Australia',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 22,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.statusOpen,
          indicatorWeight: 3,
          labelColor: AppColors.statusOpen,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          tabs: const [
            Tab(text: 'Avisos Oficiales'),
            Tab(text: 'Guías y Empleo'),
            Tab(text: 'Comunidad & Divisas'),
          ],
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.statusOpen,
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

              // 2. Feed de noticias según filtro
              newsAsync.when(
                loading:
                    () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.statusOpen,
                        ),
                      ),
                    ),
                error:
                    (err, _) => Padding(
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
                            'No se pudieron cargar los feeds en tiempo real.\n$err',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                data: (allNews) {
                  return AnimatedBuilder(
                    animation: _tabController,
                    builder: (context, _) {
                      final selectedCategory = switch (_tabController.index) {
                        0 => 'oficial',
                        1 => 'guia',
                        2 => 'comunidad',
                        _ => 'oficial',
                      };

                      final filteredNews =
                          allNews
                              .where((n) => n.category == selectedCategory)
                              .toList();

                      if (filteredNews.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 30),
                          child: Text(
                            'No hay noticias en esta sección actualmente.',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        );
                      }

                      return Column(
                        children:
                            filteredNews
                                .map((item) => NewsCard(item: item))
                                .toList(),
                      );
                    },
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

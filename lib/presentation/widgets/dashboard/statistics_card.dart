import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/migration_data.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

class StatisticsCard extends StatefulWidget {
  const StatisticsCard({super.key});

  @override
  State<StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<StatisticsCard> {
  String selectedYear = '2024-2025';

  Future<void> _launchOfficialUrl() async {
    final Uri url = Uri.parse(MigrationData.sourceUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('No se pudo abrir ');
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentData = MigrationData.lodgementsByYear[selectedYear] ?? [];
    final numberFormat = NumberFormat('#,##0', 'en_US');
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        loc.statsOfficialData,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: _launchOfficialUrl,
                tooltip: loc.statsSourceTooltip,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Titulo de Grafico y Leyenda Interactiva
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.statsVolume,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: MigrationData.lodgementsByYear.keys.map((year) {
                  final isSelected = selectedYear == year;
                  final color = year == '2023-2024' ? Colors.orange.shade400 : AppColors.primary;
                  
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedYear = year;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? color : AppColors.cardBorder,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            year,
                            style: TextStyle(
                              color: isSelected ? color : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 28),
          
          // Chart
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100000,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.textPrimary.withOpacity(0.9),
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipMargin: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final val = rod.toY.toInt();
                      return BarTooltipItem(
                        numberFormat.format(val),
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < currentData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              selectedYear.substring(2, 4) + "/" + selectedYear.substring(7, 9) + " " + currentData[value.toInt()]['quarter'],
                              style: const TextStyle(
                                color: AppColors.textSecondary, 
                                fontSize: 10, 
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: currentData.asMap().entries.map((entry) {
                  final barColor = selectedYear == '2023-2024' ? Colors.orange.shade400 : AppColors.primary.withOpacity(0.7);
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: entry.value['lodged'].toDouble(),
                        color: barColor,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 100000,
                          color: AppColors.primary.withOpacity(0.05),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

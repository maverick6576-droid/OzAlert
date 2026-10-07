import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../screens/phase2/settings/phase2_settings_screen.dart';
import 'official_sources_modal.dart';

class Phase2AppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isEn;
  final String? infoTopic;
  final PreferredSizeWidget? bottom;
  final bool showLogo;

  const Phase2AppBar({
    super.key,
    required this.title,
    required this.isEn,
    this.infoTopic,
    this.bottom,
    this.showLogo = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLogo) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(9),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_icon.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        // Botón Información Oficial (i)
        IconButton(
          tooltip: isEn ? 'Official Legal Sources' : 'Fuentes Oficiales y Marco Legal',
          icon: const Icon(CupertinoIcons.info_circle, color: AppColors.textPrimary, size: 22),
          onPressed: () {
            showOfficialSourcesModal(context, isEn: isEn, initialTopic: infoTopic);
          },
        ),
        // Botón Ajustes (⚙️) exactamente como en Fase 1
        IconButton(
          tooltip: isEn ? 'Settings' : 'Ajustes',
          icon: const Icon(CupertinoIcons.gear, color: AppColors.textPrimary, size: 22),
          onPressed: () {
            Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const Phase2SettingsScreen()),
            );
          },
        ),
        const SizedBox(width: 4),
      ],
      bottom: bottom,
    );
  }
}

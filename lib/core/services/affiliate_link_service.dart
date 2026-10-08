import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'url_launcher_service.dart';
import '../../domain/models/phase2/affiliate_partner.dart';

class AffiliateLinkService {
  static Future<void> openPartnerLink(
    BuildContext context,
    AffiliatePartner partner, {
    String? languageCode,
  }) async {
    // 1. Si el partner tiene código promocional, se copia al portapapeles
    if (partner.promoCode != null && partner.promoCode!.trim().isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: partner.promoCode!.trim()));
      if (!context.mounted) return;
      final isEn = languageCode == 'en';
      final message = isEn
          ? 'Promo code "${partner.promoCode}" copied to clipboard!'
          : '¡Código "${partner.promoCode}" copiado al portapapeles!';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (!context.mounted) return;

    // 2. Apertura del enlace segura mediante UrlLauncherService
    if (partner.affiliateUrl.isNotEmpty) {
      await UrlLauncherService.openUrl(context, partner.affiliateUrl);
    }
  }
}

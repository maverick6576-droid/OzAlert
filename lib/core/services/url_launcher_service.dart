import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_colors.dart';

/// Servicio robusto y a prueba de fallos para abrir URLs y enlaces oficiales en toda la app.
/// Implementa reintentos en cascada (navegador externo -> navegador por defecto -> vista in-app)
/// y copia automática al portapapeles con notificación en caso de restricciones del sistema operativo.
class UrlLauncherService {
  /// Abre la URL especificada de forma segura y progresiva.
  static Future<bool> openUrl(
    BuildContext? context,
    String? urlString, {
    LaunchMode preferredMode = LaunchMode.externalApplication,
    String? feedbackTitle,
  }) async {
    if (urlString == null) return false;
    final trimmed = urlString.trim();
    if (trimmed.isEmpty) return false;

    // Normalizar URL asegurando el esquema https
    String normalized = trimmed;
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      if (normalized.startsWith('www.')) {
        normalized = 'https://$normalized';
      } else if (!normalized.contains('://')) {
        normalized = 'https://$normalized';
      }
    }

    final uri = Uri.tryParse(normalized);
    if (uri == null) {
      debugPrint('[UrlLauncherService] ⚠️ URL con formato inválido: $normalized');
      if (context != null) {
        _showFeedback(context, 'Enlace no válido: $normalized', isWarning: true);
      }
      return false;
    }

    bool launched = false;

    // Intento 1: Modo preferido (externalApplication - navegador real del dispositivo)
    try {
      launched = await launchUrl(uri, mode: preferredMode);
      if (launched) {
        debugPrint('[UrlLauncherService] ✅ Enlace abierto con $preferredMode: $normalized');
        return true;
      }
    } catch (e) {
      debugPrint('[UrlLauncherService] ⚠️ Falló apertura con $preferredMode: $e');
    }

    // Intento 2: Fallback a platformDefault (Custom Tabs en Android / Safari Controller)
    if (!launched && preferredMode != LaunchMode.platformDefault) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) {
          debugPrint('[UrlLauncherService] ✅ Enlace abierto con platformDefault: $normalized');
          return true;
        }
      } catch (e) {
        debugPrint('[UrlLauncherService] ⚠️ Falló apertura con platformDefault: $e');
      }
    }

    // Intento 3: Fallback a inAppBrowserView
    if (!launched && preferredMode != LaunchMode.inAppBrowserView) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
        if (launched) {
          debugPrint('[UrlLauncherService] ✅ Enlace abierto con inAppBrowserView: $normalized');
          return true;
        }
      } catch (e) {
        debugPrint('[UrlLauncherService] ⚠️ Falló apertura con inAppBrowserView: $e');
      }
    }

    // Si fallaron todos los métodos del sistema operativo, copiamos al portapapeles para no dejar al usuario sin acceso
    try {
      await Clipboard.setData(ClipboardData(text: normalized));
    } catch (e) {
      debugPrint('[UrlLauncherService] Error al copiar al portapapeles: $e');
    }

    if (context != null && context.mounted) {
      _showFeedback(
        context,
        'No se pudo abrir el navegador. Enlace copiado al portapapeles: $normalized',
        isWarning: true,
      );
    }

    return false;
  }

  static void _showFeedback(BuildContext context, String message, {bool isWarning = false}) {
    if (!context.mounted) return;
    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isWarning ? AppColors.warning : AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              Icon(
                isWarning ? Icons.info_outline : Icons.check_circle_outline,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 12.5),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (_) {
      // Ignorar si el scaffold no está disponible
    }
  }
}

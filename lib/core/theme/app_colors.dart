import 'package:flutter/material.dart';

class AppColors {
  // Fondos y superficies Dark Sapphire (Estética espacial / radar premium)
  static const Color background = Color(0xFF0A0F1D);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceElevated = Color(0xFF1C2742);
  static const Color cardBorder = Color(0xFF2E3D5E);

  // Colores de estado de Visa e Indicadores
  static const Color statusOpen = Color(0xFF00F59B); // Neón Esmeralda (¡ABIERTA!)
  static const Color statusPaused = Color(0xFF3366FF); // Azul (PAUSADA)
  static const Color statusClosed = Color(0xFFFF3366); // Rubí Intenso (CERRADA)
  static const Color warning = Color(0xFFFFB800); // Ámbar
  static const Color primary = Color(0xFF3B82F6); // Azul zafiro activo
  static const Color primaryGlow = Color(0x403B82F6);

  // Tipografía
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Degradados de Tarjetas
  static const LinearGradient openCardGradient = LinearGradient(
    colors: [Color(0xFF063D2B), Color(0xFF001F15)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient closedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2A1B1F),
      Color(0xFF1F1518),
    ],
  );

  static const LinearGradient pausedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1B2433),
      Color(0xFF151A24),
    ],
  );

  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

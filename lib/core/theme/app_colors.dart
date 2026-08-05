import 'package:flutter/material.dart';

class AppColors {
  // Fondos y superficies Light Explorer (Estética Outback & Coast - Modo Claro)
  static const Color background = Color(0xFFFBF8F3); // Blanco Crema / Arena Suave
  static const Color surface = Color(0xFFFFFFFF); // Blanco Puro para las tarjetas
  static const Color surfaceElevated = Color(0xFFF4F1EA); // Arena ligeramente más oscura
  static const Color cardBorder = Color(0xFFE2DCD0); // Borde suave arena

  // Colores de estado de Visa e Indicadores
  static const Color statusOpen = Color(0xFF00A896); // Azul Turquesa Océano (¡ABIERTA!)
  static const Color statusPaused = Color(0xFFF4A261); // Amarillo Señalización Australiana (PAUSADA)
  static const Color statusClosed = Color(0xFFD96B43); // Naranja Terracota (CERRADA)
  static const Color warning = Color(0xFFF4A261); // Ámbar
  
  static const Color primary = Color(0xFFD96B43); // Naranja Terracota
  static const Color primaryGlow = Color(0x40D96B43);
  static const Color secondary = Color(0xFF00A896); // Azul Turquesa Océano

  // Tipografía (Invertida para Modo Claro)
  static const Color textPrimary = Color(0xFF1E293B); // Gris Pizarra Oscuro / Casi Negro
  static const Color textSecondary = Color(0xFF475569); // Gris Medio
  static const Color textMuted = Color(0xFF94A3B8); // Gris Claro

  // Degradados de Tarjetas
  static const LinearGradient openCardGradient = LinearGradient(
    colors: [Color(0xFF00A896), Color(0xFF008F7F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient closedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD96B43),
      Color(0xFFC25B36),
    ],
  );

  static const LinearGradient pausedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4A261),
      Color(0xFFE09153),
    ],
  );

  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFFD96B43), Color(0xFF00A896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

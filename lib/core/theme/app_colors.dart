import 'package:flutter/material.dart';

class AppColors {
  // Fondos y superficies Dark Explorer (Estética Outback & Coast)
  static const Color background = Color(0xFF121B28); // Azul Noche Profundo
  static const Color surface = Color(0xFF1C2738);
  static const Color surfaceElevated = Color(0xFF26344A);
  static const Color cardBorder = Color(0xFF384B66);

  // Colores de estado de Visa e Indicadores
  static const Color statusOpen = Color(0xFF00A896); // Azul Turquesa Océano (¡ABIERTA!)
  static const Color statusPaused = Color(0xFFF4A261); // Amarillo Señalización Australiana (PAUSADA)
  static const Color statusClosed = Color(0xFFD96B43); // Naranja Terracota (CERRADA)
  static const Color warning = Color(0xFFF4A261); // Ámbar
  
  static const Color primary = Color(0xFFD96B43); // Naranja Terracota
  static const Color primaryGlow = Color(0x40D96B43);
  static const Color secondary = Color(0xFF00A896); // Azul Turquesa Océano

  // Tipografía
  static const Color textPrimary = Color(0xFFFBF8F3); // Blanco Crema / Arena Suave
  static const Color textSecondary = Color(0xFFB0B9C6);
  static const Color textMuted = Color(0xFF7A899E);

  // Degradados de Tarjetas
  static const LinearGradient openCardGradient = LinearGradient(
    colors: [Color(0xFF00A896), Color(0xFF007A6D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient closedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD96B43),
      Color(0xFFA64A2B),
    ],
  );

  static const LinearGradient pausedCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF4A261),
      Color(0xFFCC854B),
    ],
  );

  static const LinearGradient vipGradient = LinearGradient(
    colors: [Color(0xFFD96B43), Color(0xFF00A896)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

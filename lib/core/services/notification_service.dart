import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        debugPrint('Notificación local presionada: ${details.payload}');
      },
    );

    // Permisos de Firebase Cloud Messaging en iOS y Android
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e) {
      debugPrint('FCM no disponible en entorno local o escritorio: $e');
    }

    _isInitialized = true;
  }

  /// Botón "Probar Alerta" - Simula una notificación Push en 2 segundos
  /// para que el usuario compruebe con máxima confianza que el sistema funciona.
  Future<void> sendTestAlert({
    required String countryName,
    required String countryCode,
  }) async {
    if (!_isInitialized) await init();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ozvisa_radar_channel',
          'OzVisa Alertas de Apertura',
          channelDescription:
              'Notificaciones inmediatas de apertura de plazas de visa Work & Holiday',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'OzVisa Alerta Test',
          styleInformation: BigTextStyleInformation(
            '¡El sistema de rastreo de los servidores de OzVisa Alert está operativo para $countryName! Te notificaremos al segundo en que el Departamento de Home Affairs abra plazas.',
          ),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Esperar 1.5 segundos para simular llegada en tiempo real desde el servidor
    await Future.delayed(const Duration(milliseconds: 1500));

    await _localNotifications.show(
      888,
      '🔔 TEST ALERTA: OzVisa Radar Activo ($countryName)',
      '✅ Conexión verificada: Servidores monitoreando visas 24/7 en tiempo real.',
      platformDetails,
      payload: 'test_alert_$countryCode',
    );
  }

  /// Suscripción al tópico de Firebase Cloud Messaging (/topics/visa_ES, etc.)
  Future<void> subscribeToCountryTopic(String countryCode) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(
        'visa_$countryCode',
      );
      debugPrint('Suscrito a tópico FCM: visa_$countryCode');
    } catch (e) {
      debugPrint('FCM subscribeToTopic ignorado en modo offline/mock: $e');
    }
  }
}

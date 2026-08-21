import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

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
      
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        String? apnsToken = await messaging.getAPNSToken();
        int retries = 0;
        while (apnsToken == null && retries < 10) {
          debugPrint('Esperando APNs Token... intento $retries');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await messaging.getAPNSToken();
          retries++;
        }
        debugPrint('APNs Token final: $apnsToken');
      }

      final token = await messaging.getToken();
      debugPrint('🔑 FCM Token: $token');
      // Suscribirse a las noticias globales de Google Alerts
      await messaging.subscribeToTopic('all_users');
      debugPrint('Suscrito a tópico FCM: all_users');

      // Escuchar notificaciones cuando la app está en PRIMER PLANO (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground: ${message.messageId}');
        if (message.notification != null) {
          _showLocalNotification(
            title: message.notification!.title ?? 'OzAlert',
            body: message.notification!.body ?? '',
          );
        }
      });
    } catch (e) {
      debugPrint('FCM no disponible en entorno local o escritorio: $e');
    }

    _isInitialized = true;
  }

  /// Botón "Probar Alerta" - Simula una notificación Push en 2 segundos
  /// para que el usuario compruebe con máxima confianza que el sistema funciona.
  Future<void> sendTestAlert({
    required String countryCode,
    required String title,
    required String body,
    required String longBody,
    required String channelName,
    required String channelDescription,
    required String ticker,
  }) async {
    if (!_isInitialized) await init();

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'ozvisa_radar_channel',
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: ticker,
          styleInformation: BigTextStyleInformation(
            longBody,
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
      title,
      body,
      platformDetails,
      payload: 'test_alert_$countryCode',
    );
  }

  /// Muestra una notificación local desde un Push en primer plano
  Future<void> _showLocalNotification({required String title, required String body}) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ozvisa_radar_channel',
      'Alertas de Apertura',
      importance: Importance.max,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(body),
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

    await _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
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
  /// Sincroniza las suscripciones: se suscribe a los códigos activos y se desuscribe del resto
  Future<void> syncPassportSubscriptions(List<String> activeCountryCodes) async {
    if (!_isInitialized) await init();
    try {
      // Suscribirse a los seleccionados
      for (var code in activeCountryCodes) {
        await FirebaseMessaging.instance.subscribeToTopic('visa_$code');
        debugPrint('Sincronizado: Suscrito a visa_$code');
      }
      
      // Desuscribirse de los no seleccionados
      for (var country in AppConstants.supportedCountries) {
        if (!activeCountryCodes.contains(country.code)) {
          await FirebaseMessaging.instance.unsubscribeFromTopic('visa_${country.code}');
          debugPrint('Sincronizado: Desuscrito de visa_${country.code}');
        }
      }
    } catch (e) {
      debugPrint('Error sincronizando tópicos: $e');
    }
  }
}

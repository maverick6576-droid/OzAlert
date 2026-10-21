import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

      // PRE-CREAR el canal en Android para que FCM en segundo plano tenga el sonido correcto
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          try {
            const channel = AndroidNotificationChannel(
              'ozvisa_radar_channel_siren_v6',
              'Alertas de Apertura (Sirena)',
              description: 'Canal de emergencia para apertura de visas',
              importance: Importance.max,
              playSound: true,
              sound: RawResourceAndroidNotificationSound('siren'),
            );
            await androidPlugin.createNotificationChannel(channel);
            debugPrint('Canal de sirena v6 pre-creado en Android');
          } catch (e) {
            debugPrint('Error creando el canal v6 en Android: $e');
          }
        }
      }
      
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
      // Suscribirse a las noticias globales (si no están desactivadas)
      final prefs = await SharedPreferences.getInstance();
      final newsEnabled = prefs.getBool('news_notifications_enabled') ?? true;
      _isPremiumActive = prefs.getBool('is_premium_active') ?? false;
      if (newsEnabled) {
        await messaging.subscribeToTopic('all_users');
        debugPrint('Suscrito a tópico FCM: all_users');
      }

      // Escuchar notificaciones cuando la app está en PRIMER PLANO (Foreground)
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('FCM Foreground: ${message.messageId}');
        if (message.notification != null) {
          final isVisaAlert = message.from != null && message.from!.contains('visa_');
          if (isVisaAlert && !_isPremiumActive) {
            debugPrint('Alerta de visado ignorada en primer plano: usuario no es Premium');
            return;
          }
          _showLocalNotification(
            title: message.notification!.title ?? 'OzAlert',
            body: message.notification!.body ?? '',
            useSiren: isVisaAlert,
          );
        }
      });
    } catch (e) {
      debugPrint('FCM no disponible en entorno local o escritorio: $e');
    }

    _isInitialized = true;
  }

  bool _isPremiumActive = false;

  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremiumActive = isPremium;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_active', isPremium);
    } catch (_) {}
  }

  /// Botón "Probar Alerta" - Simula una notificación Push
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
          'ozvisa_radar_channel_siren_v6', 
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          ticker: ticker,
          sound: const RawResourceAndroidNotificationSound('siren'),
          playSound: true,
          styleInformation: BigTextStyleInformation(longBody),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'siren.wav',
    );

    final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

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
  Future<void> _showLocalNotification({
    required String title, 
    required String body,
    bool useSiren = false,
  }) async {
    final AndroidNotificationDetails androidDetails = useSiren
        ? const AndroidNotificationDetails(
            'ozvisa_radar_channel_siren_v6',
            'Alertas de Apertura (Sirena)',
            importance: Importance.max,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('siren'),
            playSound: true,
            styleInformation: BigTextStyleInformation(''),
          )
        : const AndroidNotificationDetails(
            'ozvisa_news_channel',
            'Noticias y Actualizaciones',
            importance: Importance.high,
            priority: Priority.defaultPriority,
            playSound: true,
            styleInformation: BigTextStyleInformation(''),
          );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: useSiren ? 'siren.wav' : null,
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
    if (!_isPremiumActive) return;
    try {
      await FirebaseMessaging.instance.subscribeToTopic(
        'visa_$countryCode',
      );
      debugPrint('Suscrito a tópico FCM: visa_$countryCode');
    } catch (e) {
      debugPrint('FCM subscribeToTopic ignorado en modo offline/mock: $e');
    }
  }

  /// Sincroniza las suscripciones: se suscribe a los códigos activos y se desuscribe del resto en paralelo
  Future<void> syncPassportSubscriptions(List<String> activeCountryCodes) async {
    if (!_isInitialized) await init();
    try {
      final futures = <Future<void>>[];

      // Suscribirse a los seleccionados (únicamente si hay códigos activos para usuario Premium en Fase 1)
      for (final code in activeCountryCodes) {
        futures.add(
          FirebaseMessaging.instance.subscribeToTopic('visa_$code').then((_) {
            debugPrint('Sincronizado: Suscrito a visa_$code');
          }).catchError((e) {
            debugPrint('Error suscribiendo a visa_$code: $e');
          }),
        );
      }

      // Desuscribirse de los no seleccionados (o de todos cuando deja de pagar / cambia a Fase 2)
      for (final country in AppConstants.supportedCountries) {
        if (!activeCountryCodes.contains(country.code)) {
          futures.add(
            FirebaseMessaging.instance.unsubscribeFromTopic('visa_${country.code}').then((_) {
              debugPrint('Sincronizado: Desuscrito de visa_${country.code}');
            }).catchError((e) {
              debugPrint('Error desuscribiendo de visa_${country.code}: $e');
            }),
          );
        }
      }

      await Future.wait(futures);
    } catch (e) {
      debugPrint('Error sincronizando tópicos: $e');
    }
  }

  /// Sincroniza la suscripción al canal de noticias según la fase del usuario:
  /// - Fase 1: Se suscribe a 'all_users' (si news_notifications_enabled está activo).
  /// - Fase 2: Se desuscribe de 'all_users' para no recibir avisos de noticias de la Fase 1.
  Future<void> syncPhaseNewsSubscription(int currentPhase) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final newsEnabled = prefs.getBool('news_notifications_enabled') ?? true;

      if (currentPhase == 1) {
        if (newsEnabled) {
          await FirebaseMessaging.instance.subscribeToTopic('all_users');
          debugPrint('FCM: Suscrito al canal de noticias de Fase 1 (all_users)');
        }
      } else {
        // En Fase 2 desuscribirse del canal de noticias de la Fase 1
        await FirebaseMessaging.instance.unsubscribeFromTopic('all_users');
        debugPrint('FCM: Desuscrito del canal de noticias de Fase 1 (all_users) - Fase actual: $currentPhase');
      }
    } catch (e) {
      debugPrint('Error sincronizando suscripción de noticias de fase: $e');
    }
  }

  /// Programa o emite recordatorio del 12% de Payday Super (7 días hábiles)
  Future<void> schedulePaydaySuperReminder({
    required String employerName,
    required double superAmountAud,
    required DateTime deadlineDate,
  }) async {
    final title = '🔔 Payday Super (12%): $employerName';
    final body =
        'Vencimiento legal (${deadlineDate.day}/${deadlineDate.month}): Comprueba en tu app de Super (Hostplus/AustralianSuper) el ingreso de \$${superAmountAud.toStringAsFixed(2)} AUD.';
    await _showLocalNotification(title: title, body: body);
  }
}


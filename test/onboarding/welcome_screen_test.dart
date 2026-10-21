import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ozvisa_alert/presentation/screens/onboarding/welcome_screen.dart';
import 'package:ozvisa_alert/presentation/providers/locale_provider.dart';
import 'package:ozvisa_alert/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Widget createWelcomeTestWidget({Locale initialLocale = const Locale('es')}) {
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final locale = ref.watch(localeProvider) ?? initialLocale;
          return MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }

  group('WelcomeScreen Tests', () {
    testWidgets('Renders all 5 feature pillars and primary button without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWelcomeTestWidget(initialLocale: const Locale('es')));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      // Verificamos elementos clave
      expect(find.text('OzAlert'), findsOneWidget);
      expect(find.text('Empezar mi Aventura'), findsOneWidget);

      // Verificamos presencia de los pilares de valor
      expect(find.text('Alertas de Visas al Instante'), findsOneWidget);
      expect(find.text('Aterrizaje & Primeros Días'), findsOneWidget);
      expect(find.text('CV Australiano & Ley Fair Work'), findsOneWidget);
      expect(find.text('Días Regionales & Form 1263'), findsOneWidget);
      expect(find.text('Tax Return, Medicare 2% & DASP'), findsOneWidget);
    });

    testWidgets('Renders properly on small screen height without any RenderFlex overflow', (tester) async {
      // Pantalla compacta (e.g., iPhone SE o Android compacto: 360 x 580)
      await tester.binding.setSurfaceSize(const Size(360, 580));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWelcomeTestWidget(initialLocale: const Locale('es')));
      await tester.pumpAndSettle();

      // No debe existir ningún tipo de desbordamiento ni excepción
      expect(tester.takeException(), isNull);

      // El botón de acción está fijado abajo y siempre es visible y clickeable
      final buttonFinder = find.text('Empezar mi Aventura');
      expect(buttonFinder, findsOneWidget);
    });

    testWidgets('Toggles language across all 5 languages seamlessly (ES, EN, FR, IT, ZH)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWelcomeTestWidget(initialLocale: const Locale('es')));
      await tester.pumpAndSettle();

      // 1. English
      await tester.tap(find.text('EN'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Start My Journey'), findsOneWidget);
      expect(find.text('Instant Visa Opening Alerts'), findsOneWidget);

      // 2. French
      await tester.tap(find.text('FR'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Commencer Mon Aventure'), findsOneWidget);
      expect(find.text('Alertes d’Ouverture de Visa'), findsOneWidget);

      // 3. Italian
      await tester.tap(find.text('IT'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Inizia la Mia Avventura'), findsOneWidget);
      expect(find.text('Avvisi Apertura Visto'), findsOneWidget);

      // 4. Chinese
      await tester.tap(find.text('ZH'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('开启我的澳洲之旅'), findsOneWidget);
      expect(find.text('即时签证开放提醒'), findsOneWidget);

      // 5. Back to Spanish
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Empezar mi Aventura'), findsOneWidget);
      expect(find.text('Alertas de Visas al Instante'), findsOneWidget);
    });

    testWidgets('Renders all languages on compact screen (360x580) with zero RenderFlex overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 580));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final testLocales = [
        const Locale('es'),
        const Locale('en'),
        const Locale('fr'),
        const Locale('it'),
        const Locale('zh'),
      ];

      for (final loc in testLocales) {
        await tester.pumpWidget(createWelcomeTestWidget(initialLocale: loc));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Failed with overflow for locale: ${loc.languageCode}');
      }
    });
  });
}

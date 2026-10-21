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

    testWidgets('Toggles language between ES and EN seamlessly', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createWelcomeTestWidget(initialLocale: const Locale('es')));
      await tester.pumpAndSettle();

      // Cambiamos a inglés tocando 'EN'
      final enButton = find.text('EN');
      expect(enButton, findsOneWidget);
      await tester.tap(enButton);
      await tester.pumpAndSettle();

      // Verificamos que los textos cambian al inglés
      expect(find.text('Start My Journey'), findsOneWidget);
      expect(find.text('Instant Visa Opening Alerts'), findsOneWidget);
      expect(find.text('Arrival & First Days Roadmap'), findsOneWidget);
    });
  });
}

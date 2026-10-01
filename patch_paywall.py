import codecs
import re

with codecs.open('lib/presentation/providers/paywall_provider.dart', 'r', 'utf-8') as f:
    text = f.read()

new_block = '''  Future<void> checkSubscriptionStatus() async {
    final user = ref.read(authStateProvider).value;
    
    // 1. VIP Override: Si es el administrador, dejarle pasar siempre gratis.
    if (user != null && user.email == 'maverick6576+Ozspain@gmail.com') {
      await _updateFirebasePremiumStatus(true);
      state = true;
      return;
    }

    // 2. Flujo normal para el resto del mundo
    final repo = ref.read(paywallRepositoryProvider);
    final active = await repo.isUserSubscribed();
    
    // 3. ACTUALIZAR FIREBASE EN AMBOS CASOS (Activo o Cancelado)
    await _updateFirebasePremiumStatus(active);
    
    state = active;
  }'''

text = re.sub(r'  Future<void> checkSubscriptionStatus\(\) async \{.*?\n  \}', new_block, text, flags=re.DOTALL)

with codecs.open('lib/presentation/providers/paywall_provider.dart', 'w', 'utf-8') as f:
    f.write(text)
print("Reemplazo con regex exitoso")

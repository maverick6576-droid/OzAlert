# 📘 Guía Completa de Conexión y Despliegue de OzVisa Alert (Coste $0)

Esta guía paso a paso proporciona las instrucciones técnicas completas para conectar el proyecto **OzVisa Alert** a Firebase (Firestore + Cloud Messaging), integrar la plataforma de pago **RevenueCat**, desplegar el backend en **Google Cloud Functions** (con optimización de cuota gratuita 0 escrituras) y gestionar la recarga de noticias.

---

## 🔹 Paso 1: Conectar Firebase y Firestore (Coste $0 en la capa Spark)

OzVisa Alert está configurado para aprovechar la capa gratuita (Spark Plan) de Firebase, con un límite diario gratuito de **50.000 lecturas** y **20.000 escrituras**.

### 1.1 Configurar el Proyecto en la Consola de Firebase
1. Accede a [console.firebase.google.com](https://console.firebase.google.com/) y haz clic en **Añadir Proyecto** (nombre sugerido: `ozvisa-alert-prod`).
2. Desactiva o activa Google Analytics según tus preferencias y crea el proyecto.
3. Añade una **Aplicación Android** en Firebase:
   - Nombre del paquete: `com.ozvisa.alert`
   - Descarga el archivo **`google-services.json`** y guárdalo en la carpeta:
     ```
     android/app/google-services.json
     ```
4. Añade una **Aplicación iOS** en Firebase (opcional si publicas en Apple):
   - ID de paquete: `com.ozvisa.alert`
   - Descarga el archivo **`GoogleService-Info.plist`** y colócalo en el raíz del directorio `ios/Runner/`.

### 1.2 Configurar la Base de Datos Firestore
1. En el menú de la izquierda, entra en **Firestore Database** -> **Crear base de datos** (elige ubicación `australia-southeast1` o `us-central1`).
2. En la pestaña **Reglas**, sustituye las reglas por defecto por las siguientes reglas optimizadas y pégalas en Firebase:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       // Colección /visas: Lectura pública para la app (bajo costo), escritura solo para el backend de Cloud Functions
       match /visas/{countryCode} {
         allow read: if true;
         allow write: if false; // Solo se escribe a través de Admin SDK (Cloud Function Python)
       }

       // Colección /users: Solo el propio usuario autenticado puede leer/guardar sus preferencias de alerta
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }

       // Colección /news: Lectura libre
       match /news/{newsId} {
         allow read: if true;
         allow write: if false;
       }
     }
   }
   ```
3. Crea la colección inicial `visas` y añade el primer documento `ES` (España) con la siguiente estructura de prueba:
   ```json
   {
     "countryCode": "ES",
     "countryName": "España",
     "status": "CLOSED",
     "subclass": "462",
     "updatedAt": "2026-08-04T10:00:00Z"
   }
   ```

---

## 🔹 Paso 2: Conectar la Plataforma de Pago (RevenueCat SDK)

El proyecto utiliza **RevenueCat (`purchases_flutter`)** para ofrecer el **Plan Mensual ($1.99/mes)** y el **Pase de Temporada ($14.99/año)**, manejando cobros, devoluciones y restauraciones en un solo clic.

### 2.1 Configuración del Entitlement y Productos en RevenueCat
1. Crea una cuenta gratuita en [revenuecat.com](https://www.revenuecat.com/) y añade un proyecto llamado `OzVisa Alert`.
2. En el panel de RevenueCat, ve a **Entitlements (Derechos)** y crea un derecho principal con la clave exacta:
   ```
   ozvisa_pro_access
   ```
3. En **Offerings (Ofertas)**, crea el Offering predeterminado (`default`) y enlaza dos paquetes:
   - `monthly`: ID de producto de tienda `ozvisa_monthly_199` ($1.99 / mes).
   - `annual`: ID de producto de tienda `ozvisa_annual_1499` ($14.99 / año - Pase de Temporada).
4. Asocia ambos paquetes al Entitlement `ozvisa_pro_access`.

### 2.2 Reemplazar la Clave Pública de RevenueCat en el Código Flutter
Abre el archivo `lib/main.dart` de la aplicación y sustituye `'MOCK_REVENUECAT_API_KEY'` por tu Clave Pública de RevenueCat (`appl_xxxxxxx` o `goog_xxxxxxx`):

```dart
// En lib/main.dart
final paywallRepo = PaywallRepositoryImpl();
await paywallRepo.initRevenueCat('TU_PUBLIC_SDK_KEY_AQUI');
```
*Nota: Mientras uses `'MOCK_REVENUECAT_API_KEY'` en desarrollo, la app funcionará en modo Simulación Inteligente sin requerir compras reales.*

---

## 🔹 Paso 3: Desplegar y Ejecutar el Backend en Google Cloud Functions ($0 Coste)

La arquitectura de servidor se ejecuta con un micro-servicio en Python (`functions/main.py`) que audita el portal oficial de Australia. Para **garantizar un coste mensual de $0**, el script compara en cada ejecución el estado detectado con el anterior de Firestore: **Si no hay cambio en la disponibilidad de plazas, el script termina sin hacer ninguna escritura en Firestore (0 writes).**

### 3.1 Instalar Google Cloud CLI y Autenticar
1. Instala la herramienta de línea de comandos de Google Cloud CLI (`gcloud`).
2. En tu terminal, selecciona el ID de proyecto de Firebase:
   ```bash
   gcloud auth login
   gcloud config set project ozvisa-alert-prod
   ```

### 3.2 Desplegar la Cloud Function (Python 3.11)
Abre una terminal dentro del subdirectorio `functions/` del proyecto y lanza el comando de despliegue:

```bash
cd functions

gcloud functions deploy check_visa_status \
  --runtime=python311 \
  --region=us-central1 \
  --source=. \
  --entry-point=check_visa_status \
  --trigger-http \
  --allow-unauthenticated \
  --memory=256MB \
  --set-env-vars RESEND_API_KEY="tu_clave_de_resend_opcional"
```

### 3.3 Configurar Cloud Scheduler (Frecuencia: cada 2 minutos)
Para que el radar consulte de forma autónoma cada 120 segundos sin requerir servidores EC2/VPS de pago:
1. En la consola de Google Cloud, entra en **Cloud Scheduler** -> **Crear trabajo**.
2. Nombre: `ozvisa-radar-job`
3. Frecuencia (formato cron):
   ```cron
   */2 * * * *
   ```
4. Destino: URL HTTP -> Pega la URL que arrojó el comando `gcloud functions deploy`.
5. Método HTTP: `GET`.

### 3.4 Cómo Probar y Simular una Apertura de Visas desde tu Terminal
Para testear cómo se disparan las alertas Push (FCM) y Emails de forma local o en producción, ejecuta en tu terminal:
```bash
cd functions
python main.py --test-country ES --simulate-open
```
Esto simulará que Australia ha abierto cuotas para España (`ES`) y verás por consola cómo se genera la notificación sin consumir saldo.

---

## 🔹 Paso 4: Recargar Noticias, Guías Prácticas y Alertas de Comunidad

OzVisa Alert ha sido construido para que la **Pantalla 3 (Avisos Oficiales y Guías)** no consuma recursos de tu servidor backend.

### 4.1 Funcionamiento del Cliente RSS Naitvo
- La app usa el paquete Flutter `webfeed_plus` en `lib/data/repositories/news_repository_impl.dart`.
- Consulta directamente el RSS de novedades del Ministerio del Interior de Australia (`immi.homeaffairs.gov.au/rss`) y páginas oficiales comunitarias.
- Aplica filtrado automático por pestañas:
  1. **Avisos Oficiales**: Feeds migratorios etiquetados como oficiales.
  2. **Guías y Empleo**: Guías offline integradas (apertura de cuenta en Commonwealth Bank, solicitud del TFN, consejos de trabajo en granjas).
  3. **Comunidad & Divisas**: Variación del dólar australiano ($AUD/EUR) y promociones aéreas.

### 4.2 Cómo Recargar Manualmente en la App
- El usuario puede deslizar hacia abajo (**Pull-to-Refresh**) en cualquier momento dentro de la Pantalla 3 para obligar a la app a sincronizar los feeds en tiempo real.
- Si la conexión falla, la app muestra un fallback con las guías locales imprescindibles para el usuario, asegurando que **nunca haya una pantalla vacía**.

---

## 🎯 Resumen de Verificación Rápida
- [x] Tarjeta de Estado Verde/Roja y Live Radar conectados en `lib/presentation/widgets/dashboard/`.
- [x] Checklist de Requisitos persistente en `lib/presentation/screens/checklist/`.
- [x] Backend Python con **0 escrituras en reposo** implementado en `functions/main.py`.
- [x] Soporte de simulación local activo (100% de la UI testeable sin credenciales externas de pago).

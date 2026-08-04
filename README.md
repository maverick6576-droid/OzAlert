# OzVisa Alert — Monitor Global en Tiempo Real de Visas Australia MVP (3 Pantallas)

**OzVisa Alert** es una aplicación móvil de producción en Flutter (Dart) de arquitectura limpia y un backend optimizado para **coste $0 de infraestructura** utilizando Google Cloud Function, Firebase y RevenueCat. Está diseñada para rastrear de forma automatizada las 24 horas del día la disponibilidad de plazas para visas **Work and Holiday (Subclase 417 y 462)** del Gobierno de Australia.

---

## 🏗️ Arquitectura del Sistema

- **Frontend**: Flutter (Dart) con **Clean Architecture** y **Riverpod** para la gestión reactiva del estado.
- **Backend ($0 Coste)**: Python 3.11 en **Google Cloud Function** invocado por **Google Cloud Scheduler** cada 2 minutos.
- **Base de Datos**: Firebase Firestore optimizado con **0 escrituras** si el estado de la visa no ha cambiado en la web oficial.
- **Suscripciones VIP**: RevenueCat SDK (`purchases_flutter`) soportando plan mensual (**$1.99/mes**) y Pase de Temporada anual (**$14.99/año**).
- **Notificaciones**: Firebase Cloud Messaging (FCM Topic `/topics/visa_code`) + Alertas por Email vía Resend / SendGrid.
- **Feeds RSS**: Cliente nativo (`http` + `webfeed_plus`) para consulta directa desde el móvil sin servidores propios.

---

## 📱 Las 3 Pantallas Principales

1. **Pantalla 1: Dashboard Principal (`/dashboard` - Tab 1)**
   - **Live Radar**: Punto verde parpadeante *"Servidores rastreando la web oficial de Inmigración de Australia"* + Contador dinámico 60s.
   - **Estado de Visa (Tarjeta Rojo/Verde)**: Muestra en grande `CERRADA ("0 plazas disponibles actualmente")` o `¡ABIERTA! ("Visas disponibles - Aplicar ahora")` para el pasaporte seleccionado (España, Argentina, Chile, Uruguay, Perú, etc.).
   - **Botón Probar Alerta**: Envía en 2 segundos una Notificación Push local de prueba y un mensaje en app para generar máxima confianza.
   - **Paywall VIP RevenueCat**: Modal accesible desde el cabezal con políticas claras en 1 clic y botón de *Restaurar Compras*.

2. **Pantalla 2: Checklist de Requisitos (`/checklist` - Tab 2)**
   - Lista interactiva que aporta valor mientras el usuario espera a que abra la visa, con barra de progreso de 0% a 100%:
     - `[x]` Pasaporte con más de 6 meses de validez
     - `[x]` Examen de inglés aprobado (IELTS / PTE)
     - `[ ]` Fondos bancarios acreditados ($5.000 AUD)
     - `[ ]` Título universitario / Certificado de estudios
   - Persistencia automática e instantánea en el dispositivo (`SharedPreferences`).

3. **Pantalla 3: Avisos Oficiales, Guías y Comunidad (`/news` - Tab 3)**
   - **Avisos Oficiales (Inmigración Australia)**: Novedades migratorias del Department of Home Affairs en tiempo real por RSS.
   - **Guías y Empleo**: Guía de cuenta bancaria australiana, cómo solicitar el TFN y ciudades con alta demanda.
   - **Comunidad & Divisas**: Tipo de cambio del dólar australiano ($AUD/EUR) y promociones de equipaje.
   - **Banner de Seguros de Viaje**: Promoción del 15% de descuento con Chapka / IATI Seguros en un clic.

---

## 🚀 Ejecutar la Aplicación en Local

1. Instala las dependencias de Flutter:
   ```bash
   flutter pub get
   ```
2. Ejecuta la app en Windows, Chrome, Android o iOS:
   ```bash
   flutter run -d windows
   ```
   *(La app incluye un **Modo Demo/Mock inteligente** que funciona al 100% de forma inmediata sin necesidad de configurar previamente claves de Firebase o RevenueCat en tu terminal local).*

---

## 📚 Guía de Conexión y Despliegue

Para instrucciones detalladas sobre cómo conectar Firebase en producción, habilitar RevenueCat con Apple/Google y desplegar la Cloud Function en Google Cloud, consulta el archivo oficial en español:
👉 **[docs/guia_conexion.md](file:///c:/Users/maverick.vila/OneDrive%20-%20Vueling%20Airlines,%20S.A/Documentos/Maverick/Antigravity/OzAlert/docs/guia_conexion.md)**

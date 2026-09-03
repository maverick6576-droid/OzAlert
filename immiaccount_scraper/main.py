import os
import sys
import time
import logging
from playwright.sync_api import sync_playwright
import firebase_admin
from firebase_admin import credentials, firestore, messaging

# Configurar logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s]: %(message)s")
logger = logging.getLogger("immi-scraper")

# Cargar variables de entorno
IMMI_USER = os.getenv("IMMI_USER")
IMMI_PASS = os.getenv("IMMI_PASS")
FIREBASE_CREDS_PATH = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")

# Inicializar Firebase si se detectan credenciales
db = None
if FIREBASE_CREDS_PATH and os.path.exists(FIREBASE_CREDS_PATH):
    try:
        cred = credentials.Certificate(FIREBASE_CREDS_PATH)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        logger.info("Firebase inicializado correctamente.")
    except Exception as e:
        logger.error(f"Error inicializando Firebase: {e}")
else:
    logger.warning("No se ha configurado GOOGLE_APPLICATION_CREDENTIALS. Firebase desactivado (Modo Dry-Run).")

def check_immiaccount_spain() -> str:
    """
    Inicia sesión en ImmiAccount usando Playwright, navega hasta el formulario 462 de España 
    y comprueba si salta el error 'The cap for this country has been reached'.
    """
    if not IMMI_USER or not IMMI_PASS:
        logger.error("Faltan las credenciales IMMI_USER e IMMI_PASS en el entorno.")
        return "ERROR"

    logger.info("Iniciando Playwright...")
    with sync_playwright() as p:
        # Lanzamos chromium. 
        # NOTA: En producción en Cloud Run no se debe usar headless=False
        browser = p.chromium.launch(headless=True, args=["--disable-blink-features=AutomationControlled"])
        context = browser.new_context(
            user_agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        )
        page = context.new_page()

        try:
            logger.info("Navegando a la página de login de ImmiAccount...")
            page.goto("https://online.immi.gov.au/lusc/login", timeout=30000)
            
            # Paso 1: Rellenar login
            logger.info("Introduciendo credenciales...")
            page.fill("input[name='username']", IMMI_USER)
            page.fill("input[name='password']", IMMI_PASS)
            page.click("button:has-text('Login')")
            
            # Paso 1.5: Manejar la pantalla de Multi-Factor Authentication (MFA)
            try:
                # ImmiAccount puede pedir MFA (authenticator). Buscamos si aparece el texto de MFA.
                page.wait_for_selector("a:has-text('New application'), button:has-text('Continue'), button:has-text('Submit')", timeout=15000)
                
                content = page.content().lower()
                if "code from the app" in content or "authenticator" in content or "multi-factor" in content or "authentication code" in content:
                    logger.info("Pantalla de MFA detectada. Generando código TOTP automáticamente...")
                    totp_secret = os.getenv("IMMI_TOTP_SECRET", "PAOX7GELEXGKQYONPRRQXS5OBAIESYWA")
                    import pyotp
                    code = pyotp.TOTP(totp_secret).now()
                    
                    # El campo de código suele ser el único input de tipo texto visible
                    page.fill("input[type='text'], input[id*='code'], input[name*='code']", code)
                    # El botón puede ser 'Continue' o 'Submit'
                    if page.locator("button:has-text('Submit')").is_visible():
                        page.click("button:has-text('Submit')")
                    else:
                        page.click("button:has-text('Continue')")
            except Exception as e:
                logger.info(f"Nota: No se detectó MFA o fue superado automáticamente. ({e})")

            # Paso 1.6: Pantalla intermedia de "Login successful" / Avisos
            try:
                page.wait_for_selector("a:has-text('New application'), button:has-text('Next')", timeout=10000)
                if page.locator("button:has-text('Next')").is_visible() and not page.locator("a:has-text('New application')").is_visible():
                    logger.info("Pantalla de avisos intermedios detectada. Haciendo clic en Next...")
                    page.click("button:has-text('Next')")
            except Exception as e:
                pass

            # Esperar a ver si cargó la pantalla principal
            page.wait_for_selector("text='New application'", timeout=20000)
            logger.info("Login exitoso. Dentro de ImmiAccount.")

            # Paso 2: Buscar aplicación existente (Draft) y darle a Edit
            # Esto evita crear cientos de aplicaciones basura y nos lleva directo a la página 5
            logger.info("Buscando aplicación existente en estado Incomplete...")
            edit_button = page.locator("text='Edit'").first
            if edit_button.is_visible():
                edit_button.click()
                logger.info("Reanudando aplicación existente...")
            else:
                logger.error("No se encontró el botón Edit. Crea una aplicación manualmente hasta la pag 5 primero.")
                page.screenshot(path="error_no_edit.png")
                return "ERROR"
            
            # Paso 3: Esperar a que cargue la primera página del formulario (normalmente 1/17)
            page.wait_for_load_state("load")
            time.sleep(3) # Pausa de seguridad
            
            # Paso 4: Bucle para avanzar rápido por las páginas ya guardadas
            logger.info("Avanzando por el borrador hasta encontrar el límite de cupos...")
            for _ in range(7):  # Máximo 7 páginas por seguridad
                page.wait_for_load_state("load")
                time.sleep(3) # Dejar que cargue la página actual y su AJAX
                
                content = page.content().lower()
                
                # Comprobar si saltó el cerrojazo
                if "lodgement is currently closed" in content or "cap for this country has been reached" in content or "suspended" in content:
                    logger.info("Resultado obtenido: CLOSED (Error de cupos encontrado)")
                    page.screenshot(path="final_state_closed.png")
                    return "CLOSED"
                
                # Hacemos clic en Next para avanzar de página o provocar el error
                next_button = page.locator("button:has-text('Next')").first
                if next_button.is_visible():
                    logger.info("Haciendo clic en Next...")
                    next_button.click()
                else:
                    logger.info("No se encontró el botón Next, rompiendo bucle.")
                    break
                    
            page.screenshot(path="final_state_open.png")
            logger.info("Resultado obtenido de ImmiAccount: OPEN (Sin errores visibles en el borrador)")
            return "OPEN"

        except Exception as e:
            logger.error(f"Error durante la automatización de Playwright: {e}")
            page.screenshot(path="error_screenshot.png")
            return "ERROR"
        finally:
            browser.close()

def trigger_alerts():
    """
    Si ImmiAccount detecta plazas abiertas, disparamos las alertas inmediatamente a Firebase.
    Evita enviar duplicados si ya estaba en OPEN.
    """
    if not db:
        logger.warning("No se envían alertas porque Firebase no está configurado.")
        return

    try:
        doc_ref = db.collection("visas").document("ES")
        doc = doc_ref.get()
        previous_status = doc.to_dict().get("status", "CLOSED") if doc.exists else "CLOSED"

        if previous_status == "OPEN":
            logger.info("ImmiAccount detecta OPEN, pero la BD ya estaba en OPEN. No se repite la alerta.")
            # Solo actualizamos el timestamp para indicar que sigue abierto
            doc_ref.set({
                "updatedAt": firestore.SERVER_TIMESTAMP,
                "source": "ImmiAccount Deep Scraper"
            }, merge=True)
            return

        logger.info("¡APERTURA DETECTADA EN IMMIACCOUNT! Disparando alertas FCM...")
        # 1. Actualizar base de datos
        doc_ref.set({
            "status": "OPEN",
            "updatedAt": firestore.SERVER_TIMESTAMP,
            "countryCode": "ES",
            "countryName": "Spain",
            "source": "ImmiAccount Deep Scraper"
        }, merge=True)

        # 2. Enviar mensaje FCM a topic 'ES'
        message = messaging.Message(
            notification=messaging.Notification(
                title="🚨 ¡PLAZAS ABIERTAS PARA ESPAÑA! 🚨",
                body="ImmiAccount acaba de abrir los cupos. ¡Corre a aplicar ahora mismo!"
            ),
            topic="ES"
        )
        response = messaging.send(message)
        logger.info(f"FCM enviado con éxito (Deep Scraper): {response}")

    except Exception as e:
        logger.error(f"Error al enviar alertas desde ImmiAccount Scraper: {e}")

def update_closed_status():
    """
    Actualiza la base de datos a CLOSED si ImmiAccount lo detecta, 
    sobrescribiendo de forma segura el estado de apertura.
    """
    if not db: return
    try:
        doc_ref = db.collection("visas").document("ES")
        doc_ref.set({
            "status": "CLOSED",
            "updatedAt": firestore.SERVER_TIMESTAMP,
            "source": "ImmiAccount Deep Scraper"
        }, merge=True)
        logger.info("Base de datos actualizada a CLOSED por el Deep Scraper.")
    except Exception as e:
        logger.error(f"Error actualizando a CLOSED: {e}")

if __name__ == "__main__":
    logger.info("Iniciando comprobación en ImmiAccount para ES...")
    status = check_immiaccount_spain()
    
    if status == "OPEN":
        trigger_alerts()
    elif status == "CLOSED":
        update_closed_status()
    else:
        logger.info("Sin cambios (o error) que notificar.")

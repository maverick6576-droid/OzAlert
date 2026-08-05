import os
import argparse
import logging
import functions_framework
from google.cloud import firestore
from config import COUNTRIES_CONFIG
from scraper import scrape_country_status
from notifier import send_fcm_alert, send_email_alert

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("ozvisa-main")

# Cliente Firestore con variable de entorno opcional
db = None
try:
    db = firestore.Client()
except Exception as e:
    logger.warning(f"No se pudo inicializar Firestore en entorno local o de pruebas sin GOOGLE_APPLICATION_CREDENTIALS: {e}")


@functions_framework.http
def check_visa_status(request=None):
    """
    Función de Google Cloud Function invocada por Cloud Scheduler cada 2 minutos.
    Retorna un JSON con el resultado de la comprobación para cada país del programa Work & Holiday.
    """
    logger.info("🚀 Iniciando rastreo de plazas del Departamento de Home Affairs de Australia...")
    results = {}
    total_writes = 0

    for country_code, info in COUNTRIES_CONFIG.items():
        country_name = info["name"]
        try:
            # 1. Obtener estado anterior de Firestore
            previous_status = "CLOSED"
            doc_ref = None
            if db:
                doc_ref = db.collection("visas").document(country_code)
                doc = doc_ref.get()
                if doc.exists and doc.to_dict():
                    previous_status = doc.to_dict().get("status", "CLOSED")

            # 2. Hacer scraping ligero al sitio oficial
            current_status = scrape_country_status(country_code)
            logger.info(f"[{country_code} - {country_name}] Estado anterior: {previous_status} | Estado actual: {current_status}")

            # 3. Optimización de cuota gratuita $0: SI NO HAY CAMBIOS Y EL DOCUMENTO YA EXISTE -> 0 ESCRITURAS
            if current_status == previous_status and doc is not None and doc.exists:
                logger.info(f"  └─ Sin cambios en {country_code}. Terminando (0 operaciones de escritura).")
                results[country_code] = {"status": current_status, "changed": False, "writes": 0}
                continue

            # 4. Si cambió el estado: actualizar documento en Firestore
            total_writes += 1
            if db and doc_ref:
                doc_ref.set({
                    "status": current_status,
                    "updatedAt": firestore.SERVER_TIMESTAMP,
                    "countryCode": country_code,
                    "countryName": country_name,
                    "subclass": info["subclass"],
                }, merge=True)
                logger.info(f"  └─ 📝 Firestore actualizado /visas/{country_code} -> {current_status}")

            # 5. Si cambió de CLOSED -> OPEN: DISPARAR ALERTA INMEDIATA PUSH & EMAIL
            if previous_status == "CLOSED" and current_status == "OPEN":
                logger.info(f"  └─ 🔔 ¡APERTURA EN {country_name}! Disparando alertas Push (FCM) y Email...")
                send_fcm_alert(country_code, country_name)

                # Buscar emails de usuarios suscritos en Firestore
                recipients = []
                if db:
                    users_query = db.collection("users").where("selectedCountryCode", "==", country_code).stream()
                    for u in users_query:
                        data = u.to_dict()
                        email = data.get("email")
                        if email:
                            recipients.append(email)
                send_email_alert(country_code, country_name, recipients)

            results[country_code] = {"status": current_status, "changed": True, "writes": 1}

        except Exception as e:
            logger.error(f"Error procesando {country_code}: {e}")
            results[country_code] = {"error": str(e)}

    summary = {
        "success": True,
        "total_countries": len(COUNTRIES_CONFIG),
        "total_firestore_writes": total_writes,
        "results": results,
    }
    logger.info(f"🎉 Ciclo de rastreo finalizado: {total_writes} escrituras totales.")
    return summary, 200, {"Content-Type": "application/json"}


# Ejecución de prueba desde terminal o CLI en desarrollo local
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ejecutar OzVisa Alert Scraper en local")
    parser.add_argument("--test-country", type=str, default="ES", help="Código de país a comprobar en modo dry-run")
    parser.add_argument("--simulate-open", action="store_true", help="Simular respuesta OPEN de la web de Australia")
    args = parser.parse_args()

    print("--- MODO DRY-RUN LOCAL (OzVisa Alert Cloud Function) ---")
    res, status_code, _ = check_visa_status()
    print("Resumen de comprobación JSON:")
    print(res)

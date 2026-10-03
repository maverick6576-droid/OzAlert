import os
import argparse
import logging
import functions_framework
from google.cloud import firestore
from config import COUNTRIES_CONFIG
from scraper import scrape_country_status
from notifier import send_fcm_alert, send_email_alert
from datetime import datetime, timezone

logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(name)s: %(message)s")
logger = logging.getLogger("ozvisa-main")

db = None
try:
    db = firestore.Client()
except Exception as e:
    logger.warning(f"Error init db: {e}")

@functions_framework.http
def check_visa_status(request=None):
    logger.info("Iniciando rastreo de plazas del Departamento de Home Affairs de Australia...")
    results = {}
    total_writes = 0

    for country_code, info in COUNTRIES_CONFIG.items():
        country_name = info["name"]
        try:
            previous_status = "CLOSED"
            source = "Public Web"
            updated_at = None
            doc_ref = None
            if db:
                doc_ref = db.collection("visas").document(country_code)
                doc = doc_ref.get()
                if doc.exists and doc.to_dict():
                    data = doc.to_dict()
                    previous_status = data.get("status", "CLOSED")
                    source = data.get("source", "Public Web")
                    updated_at = data.get("updatedAt")

            current_status = scrape_country_status(country_code)
            logger.info(f"[{country_code} - {country_name}] Estado anterior: {previous_status} (Fuente: {source}) | Estado actual web: {current_status}")

            # 2.5 ARBITRAJE DE SISTEMAS HIBRIDOS:
            if previous_status == "OPEN" and source == "ImmiAccount Deep Scraper" and current_status in ["CLOSED", "PAUSED"]:
                logger.info(f"  [Ignorado] ImmiAccount detecto OPEN. Ignorando el {current_status} de la web estatica retrasada.")
                results[country_code] = {"status": "OPEN (Override)", "changed": False, "writes": 0}
                continue

            # 2.6 PROTECCION ANTI-BUCLE Y EXPIRACION DE CANDADO:
            source_to_save = "Public Web"
            
            lock_age_hours = 0
            if source == "ImmiAccount Deep Scraper" and updated_at:
                try:
                    lock_age_hours = (datetime.now(timezone.utc) - updated_at).total_seconds() / 3600
                except Exception as e:
                    pass

            if previous_status in ["CLOSED", "PAUSED"] and source == "ImmiAccount Deep Scraper" and current_status == "OPEN":
                if lock_age_hours < 8:
                    logger.info(f"  [PROTECCION ANTI-BUCLE]: ImmiAccount cerro hace poco. La web publica miente. Forzando a PAUSED.")
                    current_status = "PAUSED"
                    source_to_save = "ImmiAccount Deep Scraper"
                else:
                    logger.info(f"  [APERTURA REAL]: Han pasado varias horas desde el cierre de ImmiAccount. La web publica anuncia nueva apertura.")
                    source_to_save = "Public Web"
                    
            # 3. Optimizacion de cuota gratuita
            if current_status == previous_status and doc is not None and doc.exists:
                if source == "ImmiAccount Deep Scraper" and current_status in ["CLOSED", "PAUSED"]:
                    logger.info(f"  [DESBLOQUEO]: La web publica por fin marca {current_status}. Soltando candado de ImmiAccount.")
                    source_to_save = "Public Web"
                    # No hacemos continue, forzamos la escritura para actualizar el source
                else:
                    logger.info(f"  Sin cambios en {country_code}. Terminando (0 operaciones de escritura).")
                    results[country_code] = {"status": current_status, "changed": False, "writes": 0}
                    continue

            # 4. Actualizar Firestore
            total_writes += 1
            if db and doc_ref:
                doc_ref.set({
                    "status": current_status,
                    "updatedAt": firestore.SERVER_TIMESTAMP,
                    "countryCode": country_code,
                    "countryName": country_name,
                    "subclass": info["subclass"],
                    "source": source_to_save
                }, merge=True)
                logger.info(f"  Firestore actualizado /visas/{country_code} -> {current_status} (Fuente: {source_to_save})")

            # 5. DISPARAR ALERTA INMEDIATA PUSH & EMAIL
            if previous_status != "OPEN" and current_status == "OPEN":
                logger.info(f"  APERTURA EN {country_name}! Disparando alertas Push (FCM) y Email...")
                send_fcm_alert(country_code, country_name)

                recipients = []
                if db:
                    users_query = db.collection("users").where("passports", "array_contains", country_name).stream()
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
    logger.info(f"Ciclo finalizado: {total_writes} escrituras totales.")
    return summary, 200, {"Content-Type": "application/json"}

if __name__ == "__main__":
    check_visa_status()

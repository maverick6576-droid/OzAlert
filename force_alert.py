import os
import firebase_admin
from firebase_admin import credentials, firestore, messaging
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("force-alert")

if not firebase_admin._apps:
    firebase_admin.initialize_app()

db = firestore.client()

def send_fcm_alert():
    topic = "visa_ES"
    title = "🚨 ¡PLAZAS ABIERTAS PARA ESPAÑA! 🚨"
    body = "El Departamento de Home Affairs ha abierto plazas de visa para Spain. Entra ahora a tu ImmiAccount."
    message = messaging.Message(
        notification=messaging.Notification(title=title, body=body),
        topic=topic,
        android=messaging.AndroidConfig(
            priority="high",
            notification=messaging.AndroidNotification(
                channel_id="ozvisa_radar_channel_siren_v6",
                icon="ic_launcher",
                color="#00F59B",
                sound="siren.wav",
            ),
        ),
        apns=messaging.APNSConfig(
            payload=messaging.APNSPayload(
                aps=messaging.Aps(sound="siren.wav", badge=1)
            )
        ),
    )
    response = messaging.send(message)
    logger.info(f"✅ FCM enviado: {response}")

def send_email_alert():
    recipients = []
    users_query = db.collection("users").where("passports", "array_contains", "Spain").stream()
    for u in users_query:
        data = u.to_dict()
        email = data.get("email")
        if email:
            recipients.append(email)
    
    logger.info(f"Encontrados {len(recipients)} usuarios suscritos a España.")
    
    resend_api_key = os.getenv("RESEND_API_KEY")
    if not resend_api_key:
        logger.warning("Falta RESEND_API_KEY, no se envían emails en local a menos que pongas export RESEND_API_KEY=...")
        return
        
    try:
        import resend
        resend.api_key = resend_api_key
        title = "🚨 ¡ALERTA OZVISA: Se han abierto plazas Work and Holiday para Spain!"
        html_body = "<div style=\"font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #0A0F1D; color: #F8FAFC; padding: 30px; border-radius: 12px;\"><h1 style=\"color: #00F59B;\">¡Apertura Confirmada para Spain!</h1><p style=\"font-size: 16px; line-height: 1.5;\">El sistema de rastreo de <b>OzVisa Alert</b> acaba de confirmar que el Departamento de Home Affairs de Australia tiene plazas disponibles en este segundo.</p><div style=\"background-color: #131B2E; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #00F59B;\"><p style=\"margin: 0; font-weight: bold; color: #00F59B;\">Acción Requerida:</p><p style=\"margin: 5px 0 0 0;\">Entra inmediatamente a tu ImmiAccount oficial de Australia y completa el envío de tu aplicación.</p></div><a href=\"https://immi.homeaffairs.gov.au\" style=\"display: inline-block; background-color: #00F59B; color: #000000; padding: 14px 28px; border-radius: 8px; font-weight: bold; text-decoration: none;\">Ir a ImmiAccount Ahora</a></div>"
        
        for email in recipients:
            resend.Emails.send({
                "from": "OzVisa Radar <alertas@ozvisa-alert.app>",
                "to": email,
                "subject": title,
                "html": html_body,
            })
        logger.info(f"✅ Emails enviados a {len(recipients)} usuarios.")
    except Exception as e:
        logger.error(f"Error enviando emails: {e}")

if __name__ == "__main__":
    send_fcm_alert()
    send_email_alert()

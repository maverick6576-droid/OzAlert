import os
import logging
import firebase_admin
from firebase_admin import messaging

logger = logging.getLogger("ozvisa-notifier")

# Verificar si está inicializado Firebase Admin
try:
    if not firebase_admin._apps:
        firebase_admin.initialize_app()
except Exception as e:
    logger.warning(f"No se pudo inicializar Firebase Admin (modo local): {e}")


def send_fcm_alert(country_code: str, country_name: str) -> bool:
    """
    Envía una notificación Push en tiempo real al tópico /topics/visa_{country_code} en Firebase Cloud Messaging.
    """
    topic = f"visa_{country_code}"
    title = f"¡PLAZAS ABIERTAS: Australia WHV {country_name}!"
    body = f"¡ATENCIÓN! El Departamento de Home Affairs ha abierto plazas de visa para {country_name}. Entra ahora a tu ImmiAccount y aplica."

    try:
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
        logger.info(f"✅ Alerta FCM enviada con éxito al tópico {topic}: {response}")
        return True
    except Exception as e:
        logger.error(f"Error al enviar notificación FCM al tópico {topic}: {e}")
        return False



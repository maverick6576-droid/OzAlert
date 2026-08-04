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
                    channel_id="ozvisa_radar_channel",
                    icon="ic_launcher",
                    color="#00F59B",
                ),
            ),
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(sound="default", badge=1)
                )
            ),
        )
        response = messaging.send(message)
        logger.info(f"✅ Alerta FCM enviada con éxito al tópico {topic}: {response}")
        return True
    except Exception as e:
        logger.error(f"Error al enviar notificación FCM al tópico {topic}: {e}")
        return False


def send_email_alert(country_code: str, country_name: str, recipients: list[str]) -> bool:
    """
    Envía un Email de alerta masivo a los usuarios suscritos utilizando Resend API
    o SendGrid API (cero servidores propios).
    """
    if not recipients:
        logger.info(f"No hay destinatarios de correo para {country_code}.")
        return True

    resend_api_key = os.getenv("RESEND_API_KEY")
    sendgrid_api_key = os.getenv("SENDGRID_API_KEY")

    title = f"¡ALERTA OZVISA: Se han abierto plazas Work and Holiday para {country_name}!"
    html_body = f"""
    <div style="font-family: 'Helvetica Neue', Arial, sans-serif; background-color: #0A0F1D; color: #F8FAFC; padding: 30px; border-radius: 12px;">
      <h1 style="color: #00F59B;">¡Apertura Confirmada para {country_name}!</h1>
      <p style="font-size: 16px; line-height: 1.5;">
        El sistema de rastreo de <b>OzVisa Alert</b> acaba de confirmar que el Departamento de Home Affairs de Australia tiene plazas disponibles en este segundo.
      </p>
      <div style="background-color: #131B2E; padding: 20px; border-radius: 8px; margin: 20px 0; border: 1px solid #00F59B;">
        <p style="margin: 0; font-weight: bold; color: #00F59B;">Acción Requerida:</p>
        <p style="margin: 5px 0 0 0;">Entra inmediatamente a tu ImmiAccount oficial de Australia y completa el envío de tu aplicación con tus PDFs adjuntos.</p>
      </div>
      <a href="https://immi.homeaffairs.gov.au" style="display: inline-block; background-color: #00F59B; color: #000000; padding: 14px 28px; border-radius: 8px; font-weight: bold; text-decoration: none;">Ir a ImmiAccount Ahora</a>
    </div>
    """

    if resend_api_key:
        try:
            import resend
            resend.api_key = resend_api_key
            for email in recipients:
                resend.Emails.send({
                    "from": "OzVisa Radar <alertas@ozvisa-alert.app>",
                    "to": email,
                    "subject": title,
                    "html": html_body,
                })
            logger.info(f"✅ Emails enviados por Resend a {len(recipients)} usuarios.")
            return True
        except Exception as e:
            logger.error(f"Error al enviar correo por Resend: {e}")

    elif sendgrid_api_key:
        try:
            import requests
            headers = {
                "Authorization": f"Bearer {sendgrid_api_key}",
                "Content-Type": "application/json",
            }
            for email in recipients:
                payload = {
                    "personalizations": [{"to": [{"email": email}]}],
                    "from": {"email": "alertas@ozvisa-alert.app", "name": "OzVisa Radar"},
                    "subject": title,
                    "content": [{"type": "text/html", "value": html_body}],
                }
                requests.post("https://api.sendgrid.com/v3/mail/send", headers=headers, json=payload)
            logger.info(f"✅ Emails enviados por SendGrid a {len(recipients)} usuarios.")
            return True
        except Exception as e:
            logger.error(f"Error al enviar correo por SendGrid: {e}")

    logger.warning("No se ha configurado RESEND_API_KEY o SENDGRID_API_KEY. Omisión de envío de correo.")
    return False

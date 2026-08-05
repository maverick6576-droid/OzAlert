import os
import hashlib
import urllib.parse
import feedparser
from bs4 import BeautifulSoup
import functions_framework
import firebase_admin
from firebase_admin import credentials, firestore, messaging

# Inicializar Firebase Admin si no está inicializado
if not firebase_admin._apps:
    # Se inicializa con las credenciales por defecto de Google Cloud
    firebase_admin.initialize_app()

db = firestore.client()

# ===================================================================
# CONFIGURACIÓN
# ===================================================================

# Lista de URLs de feeds RSS de Google Alerts proporcionadas por el usuario.
RSS_FEED_URLS = [
    "https://www.google.com/alerts/feeds/11138616755529560004/13556120012098396995",
]

# Topic de FCM al que enviar las notificaciones
FCM_TOPIC = "all_users"

# Colección de Firestore donde se guardarán las noticias para evitar duplicados
FIRESTORE_COLLECTION = "noticias"


# ===================================================================
# FUNCIONES AUXILIARES
# ===================================================================

def clean_html(text):
    """Elimina las etiquetas HTML de un texto usando BeautifulSoup."""
    if not text:
        return ""
    soup = BeautifulSoup(text, "html.parser")
    # Extraer el texto limpio (sin tags <b>, <i>, etc.)
    return soup.get_text(strip=True)

def clean_google_url(google_url):
    """
    Las URLs de Google Alerts suelen venir ofuscadas en la forma:
    https://www.google.com/url?rct=j&sa=t&url=http://url_real...&ct=...
    Extrae la URL real si existe.
    """
    try:
        parsed = urllib.parse.urlparse(google_url)
        if "google.com/url" in google_url:
            qs = urllib.parse.parse_qs(parsed.query)
            if "url" in qs:
                return qs["url"][0]
    except Exception as e:
        print(f"Error limpiando URL {google_url}: {e}")
    return google_url

def generate_news_id(url):
    """Genera un ID único (hash SHA-256) basado en la URL de la noticia."""
    return hashlib.sha256(url.encode('utf-8')).hexdigest()

def send_push_notification(title, body):
    """Envía una notificación Push vía FCM al topic definido."""
    try:
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            topic=FCM_TOPIC,
            # Añadimos datos opcionales por si la app quiere procesarlos
            data={
                "type": "rss_alert",
                "click_action": "FLUTTER_NOTIFICATION_CLICK",
            }
        )
        response = messaging.send(message)
        print(f"Push enviada con éxito. Message ID: {response}")
    except Exception as e:
        print(f"Error enviando notificación Push FCM: {e}")


# ===================================================================
# CLOUD FUNCTION MAIN ENTRY POINT
# ===================================================================

@functions_framework.http
def process_rss_alerts(request):
    """
    Cloud Function disparada por HTTP (ideal para Cloud Scheduler).
    Lee los RSS de Google Alerts, guarda noticias nuevas en Firestore
    y dispara notificaciones push FCM.
    """
    print("Iniciando procesamiento de RSS Google Alerts...")
    
    news_processed = 0
    news_added = 0
    
    for feed_url in RSS_FEED_URLS:
        print(f"Leyendo feed: {feed_url}")
        feed = feedparser.parse(feed_url)
        
        for entry in feed.entries:
            news_processed += 1
            
            raw_title = entry.get("title", "")
            raw_link = entry.get("link", "")
            raw_summary = entry.get("summary", "")
            published_date = entry.get("published", "")
            
            # Limpieza de HTML
            clean_title = clean_html(raw_title)
            clean_summary = clean_html(raw_summary)
            clean_link = clean_google_url(raw_link)
            
            # Generar ID único
            news_id = generate_news_id(clean_link)
            
            # Referencia al documento en Firestore
            doc_ref = db.collection(FIRESTORE_COLLECTION).document(news_id)
            
            try:
                # Comprobar existencia para evitar duplicados (optimización Free Tier)
                doc = doc_ref.get()
                
                if not doc.exists:
                    # 1. Guardar la nueva noticia en Firestore
                    doc_ref.set({
                        "title": clean_title,
                        "link": clean_link,
                        "summary": clean_summary,
                        "published_date": published_date,
                        "fecha_creacion": firestore.SERVER_TIMESTAMP,
                        "source": "google_alerts"
                    })
                    print(f"[NUEVO] Se guardó la noticia: {clean_title}")
                    
                    # 2. Disparar notificación Push
                    # Acortamos el summary si es muy largo para la notificación (FCM soporta más pero es buena práctica)
                    short_summary = (clean_summary[:120] + '...') if len(clean_summary) > 120 else clean_summary
                    
                    send_push_notification(
                        title="🚨 Alerta de Visa Australia",
                        body=f"{clean_title}\n{short_summary}"
                    )
                    
                    news_added += 1
                else:
                    # La noticia ya fue procesada anteriormente, se ignora.
                    print(f"[DUPLICADO] Omitiendo noticia existente: {clean_title}")
                    
            except Exception as e:
                print(f"Error procesando la noticia ID {news_id}: {e}")

    summary_response = {
        "status": "success",
        "news_processed": news_processed,
        "news_added": news_added,
        "message": f"Se analizaron {news_processed} noticias. {news_added} eran nuevas y enviaron Push."
    }
    
    print(f"Proceso finalizado. {summary_response}")
    return summary_response, 200, {"Content-Type": "application/json"}

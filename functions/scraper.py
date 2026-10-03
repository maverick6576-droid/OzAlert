import logging
import requests
from bs4 import BeautifulSoup
from config import COUNTRIES_CONFIG, HTTP_HEADERS

logger = logging.getLogger("ozvisa-scraper")


def scrape_country_status(country_code: str, mock_html: str = None) -> str:
    """
    Inspecciona la pÃgina del Departamento de Home Affairs de Australia para el paÃ­s especificado
    y determina si el estado de plazas es 'OPEN' o 'CLOSED'.

    :param country_code: CÃ³digo ISO (ej: 'ES', 'AR', 'IT')
    :param mock_html: HTML simulado para pruebas locales o unitarias sin red
    :return: 'OPEN' si hay plazas abiertas, 'CLOSED' si estÃ cerrado.
    """
    config = COUNTRIES_CONFIG.get(country_code)
    if not config:
        logger.warning(f"PaÃ­s {country_code} no configurado en COUNTRIES_CONFIG")
        return "CLOSED"

    try:
        if mock_html:
            html_content = mock_html
        else:
            url = config["url"]
            response = requests.get(url, headers=HTTP_HEADERS, timeout=10)
            response.raise_for_status()
            html_content = response.text

        soup = BeautifulSoup(html_content, "html.parser")
        text_lower = soup.get_text(separator=" ").lower()

        # Estrategia de detecciÃ³n del estado en base al nombre del paÃ­s en inglÃ©s y palabras clave
        country_en = config.get("en_name", config["name"].lower())

        # Buscar tablas y pÃrrafos especÃ­ficos que incluyan al paÃ­s (tr, li, p)
        # Omitimos div o section porque agrupan mÃºltiples paÃ­ses y causan falsos negativos
        for row_or_tag in soup.find_all(["tr", "li", "p"]):
            tag_text = row_or_tag.get_text(separator=" ").lower()
            # Asegurarnos de que el texto es corto (una fila individual) y contiene el paÃ­s
            if len(tag_text) < 300 and country_en in tag_text:
                if any(w in tag_text for w in ["open", "available", "lodgements open"]):
                    if not any(w in tag_text for w in ["closed", "paused", "filled"]):
                        return "OPEN"
                if any(w in tag_text for w in ["paused"]):
                    return "PAUSED"
                if any(w in tag_text for w in ["closed", "reached", "filled"]):
                    return "CLOSED"

        return "CLOSED"
    except Exception as e:
        logger.error(f"Error durante el scraping para {country_code}: {e}")
        # En caso de error de red, mantener el estado actual para evitar falsas alarmas (0 escrituras)
        return "CLOSED"

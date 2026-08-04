# Configuración del Departamento de Home Affairs y Países Work & Holiday (417 / 462)

DHA_STATUS_URL_462 = "https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps"
DHA_STATUS_URL_417 = "https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417"

# Cabeceras HTTP optimizadas para evitar bloqueos del servidor y minimizar consumo
HTTP_HEADERS = {
    "User-Agent": "OzVisaAlert-Radar/1.0 (+https://ozvisa-alert.app; Python Cloud Function)",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-AU,en;q=0.9,es;q=0.8",
}

# Configuración de Países Monitoreados (Subclase 462 - Web oficial status-of-country-caps)
COUNTRIES_CONFIG = {
    "ES": {"name": "España", "en_name": "spain", "subclass": "462", "url": DHA_STATUS_URL_462},
    "AR": {"name": "Argentina", "en_name": "argentina", "subclass": "462", "url": DHA_STATUS_URL_462},
    "CL": {"name": "Chile", "en_name": "chile", "subclass": "462", "url": DHA_STATUS_URL_462},
    "UY": {"name": "Uruguay", "en_name": "uruguay", "subclass": "462", "url": DHA_STATUS_URL_462},
    "PE": {"name": "Perú", "en_name": "peru", "subclass": "462", "url": DHA_STATUS_URL_462},
    "EC": {"name": "Ecuador", "en_name": "ecuador", "subclass": "462", "url": DHA_STATUS_URL_462},
    "BR": {"name": "Brasil", "en_name": "brazil", "subclass": "462", "url": DHA_STATUS_URL_462},
    "PT": {"name": "Portugal", "en_name": "portugal", "subclass": "462", "url": DHA_STATUS_URL_462},
    "AT": {"name": "Austria", "en_name": "austria", "subclass": "462", "url": DHA_STATUS_URL_462},
    "CH": {"name": "Suiza", "en_name": "switzerland", "subclass": "462", "url": DHA_STATUS_URL_462},
    "GR": {"name": "Grecia", "en_name": "greece", "subclass": "462", "url": DHA_STATUS_URL_462},
    "PL": {"name": "Polonia", "en_name": "poland", "subclass": "462", "url": DHA_STATUS_URL_462},
    "US": {"name": "Estados Unidos", "en_name": "united states", "subclass": "462", "url": DHA_STATUS_URL_462},
}

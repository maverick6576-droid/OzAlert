# Configuración del Departamento de Home Affairs y Países Work & Holiday (417 / 462)

DHA_STATUS_URL_462 = "https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-462/status-of-country-caps"
DHA_STATUS_URL_417 = "https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417"

# Cabeceras HTTP optimizadas para evitar bloqueos del servidor y minimizar consumo
HTTP_HEADERS = {
    "User-Agent": "OzVisaAlert-Radar/1.0 (+https://ozvisa-alert.app; Python Cloud Function)",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "en-AU,en;q=0.9,es;q=0.8",
}

# Configuración de Países Monitoreados
COUNTRIES_CONFIG = {
    "ES": {"name": "España", "subclass": "462", "url": DHA_STATUS_URL_462, "keywords_open": ["spain", "open", "available"]},
    "AR": {"name": "Argentina", "subclass": "462", "url": DHA_STATUS_URL_462, "keywords_open": ["argentina", "open", "available"]},
    "CL": {"name": "Chile", "subclass": "462", "url": DHA_STATUS_URL_462, "keywords_open": ["chile", "open", "available"]},
    "UY": {"name": "Uruguay", "subclass": "462", "url": DHA_STATUS_URL_462, "keywords_open": ["uruguay", "open", "available"]},
    "PE": {"name": "Perú", "subclass": "462", "url": DHA_STATUS_URL_462, "keywords_open": ["peru", "open", "available"]},
    "IT": {"name": "Italia", "subclass": "417", "url": DHA_STATUS_URL_417, "keywords_open": ["italy", "open"]},
    "FR": {"name": "Francia", "subclass": "417", "url": DHA_STATUS_URL_417, "keywords_open": ["france", "open"]},
    "GB": {"name": "Reino Unido", "subclass": "417", "url": DHA_STATUS_URL_417, "keywords_open": ["united kingdom", "open"]},
    "DE": {"name": "Alemania", "subclass": "417", "url": DHA_STATUS_URL_417, "keywords_open": ["germany", "open"]},
}

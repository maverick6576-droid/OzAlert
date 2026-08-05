# Configuración del Departamento de Home Affairs y Países Work & Holiday (417 / 462)

DHA_STATUS_URL_462 = "https://immi.homeaffairs.gov.au/what-we-do/whm-program/status-of-country-caps"
DHA_STATUS_URL_417 = "https://immi.homeaffairs.gov.au/visas/getting-a-visa/visa-listing/work-holiday-417"

# Cabeceras HTTP optimizadas simulando un navegador Chrome real para evitar bloqueos del firewall (WAF) del gobierno
HTTP_HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,en-AU;q=0.8,es;q=0.7",
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
    "CN": {"name": "China", "en_name": "china", "subclass": "462", "url": DHA_STATUS_URL_462},
    "CZ": {"name": "República Checa", "en_name": "czech republic", "subclass": "462", "url": DHA_STATUS_URL_462},
    "HU": {"name": "Hungría", "en_name": "hungary", "subclass": "462", "url": DHA_STATUS_URL_462},
    "IN": {"name": "India", "en_name": "india", "subclass": "462", "url": DHA_STATUS_URL_462},
    "ID": {"name": "Indonesia", "en_name": "indonesia", "subclass": "462", "url": DHA_STATUS_URL_462},
    "IL": {"name": "Israel", "en_name": "israel", "subclass": "462", "url": DHA_STATUS_URL_462},
    "LU": {"name": "Luxemburgo", "en_name": "luxembourg", "subclass": "462", "url": DHA_STATUS_URL_462},
    "MY": {"name": "Malasia", "en_name": "malaysia", "subclass": "462", "url": DHA_STATUS_URL_462},
    "MN": {"name": "Mongolia", "en_name": "mongolia", "subclass": "462", "url": DHA_STATUS_URL_462},
    "PG": {"name": "Papúa Nueva Guinea", "en_name": "papua new guinea", "subclass": "462", "url": DHA_STATUS_URL_462},
    "SM": {"name": "San Marino", "en_name": "san marino", "subclass": "462", "url": DHA_STATUS_URL_462},
    "SG": {"name": "Singapur", "en_name": "singapore", "subclass": "462", "url": DHA_STATUS_URL_462},
    "SK": {"name": "Eslovaquia", "en_name": "slovak republic", "subclass": "462", "url": DHA_STATUS_URL_462},
    "SI": {"name": "Eslovenia", "en_name": "slovenia", "subclass": "462", "url": DHA_STATUS_URL_462},
    "TH": {"name": "Tailandia", "en_name": "thailand", "subclass": "462", "url": DHA_STATUS_URL_462},
    "TR": {"name": "Turquía", "en_name": "türkiye", "subclass": "462", "url": DHA_STATUS_URL_462},
    "VN": {"name": "Vietnam", "en_name": "vietnam", "subclass": "462", "url": DHA_STATUS_URL_462},
}

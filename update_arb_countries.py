import json

def add_keys(path, new_keys):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(new_keys)
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

es_keys = {
    "countryAR": "Argentina",
    "countryAT": "Austria",
    "countryBR": "Brasil",
    "countryCL": "Chile",
    "countryCN": "China",
    "countryCZ": "República Checa",
    "countryEC": "Ecuador",
    "countryGR": "Grecia",
    "countryHU": "Hungría",
    "countryIN": "India",
    "countryID": "Indonesia",
    "countryIL": "Israel",
    "countryLU": "Luxemburgo",
    "countryMY": "Malasia",
    "countryMN": "Mongolia",
    "countryPG": "Papúa Nueva Guinea",
    "countryPE": "Perú",
    "countryPL": "Polonia",
    "countryPT": "Portugal",
    "countrySM": "San Marino",
    "countrySG": "Singapur",
    "countrySK": "Eslovaquia",
    "countrySI": "Eslovenia",
    "countryES": "España",
    "countryCH": "Suiza",
    "countryTH": "Tailandia",
    "countryTR": "Turquía",
    "countryUY": "Uruguay",
    "countryVN": "Vietnam"
}

en_keys = {
    "countryAR": "Argentina",
    "countryAT": "Austria",
    "countryBR": "Brazil",
    "countryCL": "Chile",
    "countryCN": "China",
    "countryCZ": "Czech Republic",
    "countryEC": "Ecuador",
    "countryGR": "Greece",
    "countryHU": "Hungary",
    "countryIN": "India",
    "countryID": "Indonesia",
    "countryIL": "Israel",
    "countryLU": "Luxembourg",
    "countryMY": "Malaysia",
    "countryMN": "Mongolia",
    "countryPG": "Papua New Guinea",
    "countryPE": "Peru",
    "countryPL": "Poland",
    "countryPT": "Portugal",
    "countrySM": "San Marino",
    "countrySG": "Singapore",
    "countrySK": "Slovakia",
    "countrySI": "Slovenia",
    "countryES": "Spain",
    "countryCH": "Switzerland",
    "countryTH": "Thailand",
    "countryTR": "Turkey",
    "countryUY": "Uruguay",
    "countryVN": "Vietnam"
}

add_keys("lib/l10n/app_es.arb", es_keys)
add_keys("lib/l10n/app_en.arb", en_keys)

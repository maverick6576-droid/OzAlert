import json

def add_keys(path, new_keys):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(new_keys)
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

es_keys = {
    "radarLastChecked": "Última comprobación: hace {seconds} segundos (Frecuencia: cada 60 seg)",
    "@radarLastChecked": {
        "placeholders": {
            "seconds": {
                "type": "String"
            }
        }
    },
    "newsExplore": "Explorar",
    "newsUpdated": "ACTUALIZADO"
}

en_keys = {
    "radarLastChecked": "Last checked: {seconds} seconds ago (Frequency: every 60 sec)",
    "@radarLastChecked": {
        "placeholders": {
            "seconds": {
                "type": "String"
            }
        }
    },
    "newsExplore": "Explore",
    "newsUpdated": "UPDATED"
}

add_keys("lib/l10n/app_es.arb", es_keys)
add_keys("lib/l10n/app_en.arb", en_keys)

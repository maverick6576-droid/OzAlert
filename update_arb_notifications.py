import json

def add_keys(path, new_keys):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(new_keys)
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

es_keys = {
    "notificationTestTitle": "🔔 TEST ALERTA: OzVisa Radar Activo ({countryName})",
    "@notificationTestTitle": {
        "placeholders": {
            "countryName": {
                "type": "String"
            }
        }
    },
    "notificationTestBody": "✅ Conexión verificada: Servidores monitoreando visas 24/7 en tiempo real.",
    "notificationTestLongBody": "¡El sistema de rastreo de los servidores de OzVisa Alert está operativo para {countryName}! Te notificaremos al segundo en que el Departamento de Home Affairs abra plazas.",
    "@notificationTestLongBody": {
        "placeholders": {
            "countryName": {
                "type": "String"
            }
        }
    },
    "notificationChannelName": "OzVisa Alertas de Apertura",
    "notificationChannelDesc": "Notificaciones inmediatas de apertura de plazas de visa Work & Holiday",
    "notificationTestTicker": "OzVisa Alerta Test"
}

en_keys = {
    "notificationTestTitle": "🔔 TEST ALERT: OzVisa Radar Active ({countryName})",
    "@notificationTestTitle": {
        "placeholders": {
            "countryName": {
                "type": "String"
            }
        }
    },
    "notificationTestBody": "✅ Connection verified: Servers monitoring visas 24/7 in real time.",
    "notificationTestLongBody": "OzVisa Alert's tracking system is now active for {countryName}! We will notify you the exact second the Department of Home Affairs opens new spots.",
    "@notificationTestLongBody": {
        "placeholders": {
            "countryName": {
                "type": "String"
            }
        }
    },
    "notificationChannelName": "OzVisa Opening Alerts",
    "notificationChannelDesc": "Immediate notifications for Work & Holiday visa spots openings",
    "notificationTestTicker": "OzVisa Test Alert"
}

add_keys("lib/l10n/app_es.arb", es_keys)
add_keys("lib/l10n/app_en.arb", en_keys)

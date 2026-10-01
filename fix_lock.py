import codecs
import re

with codecs.open('functions/main.py', 'r', 'utf-8') as f:
    text = f.read()

# 1. Capture updatedAt
text = text.replace('source = data.get("source", "Public Web")', 'source = data.get("source", "Public Web")\n                    updated_at = data.get("updatedAt")')

# 2. Modify Anti-Loop to check timestamp
old_anti_loop = '''            # 2.6 PROTECCION ANTI-BUCLE (FALSO OPEN):
            # ImmiAccount comprobo que ya no hay plazas (CLOSED), pero la web publica va con retraso y sigue diciendo OPEN.
            source_to_save = "Public Web"
            if previous_status in ["CLOSED", "PAUSED"] and source == "ImmiAccount Deep Scraper" and current_status == "OPEN":
                logger.info(f"  [PROTECCION ANTI-BUCLE]: ImmiAccount ya cerro las plazas, pero la web publica miente diciendo OPEN. Forzando a PAUSED.")
                current_status = "PAUSED"
                source_to_save = "ImmiAccount Deep Scraper"  # Mantenemos autoria para que el candado siga activo'''

new_anti_loop = '''            # 2.6 PROTECCION ANTI-BUCLE Y EXPIRACION DE CANDADO:
            source_to_save = "Public Web"
            
            # Calculamos la edad del candado de ImmiAccount
            lock_age_hours = 0
            if source == "ImmiAccount Deep Scraper" and updated_at:
                from datetime import datetime, timezone
                try:
                    lock_age_hours = (datetime.now(timezone.utc) - updated_at).total_seconds() / 3600
                except Exception as e:
                    pass

            if previous_status in ["CLOSED", "PAUSED"] and source == "ImmiAccount Deep Scraper" and current_status == "OPEN":
                if lock_age_hours < 12:
                    # Si hace menos de 12 horas que ImmiAccount cerró, la web pública está retrasada (FALSO OPEN).
                    logger.info(f"  [PROTECCION ANTI-BUCLE]: ImmiAccount cerro hace poco. La web publica miente. Forzando a PAUSED.")
                    current_status = "PAUSED"
                    source_to_save = "ImmiAccount Deep Scraper"  # Mantenemos candado
                else:
                    # Han pasado mas de 12 horas. Esto es una APERTURA REAL al dia siguiente. Rompemos el candado.
                    logger.info(f"  [APERTURA REAL]: Han pasado {lock_age_hours:.1f}h desde el cierre de ImmiAccount. La web publica anuncia nueva apertura.")
                    source_to_save = "Public Web"
                    # Permitimos que current_status se quede en "OPEN" para que dispare alertas abajo!'''

text = text.replace(old_anti_loop, new_anti_loop)

with codecs.open('functions/main.py', 'w', 'utf-8') as f:
    f.write(text)

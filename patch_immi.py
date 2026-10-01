import codecs

with codecs.open('immiaccount_scraper/main.py', 'r', 'utf-8') as f:
    text = f.read()

# Replace the "CLOSED" string with "PAUSED" inside update_closed_status
new_func = '''def update_closed_status():
    \"\"\"
    Actualiza la base de datos a PAUSED si ImmiAccount detecta que ya no hay plazas,
    dejando el estado CLOSED reservado unicamente para la web publica oficial.
    \"\"\"
    if not db: return
    try:
        doc_ref = db.collection("visas").document("ES")
        doc_ref.set({
            "status": "PAUSED",
            "updatedAt": firestore.SERVER_TIMESTAMP,
            "source": "ImmiAccount Deep Scraper"
        }, merge=True)
        logger.info("Base de datos actualizada a PAUSED por el Deep Scraper (ImmiAccount).")
    except Exception as e:
        logger.error(f"Error actualizando a PAUSED: {e}")'''

import re
text = re.sub(r'def update_closed_status\(\):.*?except Exception as e:\s+logger\.error\(f"Error actualizando a CLOSED: \{e\}"\)', new_func, text, flags=re.DOTALL)

with codecs.open('immiaccount_scraper/main.py', 'w', 'utf-8') as f:
    f.write(text)

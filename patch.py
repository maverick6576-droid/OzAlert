import codecs

with codecs.open('functions/main.py', 'r', 'utf-8') as f:
    text = f.read()

new_block = '''            # 2.6 PROTECCION ANTI-BUCLE (FALSO OPEN):
            # ImmiAccount comprobo que ya no hay plazas (CLOSED), pero la web publica va con retraso y sigue diciendo OPEN.
            source_to_save = "Public Web"
            if previous_status in ["CLOSED", "PAUSED"] and source == "ImmiAccount Deep Scraper" and current_status == "OPEN":
                logger.info(f"  [PROTECCION ANTI-BUCLE]: ImmiAccount ya cerro las plazas, pero la web publica miente diciendo OPEN. Forzando a PAUSED.")
                current_status = "PAUSED"
                source_to_save = "ImmiAccount Deep Scraper"  # Mantenemos autoria para que el candado siga activo

            # 3.'''

text = text.replace('            # 3.', new_block, 1)
text = text.replace('"source": "Public Web"', '"source": source_to_save', 1)

with codecs.open('functions/main.py', 'w', 'utf-8') as f:
    f.write(text)

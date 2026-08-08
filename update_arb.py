import json

def add_keys(path, new_keys):
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data.update(new_keys)
    
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=4)

es_keys = {
    "navRadar": "Radar",
    "navEquipment": "Equipo",
    "navNews": "Bitácora",
    "checklistIdentityDocumentsTitle": "Documentos de identidad",
    "checklistIdentityDocumentsDesc": "Páginas de tu pasaporte (foto, datos, fechas). Certificado de nacimiento con nombres de padres. Prueba de cambio de nombre (si aplica).",
    "checklistEducationTitle": "Educación",
    "checklistEducationDesc": "Evidencia de tus calificaciones educativas (título universitario, años cursados o equivalente, dependiendo de las exigencias para tu país).",
    "checklistEnglishLanguageTitle": "Nivel de inglés",
    "checklistEnglishLanguageDesc": "Evidencia de estudios en inglés, o examen aprobado en los últimos 12 meses (IELTS 4.5, PTE 30, Cambridge C1 147, o TOEFL iBT 32).",
    "checklistGovernmentSupportTitle": "Apoyo del Gobierno",
    "checklistGovernmentSupportDesc": "Carta de apoyo de tu gobierno (solo para ciertos países como Perú, Ecuador, etc. No requerida para España, Argentina, Chile, etc.).",
    "checklistEnoughMoneyTitle": "Fondos suficientes para tu estancia y salida",
    "checklistEnoughMoneyDesc": "Evidencia de dinero para tu estancia (normalmente $5.000 AUD) y dinero para un billete de salida de Australia (o el billete ya comprado).",
    "checklistCharacterDocumentsTitle": "Documentos de carácter (Antecedentes)",
    "checklistCharacterDocumentsDesc": "Certificados de policía de cada país donde hayas pasado 12+ meses en los últimos 10 años (desde los 16 años), y registro militar si aplica.",
    "checklistGettingHelpTitle": "Notificar si recibes ayuda (Agentes)",
    "checklistGettingHelpDesc": "Formulario 956A o 956 si usas un agente migratorio o autorizas a alguien para recibir tus documentos.",
    "checklistPrepareDocumentsTitle": "Preparar tus documentos",
    "checklistPrepareDocumentsDesc": "Traducir al inglés todos los documentos por un traductor cualificado y escanear/fotografiar todos los originales y traducciones a color."
}

en_keys = {
    "navRadar": "Radar",
    "navEquipment": "Equipment",
    "navNews": "Logbook",
    "checklistIdentityDocumentsTitle": "Identity documents",
    "checklistIdentityDocumentsDesc": "Pages of your passport (photo, data, dates). Birth certificate with parents' names. Proof of name change (if applicable).",
    "checklistEducationTitle": "Education",
    "checklistEducationDesc": "Evidence of your educational qualifications (university degree, years completed or equivalent, depending on your country's requirements).",
    "checklistEnglishLanguageTitle": "English level",
    "checklistEnglishLanguageDesc": "Evidence of English studies, or approved exam in the last 12 months (IELTS 4.5, PTE 30, Cambridge C1 147, or TOEFL iBT 32).",
    "checklistGovernmentSupportTitle": "Government support",
    "checklistGovernmentSupportDesc": "Letter of support from your government (only for certain countries like Peru, Ecuador, etc. Not required for Spain, Argentina, Chile, etc.).",
    "checklistEnoughMoneyTitle": "Enough money for your stay and departure",
    "checklistEnoughMoneyDesc": "Evidence of money for your stay (usually $5,000 AUD) and money for a departure ticket from Australia (or the ticket already purchased).",
    "checklistCharacterDocumentsTitle": "Character documents (Background checks)",
    "checklistCharacterDocumentsDesc": "Police certificates from every country where you have spent 12+ months in the last 10 years (since age 16), and military record if applicable.",
    "checklistGettingHelpTitle": "Getting help (Agents)",
    "checklistGettingHelpDesc": "Form 956A or 956 if you use a migration agent or authorize someone to receive your documents.",
    "checklistPrepareDocumentsTitle": "Prepare your documents",
    "checklistPrepareDocumentsDesc": "Translate all documents into English by a qualified translator and scan/photograph all originals and translations in color."
}

add_keys("lib/l10n/app_es.arb", es_keys)
add_keys("lib/l10n/app_en.arb", en_keys)

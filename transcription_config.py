# Configuración para la transcripción de audio
# Este archivo contiene configuraciones que puedes ajustar según tus necesidades

# Configuración de idiomas disponibles
LANGUAGES = {
    'Español (España)': 'es-ES',
    'Español (México)': 'es-MX', 
    'Español (Argentina)': 'es-AR',
    'Inglés (Estados Unidos)': 'en-US',
    'Inglés (Reino Unido)': 'en-GB',
    'Francés': 'fr-FR',
    'Italiano': 'it-IT',
    'Portugués': 'pt-PT',
    'Alemán': 'de-DE'
}

# Configuración del reconocedor
RECOGNIZER_CONFIG = {
    'energy_threshold': 300,          # Umbral de energía para detectar habla
    'dynamic_energy_threshold': True, # Ajustar automáticamente el umbral
    'pause_threshold': 0.8,           # Pausa mínima entre frases (segundos)
    'phrase_threshold': 0.3,          # Umbral mínimo para considerar una frase
    'non_speaking_duration': 0.8      # Duración de silencio para terminar grabación
}

# Configuración de segmentación
SEGMENT_CONFIG = {
    'max_duration': 300,              # Duración máxima del archivo completo (5 minutos)
    'segment_length': 30,             # Longitud de cada segmento (segundos)
    'ambient_noise_duration': 1.0     # Tiempo para ajustar ruido ambiente
}

# Configuración de servicios
SERVICE_CONFIG = {
    'primary_service': 'google',      # Servicio principal: 'google', 'wit', 'sphinx'
    'fallback_enabled': True,         # Usar métodos de respaldo si falla el principal
    'wit_ai_key': None,              # Clave API de Wit.ai (opcional)
    'timeout': 30                    # Timeout para servicios online (segundos)
}

# Configuración de salida
OUTPUT_CONFIG = {
    'include_timestamps': True,       # Incluir marcas de tiempo en segmentos
    'include_confidence': False,      # Incluir nivel de confianza (si está disponible)
    'format_paragraphs': True,        # Formatear texto en párrafos
    'encoding': 'utf-8'              # Codificación del archivo de salida
}

# Mensajes de error personalizados
ERROR_MESSAGES = {
    'no_internet': 'Sin conexión a internet. Usando reconocimiento offline.',
    'bad_request': 'Error en la solicitud. El archivo puede estar dañado o en formato no compatible.',
    'quota_exceeded': 'Se ha excedido el límite de uso del servicio de transcripción.',
    'timeout': 'Timeout en el servicio de transcripción. Intentando método alternativo.',
    'file_too_large': 'Archivo demasiado grande. Use la función de segmentación.',
    'unknown_audio': 'No se pudo entender el audio. Verifique la calidad del archivo.'
}

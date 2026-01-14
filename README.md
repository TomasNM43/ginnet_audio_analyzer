# Ginnet Audio Analyzer

Aplicación para análisis de audio con generación de espectrogramas, transcripción y detección mediante YOLO.

## Requisitos del Sistema

- Python 3.13 o superior
- Windows (configurado para PowerShell)
- FFmpeg (para procesamiento de audio - instalación opcional pero recomendada)

## Instalación

### Instalación Rápida

Ver instrucciones detalladas en **[INSTALL.md](INSTALL.md)**

### Resumen de Pasos

1. **Crear entorno virtual:**
   ```powershell
   python -m venv .venv
   .\.venv\Scripts\Activate.ps1
   ```

2. **Instalar PyTorch (IMPORTANTE - hacer PRIMERO):**
   ```powershell
   pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --extra-index-url https://download.pytorch.org/whl/cpu
   ```

3. **Instalar el resto de dependencias:**
   ```powershell
   pip install -r requirements.txt
   ```

4. **Verificar instalación:**
   ```powershell
   python -c "import PyQt5, librosa, cv2, torch, ultralytics; print('✅ OK')"
   ```

### (Opcional) Instalar FFmpeg

Para mejor compatibilidad con formatos de audio:

1. Descarga FFmpeg desde: https://ffmpeg.org/download.html
2. Extrae el archivo y agrega la carpeta `bin` a tu PATH del sistema

## Estructura del Proyecto

```
ginnet_audio_analyzer/
├── all-in-3.py              # Aplicación principal
├── requirements.txt         # Dependencias Python
├── modelos/                 # Modelos YOLO
│   ├── grayscale/          
│   │   └── best.pt         # Modelo para segmentos de 1 segundo
│   └── normal/
│       └── best.pt         # Modelo para segmentos de 3+ segundos
├── Audio/                   # Carpeta para archivos de audio
├── spectrograms/           # Espectrogramas generados (modo completo)
├── spectrograms_time_range/# Espectrogramas de rango específico
├── spectrograms_jumps/     # Espectrogramas con saltos
└── output/                 # Salidas del análisis
```

## Uso

### Ejecutar la aplicación

**⚠️ IMPORTANTE:** Debes usar el Python del entorno virtual, no el Python global del sistema.

#### Opción 1: Script de ejecución (RECOMENDADO)
```powershell
.\run.ps1
```
O doble clic en `run.bat` (Windows)

#### Opción 2: Con entorno virtual activado
```powershell
.\.venv\Scripts\Activate.ps1
python all-in-3.py
```

#### Opción 3: Directamente con Python del entorno
```powershell
.\.venv\Scripts\python.exe all-in-3.py
```

**🔧 Configurar VS Code:** Si usas VS Code y ves errores de imports, lee `VSCODE_CONFIG.md` para configurar el intérprete correcto.

### Funcionalidades principales

1. **Generar Espectrogramas**
   - Carga uno o más archivos de audio
   - Selecciona la duración de cada espectrograma (1s a 5min)
   - Genera espectrogramas en escala de grises

2. **Análisis por Rango de Tiempo**
   - Especifica tiempo inicial y final
   - Elige entre modo completo o combinado
   - Exporta a directorio separado

3. **Análisis por Saltos**
   - Define intervalos de salto personalizados
   - Ideal para archivos muy largos

4. **Transcripción de Audio**
   - Soporta múltiples idiomas (Español, Inglés, Francés, etc.)
   - Usa múltiples métodos de reconocimiento
   - Genera archivo TXT con transcripciones

5. **Análisis de Autenticidad (YOLO)**
   - Detecta posibles cortes o manipulaciones
   - Usa modelos pre-entrenados
   - Genera reportes detallados

6. **Reporte Consolidado**
   - Genera documento Word con resultados
   - Incluye gráficos y estadísticas
   - Exporta análisis completo

## Dependencias Principales

- **PyQt5**: Interfaz gráfica
- **librosa**: Procesamiento de audio
- **torch/ultralytics**: Análisis con YOLO
- **opencv-python**: Procesamiento de imágenes
- **SpeechRecognition**: Transcripción de audio
- **python-docx**: Generación de reportes Word
- **matplotlib**: Visualización de datos

## Formatos de Audio Soportados

- WAV
- MP3
- FLAC
- M4A

## Notas Importantes

1. **Modelos YOLO**: Asegúrate de que los archivos `best.pt` estén en las carpetas `modelos/grayscale/` y `modelos/normal/`

2. **Transcripción**: Requiere conexión a internet para mejores resultados (usa Google Speech Recognition API)

3. **Duración de Espectrogramas**:
   - Segmentos cortos (1-5s): Mayor precisión en detección
   - Segmentos largos (1-5min): Visión general del contexto

4. **Memoria**: El procesamiento de archivos muy largos puede requerir bastante RAM

## Solución de Problemas

### Error al importar módulos
```powershell
# Verifica que el entorno virtual esté activo
# Debe aparecer (.venv) al inicio del prompt
.\.venv\Scripts\Activate.ps1
```

### Error de FFmpeg
```powershell
# Instala FFmpeg y agrégalo al PATH del sistema
# O usa formatos WAV directamente
```

### Errores de transcripción
- Verifica tu conexión a internet
- Archivos muy largos se segmentan automáticamente
- Prueba con archivos de mejor calidad de audio

## Contacto y Soporte

Para preguntas o problemas, contacta al equipo de desarrollo de Ginnet.

## Licencia

Todos los derechos reservados © Ginnet Audio Analyzer

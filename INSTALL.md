# Instrucciones de Instalación - Ginnet Audio Analyzer

## Requisitos Previos

- **Python 3.13.5 o superior**
- **Windows 10/11**
- **PowerShell** (instalado por defecto en Windows)

## Pasos de Instalación

### 1. Crear el entorno virtual

```powershell
python -m venv .venv
```

### 2. Activar el entorno virtual

```powershell
.\.venv\Scripts\Activate.ps1
```

**NOTA:** Si obtienes un error de política de ejecución, ejecuta:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Actualizar pip (opcional pero recomendado)

```powershell
python -m pip install --upgrade pip
```

### 4. Instalar PyTorch (versión CPU para Windows)

**⚠️ IMPORTANTE:** PyTorch debe instalarse PRIMERO con este comando especial:

```powershell
pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --extra-index-url https://download.pytorch.org/whl/cpu
```

Este comando instala la versión CPU de PyTorch optimizada para Windows, evitando problemas de DLL.

### 5. Instalar el resto de dependencias

```powershell
pip install -r requirements.txt
```

**NOTA:** Si ya instalaste torch con el comando anterior, pip detectará que ya está instalado y omitirá esa dependencia.

## Verificación de la Instalación

Para verificar que todo se instaló correctamente:

```powershell
python -c "import PyQt5, librosa, cv2, torch, ultralytics, speech_recognition; print('✅ Todas las librerías instaladas correctamente')"
```

## Ejecutar la Aplicación

Una vez instalado todo:

```powershell
python all-in-3.py
```

## Solución de Problemas Comunes

### Error: "torch DLL load failed"

**Solución:**
```powershell
pip uninstall torch torchvision -y
pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --extra-index-url https://download.pytorch.org/whl/cpu
```

### Error: "numpy.core.multiarray failed to import"

**Solución:**
```powershell
pip uninstall opencv-python -y
pip install opencv-python==4.12.0.88
```

### Error: "No module named 'PyQt5'"

**Solución:**
```powershell
pip install PyQt5==5.15.10
```

### La ventana no se abre

Verifica que el entorno virtual esté activo (debe aparecer `(.venv)` al inicio del prompt):
```powershell
.\.venv\Scripts\Activate.ps1
```

## Instalación Alternativa (Un Solo Comando)

Si prefieres instalar todo de una vez (puede tomar más tiempo):

```powershell
# Crear y activar entorno
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Instalar todo incluyendo PyTorch CPU
pip install torch==2.6.0+cpu torchvision==0.21.0+cpu --extra-index-url https://download.pytorch.org/whl/cpu
pip install -r requirements.txt
```

## Desactivar el Entorno Virtual

Cuando termines de usar la aplicación:

```powershell
deactivate
```

## Nota sobre FFmpeg (Opcional)

Para mejor compatibilidad con formatos de audio (MP3, M4A, etc.), instala FFmpeg:

1. Descarga desde: https://ffmpeg.org/download.html
2. Extrae el archivo
3. Agrega la carpeta `bin` a tu PATH del sistema

Sin FFmpeg, la aplicación solo podrá procesar archivos WAV nativamente.

## Estructura de Archivos Requeridos

Asegúrate de que estos archivos/carpetas existan:

```
ginnet_audio_analyzer/
├── all-in-3.py          ← Archivo principal
├── requirements.txt     ← Este archivo
├── modelos/
│   ├── grayscale/
│   │   └── best.pt     ← Modelo YOLO para 1 seg
│   └── normal/
│       └── best.pt     ← Modelo YOLO para 3+ seg
```

Los modelos YOLO (`best.pt`) deben estar presentes para que el análisis de autenticidad funcione.

## Versiones Confirmadas que Funcionan

- Python: 3.13.5
- PyTorch: 2.6.0+cpu
- OpenCV: 4.12.0.88
- NumPy: 2.2.6
- Librosa: 0.10.1
- PyQt5: 5.15.10
- Ultralytics: 8.3.234

---

**¿Problemas? Verifica:**
1. ✓ Python 3.13+ instalado
2. ✓ Entorno virtual activado (`.venv`)
3. ✓ PyTorch CPU instalado correctamente
4. ✓ Todas las dependencias instaladas sin errores
5. ✓ Modelos YOLO en carpeta `modelos/`

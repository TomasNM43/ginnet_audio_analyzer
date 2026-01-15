# Guía para Crear el Ejecutable de Ginnet Audio Analyzer

## Requisitos Previos

1. Python 3.13 o superior instalado
2. Entorno virtual activado
3. Todas las dependencias instaladas según `requirements.txt`

## Pasos para Generar el Ejecutable

### 1. Instalar PyInstaller

Activar el entorno virtual y ejecutar:

```powershell
.\.venv\Scripts\Activate.ps1
pip install pyinstaller
```

### 2. Crear el Ejecutable

**OPCIÓN A - Un solo archivo (más lento, puede dar errores de DLL):**
```powershell
.\.venv\Scripts\pyinstaller --onefile --windowed --name "GinnetAudioAnalyzer" --add-data "modelos;modelos" --hidden-import=sklearn.utils._typedefs --hidden-import=sklearn.utils._heap --hidden-import=sklearn.utils._sorting --hidden-import=sklearn.utils._vector_sentinel --hidden-import=sklearn.neighbors._partition_nodes --collect-all torch --collect-all torchvision --collect-all ultralytics --collect-all librosa all-in-3.py
```

**OPCIÓN B - Carpeta con archivos (RECOMENDADO - funciona mejor con PyTorch):**
```powershell
.\.venv\Scripts\pyinstaller --onedir --windowed --name "GinnetAudioAnalyzer" --add-data "modelos;modelos" --hidden-import=sklearn.utils._typedefs --hidden-import=sklearn.utils._heap --hidden-import=sklearn.utils._sorting --hidden-import=sklearn.utils._vector_sentinel --hidden-import=sklearn.neighbors._partition_nodes --collect-all torch --collect-all torchvision --collect-all ultralytics --collect-all librosa all-in-3.py
```

### 3. Resultado

**Con --onefile (Opción A):**
```
dist/GinnetAudioAnalyzer.exe (archivo único)
```

**Con --onedir (Opción B - RECOMENDADO):**
```
dist/GinnetAudioAnalyzer/
  ├── GinnetAudioAnalyzer.exe (ejecutable principal)
  ├── _internal/ (librerías y dependencias)
  └── modelos/ (modelos YOLO)
```

## Explicación de los Parámetros

- `--onefile`: Crea un único archivo ejecutable (más fácil de distribuir)
- `--windowed`: No muestra la consola de comandos al ejecutar (aplicación GUI)
- `--name "GinnetAudioAnalyzer"`: Nombre del ejecutable
- `--add-data "modelos;modelos"`: Incluye la carpeta de modelos YOLO en el ejecutable
- `--hidden-import=...`: Incluye módulos de sklearn que PyInstaller no detecta automáticamente
- `--collect-all torch`: Incluye todos los archivos de PyTorch
- `--collect-all torchvision`: Incluye todos los archivos de TorchVision
- `--collect-all ultralytics`: Incluye todos los archivos de YOLO (Ultralytics)
- `--collect-all librosa`: Incluye todos los archivos de Librosa para procesamiento de audio

## Archivos Generados

Durante el proceso se crean:

- **build/**: Archivos temporales de compilación (se pueden eliminar después)
- **dist/**: Carpeta con el ejecutable final
- **GinnetAudioAnalyzer.spec**: Archivo de configuración de PyInstaller (útil para futuras compilaciones)

## Limpieza Después de Compilar (Opcional)

Para limpiar archivos temporales:

```powershell
Remove-Item -Path "build" -Recurse -Force
```

## Notas Importantes

1. **Tamaño del Ejecutable**: 
   - `--onefile`: ~570MB (archivo único)
   - `--onedir`: ~1.2GB (carpeta completa, pero inicia más rápido)

2. **Modelos YOLO**: Asegúrate de que la carpeta `modelos/` contiene:
   - `modelos/grayscale/best.pt`
   - `modelos/normal/best.pt`

3. **Antivirus**: Algunos antivirus pueden marcar el ejecutable como sospechoso. Esto es común con PyInstaller.

4. **Primera Ejecución**: 
   - `--onefile`: Tarda más (descomprime en temp)
   - `--onedir`: Inicia más rápido

5. **Base deOSError: Error loading DLL" o "WinError 1114"
**Problema**: Falta Visual C++ Redistributables o PyTorch no se empaquetó bien.

**Soluciones**:
1. **En la PC de destino**, instala: [Visual C++ Redistributables](https://aka.ms/vs/17/release/vc_redist.x64.exe)
2. Usa `--onedir` en lugar de `--onefile` (más compatible)
3. Si persiste, agrega `--noupx` al comando de PyInstaller

### Error: "No module named..."
- Verifica que todas las dependencias estén instaladas en el entorno virtual
- Agrega el módulo faltante con `--hidden-import=nombre_modulo`

### Ejecutable no inicia
- Prueba ejecutarlo desde la terminal para ver los errores:
  ```powershell
  .\dist\GinnetAudioAnalyzer
### Error: "No module named..."
- Verifica que todas las dependencias estén instaladas en el entorno virtual
- Agrega el módulo faltante con `--hidden-import=nombre_modulo`

### Ejecutable no inicia
- Prueba ejecutarlo desde la terminal para ver los errores:
  ```powershell
**Con --onefile:**
1. Distribuye el archivo `dist/GinnetAudioAnalyzer.exe`

**Con --onedir (RECOMENDADO):**
1. Comprime toda la carpeta `dist/GinnetAudioAnalyzer/`
2. El usuario debe extraer y ejecutar `GinnetAudioAnalyzer.exe`

**Requisitos para el usuario final:**
1. Windows 10/11 (64-bit)
2. [Visual C++ Redistributables](https://aka.ms/vs/17/release/vc_redist.x64.exe)
3. MySQL instalado y configurado
4. No necesita Python instalado

Para distribuir la aplicación:

1. Comprime la carpeta `dist/` completa
2. Incluye instrucciones para:
   - Instalación de MySQL si es necesario
  **USA `--onedir`** (Opción B) para mejor compatibilidad con PyTorch
- Prueba el ejecutable en un sistema limpio (sin Python) antes de distribuir
- Mantén una copia del archivo `.spec` para regenerar el ejecutable más rápido
- Si el ejecutable da errores de DLL, asegúrate de que la PC tenga Visual C++ Redistributables
- `--onedir` es más grande pero más rápido y confiable que `--onefile`
## Recomendaciones

- Prueba el ejecutable en un sistema limpio (sin Python) antes de distribuir
- Mantén una copia del archivo `.spec` para regenerar el ejecutable más rápido
- Considera usar `--onedir` en lugar de `--onefile` para aplicaciones grandes (carga más rápida)

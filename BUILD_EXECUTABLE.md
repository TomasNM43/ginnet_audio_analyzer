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
.\.venv\Scripts\pyinstaller --onedir --windowed --noupx --name "GinnetAudioAnalyzer" --add-data "modelos;modelos" --hidden-import=sklearn.utils._typedefs --hidden-import=sklearn.utils._heap --hidden-import=sklearn.utils._sorting --hidden-import=sklearn.utils._vector_sentinel --hidden-import=sklearn.neighbors._partition_nodes --collect-all torch --collect-all torchvision --collect-all ultralytics --collect-all librosa all-in-3.py
```

**NOTA:** El flag `--noupx` evita la compresión UPX que puede corromper las DLLs de PyTorch.

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

## Solución de Problemas

### Error: "OSError: [WinError 1114] Error loading c10.dll" o "DLL load failed"

**Problema**: PyTorch no puede cargar sus DLLs nativas. Muy común con `--onefile`.

**Soluciones (en orden de prioridad):**

1. **Regenerar con `--noupx`:**
   ```powershell
   # Agregar flag --noupx al comando
   .\.venv\Scripts\pyinstaller --onedir --windowed --noupx --name "GinnetAudioAnalyzer" ...
   ```

2. **En la PC de destino, instalar TODAS las versiones de Visual C++ Redistributables:**
   
   **Método Automático (PowerShell como Admin):**
   ```powershell
   # Visual C++ 2013 x64
   Invoke-WebRequest -Uri "https://aka.ms/highdpimfc2013x64enu" -OutFile "$env:TEMP\vcredist2013_x64.exe"
   Start-Process "$env:TEMP\vcredist2013_x64.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
   
   # Visual C++ 2015-2022 x64
   Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$env:TEMP\vc_redist.x64.exe"
   Start-Process "$env:TEMP\vc_redist.x64.exe" -ArgumentList "/install", "/quiet", "/norestart" -Wait
   
   # REINICIAR LA PC después de instalar
   ```
   
   **Método Manual:**
   - VC++ 2013: https://aka.ms/highdpimfc2013x64enu
   - VC++ 2015-2022: https://aka.ms/vs/17/release/vc_redist.x64.exe
   - **IMPORTANTE:** Reiniciar la PC después de instalar

3. **Verificar que se copió TODA la carpeta `dist/GinnetAudioAnalyzer/`:**
   ```
   GinnetAudioAnalyzer/
   ├── GinnetAudioAnalyzer.exe
   ├── _internal/           ← DEBE existir
   │   ├── torch/
   │   │   └── lib/
   │   │       └── c10.dll  ← Debe estar aquí
   │   └── ...
   └── modelos/
   ```

4. **Usar `--onedir` en lugar de `--onefile`** (la Opción B es más compatible)

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
2. **Visual C++ Redistributables 2013 y 2015-2022** (ambos son necesarios)
   - VC++ 2013: https://aka.ms/highdpimfc2013x64enu
   - VC++ 2015-2022: https://aka.ms/vs/17/release/vc_redist.x64.exe
3. MySQL instalado y configurado (si usa base de datos)
4. No necesita Python instalado

**IMPORTANTE:** Después de instalar los VC++ Redistributables, REINICIAR la PC.

## Distribución

## Distribución

**Pasos para distribuir:**

1. Comprime **TODA** la carpeta `dist/GinnetAudioAnalyzer/` (no solo el .exe)

2. Incluye un archivo README.txt con:
   ```
   INSTRUCCIONES DE INSTALACIÓN:
   
   1. Instalar Visual C++ 2013:
      https://aka.ms/highdpimfc2013x64enu
      
   2. Instalar Visual C++ 2015-2022:
      https://aka.ms/vs/17/release/vc_redist.x64.exe
      
   3. REINICIAR LA PC
   
   4. Ejecutar GinnetAudioAnalyzer.exe
   
   Si MySQL no está instalado, descargarlo de:
   https://dev.mysql.com/downloads/installer/
   ```

3. El ZIP final debe contener:
   - Carpeta `GinnetAudioAnalyzer/` completa
   - README.txt con instrucciones
   - (Opcional) Los instaladores de VC++ incluidos

## Recomendaciones

- **SIEMPRE usa `--onedir --noupx`** para PyTorch (evita errores de DLL)

- Prueba el ejecutable en un sistema limpio (sin Python) antes de distribuir
- Mantén una copia del archivo `.spec` para regenerar el ejecutable más rápido
- Considera usar `--onedir` en lugar de `--onefile` para aplicaciones grandes (carga más rápida)

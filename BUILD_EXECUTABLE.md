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

Ejecutar el siguiente comando desde la raíz del proyecto:

```powershell
.\.venv\Scripts\pyinstaller --onefile --windowed --name "GinnetAudioAnalyzer" --add-data "modelos;modelos" --hidden-import=sklearn.utils._typedefs --hidden-import=sklearn.utils._heap --hidden-import=sklearn.utils._sorting --hidden-import=sklearn.utils._vector_sentinel --hidden-import=sklearn.neighbors._partition_nodes --collect-all torch --collect-all torchvision --collect-all ultralytics --collect-all librosa all-in-3.py
```

### 3. Resultado

El ejecutable se generará en:
```
dist/GinnetAudioAnalyzer.exe
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

1. **Tamaño del Ejecutable**: El archivo será grande (~500MB - 1GB) debido a las librerías de machine learning incluidas (PyTorch, YOLO, etc.)

2. **Modelos YOLO**: Asegúrate de que la carpeta `modelos/` contiene:
   - `modelos/grayscale/best.pt`
   - `modelos/normal/best.pt`

3. **Antivirus**: Algunos antivirus pueden marcar el ejecutable como sospechoso. Esto es común con PyInstaller.

4. **Primera Ejecución**: La primera vez puede tardar un poco más en iniciar mientras descomprime los recursos.

5. **Base de Datos MySQL**: El ejecutable requiere que MySQL esté instalado y accesible en el sistema donde se ejecute.

## Solución de Problemas

### Error: "No module named..."
- Verifica que todas las dependencias estén instaladas en el entorno virtual
- Agrega el módulo faltante con `--hidden-import=nombre_modulo`

### Ejecutable no inicia
- Prueba ejecutarlo desde la terminal para ver los errores:
  ```powershell
  .\dist\GinnetAudioAnalyzer.exe
  ```

### Falta archivo o recurso
- Usa `--add-data "origen;destino"` para incluir archivos adicionales

## Distribución

Para distribuir la aplicación:

1. Comprime la carpeta `dist/` completa
2. Incluye instrucciones para:
   - Instalación de MySQL si es necesario
   - Configuración de la base de datos
   - Requisitos del sistema (Windows 10/11)

## Recomendaciones

- Prueba el ejecutable en un sistema limpio (sin Python) antes de distribuir
- Mantén una copia del archivo `.spec` para regenerar el ejecutable más rápido
- Considera usar `--onedir` en lugar de `--onefile` para aplicaciones grandes (carga más rápida)

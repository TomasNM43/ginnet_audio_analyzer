# Script para Preparar Paquete de Distribución
# Crea un ZIP con todo lo necesario para distribuir

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Preparar Paquete de Distribución" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que existe el ejecutable
if (-not (Test-Path ".\dist\GinnetAudioAnalyzer")) {
    Write-Host "❌ Error: No se encontró dist\GinnetAudioAnalyzer\" -ForegroundColor Red
    Write-Host "   Primero debes compilar el ejecutable con PyInstaller" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit
}

# Crear carpeta temporal para el paquete
$packageDir = ".\GinnetAudioAnalyzer-Paquete"
if (Test-Path $packageDir) {
    Write-Host "🧹 Limpiando paquete anterior..." -ForegroundColor Yellow
    Remove-Item -Path $packageDir -Recurse -Force
}

Write-Host "📁 Creando estructura del paquete..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null
New-Item -ItemType Directory -Path "$packageDir\instaladores" -Force | Out-Null

# Copiar ejecutable
Write-Host "📦 Copiando GinnetAudioAnalyzer..." -ForegroundColor Cyan
Copy-Item -Path ".\dist\GinnetAudioAnalyzer" -Destination $packageDir -Recurse -Force

# Copiar archivos de instalación
Write-Host "📄 Copiando archivos de instalación..." -ForegroundColor Cyan
Copy-Item -Path ".\InstalarDependencias.ps1" -Destination $packageDir -Force
Copy-Item -Path ".\LEEME.txt" -Destination $packageDir -Force

# Descargar instaladores de Visual C++
Write-Host "⬇ Descargando instaladores de Visual C++..." -ForegroundColor Cyan

Write-Host "   → Visual C++ 2013 x64..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri "https://aka.ms/highdpimfc2013x64enu" -OutFile "$packageDir\instaladores\vcredist2013_x64.exe" -UseBasicParsing
    Write-Host "   ✓ Descargado" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ No se pudo descargar (opcional)" -ForegroundColor Yellow
}

Write-Host "   → Visual C++ 2015-2022 x64..." -ForegroundColor Gray
try {
    Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile "$packageDir\instaladores\vc_redist.x64.exe" -UseBasicParsing
    Write-Host "   ✓ Descargado" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ No se pudo descargar (opcional)" -ForegroundColor Yellow
}

# Crear archivo de versión
$versionFile = @"
GINNET AUDIO ANALYZER
Versión: 1.0
Fecha de compilación: $(Get-Date -Format "dd/MM/yyyy HH:mm")
Compilado en: $env:COMPUTERNAME

CONTENIDO DEL PAQUETE:
- GinnetAudioAnalyzer/ (ejecutable y dependencias)
- InstalarDependencias.ps1 (instalador automático)
- LEEME.txt (instrucciones)
- instaladores/ (Visual C++ Redistributables)
"@

$versionFile | Out-File -FilePath "$packageDir\VERSION.txt" -Encoding UTF8

# Crear ZIP
$zipName = "GinnetAudioAnalyzer-$(Get-Date -Format 'yyyyMMdd-HHmm').zip"
Write-Host ""
Write-Host "🗜️  Creando archivo ZIP..." -ForegroundColor Cyan
Compress-Archive -Path $packageDir -DestinationPath ".\$zipName" -Force

# Mostrar tamaño
$zipSize = (Get-Item ".\$zipName").Length / 1MB
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ Paquete creado exitosamente" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Archivo: $zipName" -ForegroundColor Cyan
Write-Host "📊 Tamaño: $($zipSize.ToString('F2')) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "📂 Contenido:" -ForegroundColor Yellow
Get-ChildItem -Path $packageDir -Recurse | ForEach-Object {
    $relativePath = $_.FullName.Replace($packageDir, "").TrimStart("\")
    if ($_.PSIsContainer) {
        Write-Host "   📁 $relativePath" -ForegroundColor Gray
    } else {
        $size = ($_.Length / 1KB).ToString('F0')
        Write-Host "   📄 $relativePath ($size KB)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "✅ Listo para distribuir: $zipName" -ForegroundColor Green
Write-Host ""
Write-Host "Los usuarios solo necesitan:" -ForegroundColor Yellow
Write-Host "  1. Extraer el ZIP" -ForegroundColor White
Write-Host "  2. Ejecutar InstalarDependencias.ps1" -ForegroundColor White
Write-Host "  3. Reiniciar la PC" -ForegroundColor White
Write-Host "  4. Ejecutar GinnetAudioAnalyzer.exe" -ForegroundColor White
Write-Host ""

# Preguntar si eliminar carpeta temporal
$cleanup = Read-Host "¿Eliminar carpeta temporal '$packageDir'? (S/N)"
if ($cleanup -eq "S" -or $cleanup -eq "s") {
    Remove-Item -Path $packageDir -Recurse -Force
    Write-Host "🧹 Carpeta temporal eliminada" -ForegroundColor Green
}

Write-Host ""
Read-Host "Presiona Enter para salir"

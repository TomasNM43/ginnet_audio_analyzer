# Script para Corregir DLLs de PyTorch en el Ejecutable
# Ejecutar DESPUÉS de crear el ejecutable con PyInstaller

Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Corrector de DLLs de PyTorch" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$distPath = ".\dist\GinnetAudioAnalyzer"
$torchLibPath = "$distPath\_internal\torch\lib"

if (-not (Test-Path $distPath)) {
    Write-Host "[ERROR] No se encuentra la carpeta dist/GinnetAudioAnalyzer" -ForegroundColor Red
    Write-Host "Primero genera el ejecutable con PyInstaller" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "[1/4] Verificando carpeta de PyTorch..." -ForegroundColor Yellow
if (Test-Path $torchLibPath) {
    Write-Host "[OK] Carpeta encontrada: $torchLibPath" -ForegroundColor Green
} else {
    Write-Host "[ERROR] No se encuentra $torchLibPath" -ForegroundColor Red
    pause
    exit
}

Write-Host ""
Write-Host "[2/4] Buscando DLLs necesarias del sistema..." -ForegroundColor Yellow

# DLLs de Visual C++ que PyTorch necesita
$systemDlls = @(
    "msvcp140.dll",
    "vcruntime140.dll", 
    "vcruntime140_1.dll"
)

$windowsSystem = "$env:SystemRoot\System32"
$copiedDlls = 0

foreach ($dll in $systemDlls) {
    $sourcePath = "$windowsSystem\$dll"
    $destPath = "$torchLibPath\$dll"
    
    if (Test-Path $sourcePath) {
        if (-not (Test-Path $destPath)) {
            try {
                Copy-Item $sourcePath $destPath -Force
                Write-Host "  [COPIADO] $dll -> $torchLibPath" -ForegroundColor Green
                $copiedDlls++
            } catch {
                Write-Host "  [ERROR] No se pudo copiar $dll" -ForegroundColor Red
            }
        } else {
            Write-Host "  [OK] $dll ya existe" -ForegroundColor Gray
        }
    } else {
        Write-Host "  [AVISO] $dll no encontrada en System32" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "[3/4] Copiando DLLs adicionales de torch..." -ForegroundColor Yellow

# Copiar todas las DLLs de torch al directorio principal _internal
$torchDlls = Get-ChildItem -Path "$torchLibPath\*.dll" -ErrorAction SilentlyContinue

if ($torchDlls) {
    foreach ($dll in $torchDlls) {
        $destPath = "$distPath\_internal\$($dll.Name)"
        if (-not (Test-Path $destPath)) {
            try {
                Copy-Item $dll.FullName $destPath -Force
                Write-Host "  [COPIADO] $($dll.Name) -> _internal\" -ForegroundColor Green
            } catch {
                # Silencioso si ya existe
            }
        }
    }
}

Write-Host ""
Write-Host "[4/4] Creando archivo de configuración..." -ForegroundColor Yellow

# Crear un archivo de configuración que indique las rutas de las DLLs
$configContent = @"
# Configuración de DLLs para GinnetAudioAnalyzer
# Generado automáticamente

DLLs copiadas: $copiedDlls
Fecha: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

Si el ejecutable sigue sin funcionar en otra PC:
1. Instalar Visual C++ 2013: https://aka.ms/highdpimfc2013x64enu
2. Instalar Visual C++ 2015-2022: https://aka.ms/vs/17/release/vc_redist.x64.exe
3. Reiniciar la PC
"@

$configContent | Out-File "$distPath\LEEME-DLL.txt" -Encoding UTF8

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host " Proceso Completado" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "DLLs copiadas: $copiedDlls" -ForegroundColor Cyan
Write-Host ""
Write-Host "Ahora prueba el ejecutable:" -ForegroundColor Yellow
Write-Host "  $distPath\GinnetAudioAnalyzer.exe" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si sigue sin funcionar, la PC de destino necesita:" -ForegroundColor Yellow
Write-Host "  1. Visual C++ 2013" -ForegroundColor White
Write-Host "  2. Visual C++ 2015-2022" -ForegroundColor White
Write-Host "  3. Reiniciar después de instalar" -ForegroundColor White
Write-Host ""

pause

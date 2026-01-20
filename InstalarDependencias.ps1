# Script de Instalación Automática de Dependencias
# Para GinnetAudioAnalyzer

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Ginnet Audio Analyzer - Instalador" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "⚠️  Este script necesita permisos de administrador." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Relanzando con privilegios de administrador..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "✓ Ejecutando con permisos de administrador" -ForegroundColor Green
Write-Host ""

# Crear carpeta temporal
$tempDir = "$env:TEMP\GinnetInstaller"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Función para verificar si ya está instalado
function Test-VCRedistInstalled {
    param([string]$DisplayName)
    
    $installed = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
                 Where-Object { $_.DisplayName -like "*$DisplayName*" }
    
    if (-not $installed) {
        $installed = Get-ItemProperty "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
                     Where-Object { $_.DisplayName -like "*$DisplayName*" }
    }
    
    return $null -ne $installed
}

# Instalar Visual C++ 2013 x64
Write-Host "Verificando Visual C++ 2013 x64..." -ForegroundColor Cyan
if (Test-VCRedistInstalled "Visual C++ 2013") {
    Write-Host "✓ Visual C++ 2013 ya está instalado" -ForegroundColor Green
} else {
    Write-Host "⬇ Descargando Visual C++ 2013 x64..." -ForegroundColor Yellow
    $vc2013Path = "$tempDir\vcredist2013_x64.exe"
    try {
        Invoke-WebRequest -Uri "https://aka.ms/highdpimfc2013x64enu" -OutFile $vc2013Path -UseBasicParsing
        Write-Host "📦 Instalando Visual C++ 2013 x64..." -ForegroundColor Yellow
        Start-Process -FilePath $vc2013Path -ArgumentList "/install", "/quiet", "/norestart" -Wait
        Write-Host "✓ Visual C++ 2013 instalado correctamente" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al instalar Visual C++ 2013: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Instalar Visual C++ 2015-2022 x64
Write-Host "Verificando Visual C++ 2015-2022 x64..." -ForegroundColor Cyan
if (Test-VCRedistInstalled "Visual C++ 2015-2022" -or Test-VCRedistInstalled "Visual C++ 2022") {
    Write-Host "✓ Visual C++ 2015-2022 ya está instalado" -ForegroundColor Green
} else {
    Write-Host "⬇ Descargando Visual C++ 2015-2022 x64..." -ForegroundColor Yellow
    $vc2022Path = "$tempDir\vc_redist.x64.exe"
    try {
        Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vc_redist.x64.exe" -OutFile $vc2022Path -UseBasicParsing
        Write-Host "📦 Instalando Visual C++ 2015-2022 x64..." -ForegroundColor Yellow
        Start-Process -FilePath $vc2022Path -ArgumentList "/install", "/quiet", "/norestart" -Wait
        Write-Host "✓ Visual C++ 2015-2022 instalado correctamente" -ForegroundColor Green
    } catch {
        Write-Host "❌ Error al instalar Visual C++ 2015-2022: $_" -ForegroundColor Red
    }
}
Write-Host ""

# Limpiar archivos temporales
Write-Host "🧹 Limpiando archivos temporales..." -ForegroundColor Cyan
Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  ✓ Instalación completada" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Es necesario REINICIAR la PC" -ForegroundColor Yellow
Write-Host "para que los cambios tengan efecto." -ForegroundColor Yellow
Write-Host ""

$restart = Read-Host "¿Deseas reiniciar ahora? (S/N)"
if ($restart -eq "S" -or $restart -eq "s") {
    Write-Host "Reiniciando en 10 segundos..." -ForegroundColor Yellow
    Start-Sleep -Seconds 10
    Restart-Computer -Force
} else {
    Write-Host ""
    Write-Host "Recuerda reiniciar antes de usar GinnetAudioAnalyzer" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Presiona cualquier tecla para salir..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ═══════════════════════════════════════════════════════════════
#  GINNET AUDIO ANALYZER - INSTALADOR AUTOMÁTICO
#  Instala todo y ejecuta el programa automáticamente
# ═══════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         GINNET AUDIO ANALYZER - INSTALACIÓN              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "🔒 Solicitando permisos de administrador..." -ForegroundColor Yellow
    Write-Host ""
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Write-Host "✓ Permisos de administrador obtenidos" -ForegroundColor Green
Write-Host ""

# Obtener la ruta del script
$scriptPath = Split-Path -Parent $PSCommandPath
$appPath = Join-Path $scriptPath "GinnetAudioAnalyzer"
$exePath = Join-Path $appPath "GinnetAudioAnalyzer.exe"

# Verificar que existe el ejecutable
if (-not (Test-Path $exePath)) {
    Write-Host "❌ Error: No se encontró GinnetAudioAnalyzer.exe" -ForegroundColor Red
    Write-Host "   Ubicación esperada: $exePath" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit
}

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

# Crear acceso directo en el escritorio
Write-Host ""
Write-Host "🔗 Creando acceso directo en el escritorio..." -ForegroundColor Cyan
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcutPath = Join-Path $desktopPath "Ginnet Audio Analyzer.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $exePath
$Shortcut.WorkingDirectory = $appPath
$Shortcut.Description = "Ginnet Audio Analyzer"
$Shortcut.Save()

Write-Host "✓ Acceso directo creado en el escritorio" -ForegroundColor Green

# Crear script de auto-inicio después del reinicio
$startupScript = @"
Start-Sleep -Seconds 5
Start-Process "$exePath"
Remove-Item -Path "`$PSCommandPath" -Force
"@

$startupScriptPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\GinnetAutoStart.ps1"
$startupScript | Out-File -FilePath $startupScriptPath -Encoding UTF8

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║           ✓ INSTALACIÓN COMPLETADA                       ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "📍 Acceso directo creado en el escritorio" -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Es necesario REINICIAR para completar la instalación" -ForegroundColor Yellow
Write-Host "   El programa se ejecutará automáticamente después del reinicio" -ForegroundColor Yellow
Write-Host ""

$restart = Read-Host "¿Reiniciar ahora? (S/N)"
if ($restart -eq "S" -or $restart -eq "s") {
    Write-Host ""
    Write-Host "🔄 Reiniciando en 5 segundos..." -ForegroundColor Yellow
    Write-Host "   (El programa se abrirá automáticamente)" -ForegroundColor Cyan
    Start-Sleep -Seconds 5
    Restart-Computer -Force
} else {
    # Eliminar script de auto-inicio si no reinicia ahora
    Remove-Item -Path $startupScriptPath -Force -ErrorAction SilentlyContinue
    
    Write-Host ""
    Write-Host "⚠️  Recuerda REINICIAR antes de usar el programa" -ForegroundColor Yellow
    Write-Host "   Después del reinicio, usa el acceso directo del escritorio" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Presiona Enter para salir"
}

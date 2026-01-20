# ==================================================================
#  COPIAR DLLs DE SYSTEM32 AL EJECUTABLE (WORKAROUND)
#  Usa esto si los VC++ Redistributables no funcionan
# ==================================================================

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "     COPIAR DLLs AL EJECUTABLE (WORKAROUND)" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar privilegios de administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "[AVISO] Se recomienda ejecutar como Administrador" -ForegroundColor Yellow
    Write-Host ""
}

# Encontrar la carpeta _internal
$internalPath = ".\dist\GinnetAudioAnalyzer\_internal"
if (-not (Test-Path $internalPath)) {
    Write-Host "[ERROR] No se encuentra dist\GinnetAudioAnalyzer\_internal\" -ForegroundColor Red
    Write-Host "        Ejecuta este script desde la carpeta del proyecto" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit
}

Write-Host "[*] Copiando DLLs de Visual C++ al ejecutable..." -ForegroundColor Yellow
Write-Host ""

# DLLs a copiar
$dllsToCopy = @(
    "msvcp120.dll",
    "msvcr120.dll",
    "msvcp140.dll",
    "vcruntime140.dll",
    "vcruntime140_1.dll"
)

$copied = 0
$failed = 0

foreach ($dll in $dllsToCopy) {
    $sourcePath = "$env:SystemRoot\System32\$dll"
    $destPath = Join-Path $internalPath $dll
    
    if (Test-Path $sourcePath) {
        try {
            Copy-Item -Path $sourcePath -Destination $destPath -Force
            Write-Host "  [OK] Copiado: $dll" -ForegroundColor Green
            $copied++
        } catch {
            Write-Host "  [ERROR] No se pudo copiar: $dll - $_" -ForegroundColor Red
            $failed++
        }
    } else {
        Write-Host "  [FALTA] No existe en System32: $dll" -ForegroundColor Yellow
        $failed++
    }
}

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Copiadas: $copied DLLs" -ForegroundColor Green
Write-Host "  Fallidas: $failed DLLs" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "Gray" })
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

if ($copied -gt 0) {
    Write-Host "[OK] Ahora intenta ejecutar GinnetAudioAnalyzer.exe" -ForegroundColor Green
    Write-Host "     Si funciona, distribuye TODA la carpeta dist\GinnetAudioAnalyzer\" -ForegroundColor Cyan
} else {
    Write-Host "[ERROR] No se copiaron DLLs. Instala Visual C++ Redistributables:" -ForegroundColor Red
    Write-Host "        VC++ 2013: https://aka.ms/highdpimfc2013x64enu" -ForegroundColor Yellow
    Write-Host "        VC++ 2015-2022: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para salir"

# Script para ejecutar Ginnet Audio Analyzer
# Doble clic en este archivo para ejecutar la aplicación

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Ginnet Audio Analyzer" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Verificar que existe el entorno virtual
if (-not (Test-Path ".venv\Scripts\python.exe")) {
    Write-Host "ERROR: No se encontró el entorno virtual" -ForegroundColor Red
    Write-Host "Por favor ejecuta primero: .\setup.ps1" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit 1
}

Write-Host "Iniciando aplicación con entorno virtual...`n" -ForegroundColor Green

# Ejecutar con el Python del entorno virtual
& .\.venv\Scripts\python.exe all-in-3.py

Write-Host "`nAplicación cerrada." -ForegroundColor Gray
Write-Host "Presiona cualquier tecla para salir..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

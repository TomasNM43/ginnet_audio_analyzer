# ═══════════════════════════════════════════════════════════════
#  VERIFICADOR DE DEPENDENCIAS - GINNET AUDIO ANALYZER
# ═══════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         VERIFICACIÓN DE DEPENDENCIAS DEL SISTEMA         ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$allOk = $true

# ═══════════════════════════════════════════════════════════════
# 1. VERIFICAR VISUAL C++ REDISTRIBUTABLES
# ═══════════════════════════════════════════════════════════════

Write-Host "🔍 Verificando Visual C++ Redistributables..." -ForegroundColor Yellow
Write-Host ""

# VC++ 2013
$vc2013 = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*", 
                            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
          Where-Object { $_.DisplayName -like "*Visual C++ 2013*x64*" }

if ($vc2013) {
    Write-Host "  ✅ Visual C++ 2013 x64:" -ForegroundColor Green -NoNewline
    Write-Host " $($vc2013.DisplayVersion)" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Visual C++ 2013 x64: NO INSTALADO" -ForegroundColor Red
    Write-Host "     Descargar: https://aka.ms/highdpimfc2013x64enu" -ForegroundColor Yellow
    $allOk = $false
}

# VC++ 2015-2022
$vc2022 = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                            "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | 
          Where-Object { $_.DisplayName -like "*Visual C++ 2015-2022*x64*" -or $_.DisplayName -like "*Visual C++ 2022*x64*" }

if ($vc2022) {
    Write-Host "  ✅ Visual C++ 2015-2022 x64:" -ForegroundColor Green -NoNewline
    Write-Host " $($vc2022.DisplayVersion)" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Visual C++ 2015-2022 x64: NO INSTALADO" -ForegroundColor Red
    Write-Host "     Descargar: https://aka.ms/vs/17/release/vc_redist.x64.exe" -ForegroundColor Yellow
    $allOk = $false
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════
# 2. VERIFICAR EJECUTABLE Y DLLs DE PYTORCH
# ═══════════════════════════════════════════════════════════════

Write-Host "🔍 Verificando ejecutable empaquetado..." -ForegroundColor Yellow
Write-Host ""

$distPath = ".\dist\GinnetAudioAnalyzer"
$exePath = "$distPath\GinnetAudioAnalyzer.exe"
$internalPath = "$distPath\_internal"

if (Test-Path $exePath) {
    Write-Host "  ✅ Ejecutable encontrado: GinnetAudioAnalyzer.exe" -ForegroundColor Green
    $exeSize = (Get-Item $exePath).Length / 1MB
    Write-Host "     Tamaño: $($exeSize.ToString('F2')) MB" -ForegroundColor Gray
} else {
    Write-Host "  ❌ Ejecutable NO encontrado" -ForegroundColor Red
    Write-Host "     Ejecuta: pyinstaller --onedir --windowed ..." -ForegroundColor Yellow
    $allOk = $false
}

if (Test-Path $internalPath) {
    Write-Host "  ✅ Carpeta _internal/ encontrada" -ForegroundColor Green
    
    # Verificar DLLs críticas de PyTorch
    $criticalDlls = @(
        "torch\lib\c10.dll",
        "torch\lib\torch_cpu.dll",
        "torch\lib\torch_python.dll"
    )
    
    $missingDlls = @()
    foreach ($dll in $criticalDlls) {
        $dllPath = "$internalPath\$dll"
        if (Test-Path $dllPath) {
            $dllSize = (Get-Item $dllPath).Length / 1MB
            Write-Host "     ✅ $dll ($($dllSize.ToString('F2')) MB)" -ForegroundColor Green
        } else {
            Write-Host "     ❌ $dll - FALTA" -ForegroundColor Red
            $missingDlls += $dll
            $allOk = $false
        }
    }
    
    if ($missingDlls.Count -gt 0) {
        Write-Host ""
        Write-Host "  ⚠️  Faltan DLLs de PyTorch. Recompilar con:" -ForegroundColor Yellow
        Write-Host "     --collect-all torch" -ForegroundColor Gray
    }
    
} else {
    Write-Host "  ❌ Carpeta _internal/ NO encontrada" -ForegroundColor Red
    Write-Host "     Usar --onedir al compilar (no --onefile)" -ForegroundColor Yellow
    $allOk = $false
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════
# 3. VERIFICAR MODELOS YOLO
# ═══════════════════════════════════════════════════════════════

Write-Host "🔍 Verificando modelos YOLO..." -ForegroundColor Yellow
Write-Host ""

$modelos = @(
    "modelos\grayscale\best.pt",
    "modelos\normal\best.pt"
)

foreach ($modelo in $modelos) {
    if (Test-Path $modelo) {
        $modelSize = (Get-Item $modelo).Length / 1MB
        Write-Host "  ✅ $modelo ($($modelSize.ToString('F2')) MB)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $modelo - FALTA" -ForegroundColor Red
        $allOk = $false
    }
}

# Verificar si están en el ejecutable empaquetado
if (Test-Path $distPath) {
    $modelosInDist = @(
        "$distPath\modelos\grayscale\best.pt",
        "$distPath\modelos\normal\best.pt"
    )
    
    Write-Host ""
    Write-Host "  Modelos en el ejecutable:" -ForegroundColor Cyan
    foreach ($modelo in $modelosInDist) {
        if (Test-Path $modelo) {
            $modelSize = (Get-Item $modelo).Length / 1MB
            $relativePath = $modelo -replace [regex]::Escape($distPath + "\"), ""
            Write-Host "  ✅ $relativePath ($($modelSize.ToString('F2')) MB)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $($modelo.Replace($distPath + '\', '')) - FALTA" -ForegroundColor Red
            Write-Host "     Agregar: --add-data `"modelos;modelos`"" -ForegroundColor Yellow
            $allOk = $false
        }
    }
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════
# 4. VERIFICAR LIBRERÍAS DEL SISTEMA
# ═══════════════════════════════════════════════════════════════

Write-Host "🔍 Verificando librerías del sistema..." -ForegroundColor Yellow
Write-Host ""

# Verificar si las DLLs están en System32
$systemDlls = @(
    "$env:SystemRoot\System32\msvcp120.dll",  # VC++ 2013
    "$env:SystemRoot\System32\vcruntime140.dll"  # VC++ 2015-2022
)

foreach ($dll in $systemDlls) {
    if (Test-Path $dll) {
        $dllName = Split-Path $dll -Leaf
        Write-Host "  ✅ $dllName (System32)" -ForegroundColor Green
    } else {
        $dllName = Split-Path $dll -Leaf
        Write-Host "  ❌ $dllName - NO ENCONTRADO en System32" -ForegroundColor Red
        $allOk = $false
    }
}

Write-Host ""

# ═══════════════════════════════════════════════════════════════
# RESUMEN FINAL
# ═══════════════════════════════════════════════════════════════

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan

if ($allOk) {
    Write-Host ""
    Write-Host "  ✅ TODO CORRECTO" -ForegroundColor Green
    Write-Host "  El ejecutable debería funcionar en otras PCs" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "  ⚠️  SE ENCONTRARON PROBLEMAS" -ForegroundColor Yellow
    Write-Host "  Revisa los errores marcados arriba" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  Soluciones:" -ForegroundColor Cyan
    Write-Host "  1. Instalar VC++ Redistributables faltantes" -ForegroundColor White
    Write-Host "  2. Recompilar con: --collect-all torch --add-data modelos;modelos" -ForegroundColor White
    Write-Host "  3. Usar --onedir --noupx (no --onefile)" -ForegroundColor White
    Write-Host ""
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presiona Enter para salir"

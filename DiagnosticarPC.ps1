# ==================================================================
#  DIAGNOSTICO COMPLETO DE DEPENDENCIAS EN PC DE DESTINO
# ==================================================================

Write-Host ""
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "     DIAGNOSTICO DE DEPENDENCIAS - PC DESTINO" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# ==================================================================
# 1. VERIFICAR VC++ REDISTRIBUTABLES INSTALADOS
# ==================================================================

Write-Host "[*] Verificando Visual C++ Redistributables instalados..." -ForegroundColor Yellow
Write-Host ""

$vcPackages = Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
                                "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue |
              Where-Object { $_.DisplayName -like "*Visual C++*" } |
              Select-Object DisplayName, DisplayVersion, Publisher

if ($vcPackages) {
    foreach ($pkg in $vcPackages) {
        Write-Host "  [OK] $($pkg.DisplayName) - v$($pkg.DisplayVersion)" -ForegroundColor Green
    }
} else {
    Write-Host "  [ERROR] NO se encontraron paquetes de Visual C++ instalados" -ForegroundColor Red
}

Write-Host ""

# ==================================================================
# 2. VERIFICAR DLLs EN SYSTEM32
# ==================================================================

Write-Host "[*] Verificando DLLs en System32..." -ForegroundColor Yellow
Write-Host ""

$requiredDlls = @{
    "msvcp120.dll" = "Visual C++ 2013"
    "msvcr120.dll" = "Visual C++ 2013"
    "vcruntime140.dll" = "Visual C++ 2015-2022"
    "msvcp140.dll" = "Visual C++ 2015-2022"
    "vcruntime140_1.dll" = "Visual C++ 2015-2022"
}

foreach ($dll in $requiredDlls.Keys) {
    $path = "$env:SystemRoot\System32\$dll"
    if (Test-Path $path) {
        $version = (Get-Item $path).VersionInfo.FileVersion
        Write-Host "  [OK] $dll - v$version ($($requiredDlls[$dll]))" -ForegroundColor Green
    } else {
        Write-Host "  [FALTA] $dll - $($requiredDlls[$dll])" -ForegroundColor Red
    }
}

Write-Host ""

# ==================================================================
# 3. VERIFICAR DLLs EN EL EJECUTABLE
# ==================================================================

Write-Host "[*] Verificando DLLs de PyTorch en el ejecutable..." -ForegroundColor Yellow
Write-Host ""

$internalPath = ".\GinnetAudioAnalyzer\_internal"
if (-not (Test-Path $internalPath)) {
    $internalPath = ".\_internal"
}

if (Test-Path $internalPath) {
    $torchDlls = @(
        "torch\lib\c10.dll",
        "torch\lib\torch_cpu.dll",
        "torch\lib\torch_python.dll",
        "torch\lib\fbgemm.dll",
        "torch\lib\asmjit.dll"
    )
    
    foreach ($dll in $torchDlls) {
        $fullPath = Join-Path $internalPath $dll
        if (Test-Path $fullPath) {
            $size = (Get-Item $fullPath).Length / 1MB
            Write-Host "  [OK] $dll ($($size.ToString('F2')) MB)" -ForegroundColor Green
        } else {
            Write-Host "  [FALTA] $dll" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  [ERROR] No se encuentra la carpeta _internal/" -ForegroundColor Red
}

Write-Host ""

# ==================================================================
# 4. VERIFICAR DEPENDENCIAS DE c10.dll CON DUMPBIN (si está disponible)
# ==================================================================

Write-Host "[*] Verificando dependencias de c10.dll..." -ForegroundColor Yellow
Write-Host ""

$c10Path = Join-Path $internalPath "torch\lib\c10.dll"
if (Test-Path $c10Path) {
    # Intentar usar dumpbin si está disponible
    $dumpbin = Get-Command dumpbin -ErrorAction SilentlyContinue
    
    if ($dumpbin) {
        Write-Host "  Dependencias de c10.dll:" -ForegroundColor Cyan
        & dumpbin /dependents $c10Path | Select-String "\.dll"
    } else {
        Write-Host "  [INFO] dumpbin no disponible (requiere Visual Studio)" -ForegroundColor Gray
        Write-Host "  Usando metodo alternativo..." -ForegroundColor Gray
        
        # Método alternativo: intentar cargar la DLL
        try {
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class DllLoader {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr LoadLibrary(string lpFileName);
    
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool FreeLibrary(IntPtr hModule);
    
    [DllImport("kernel32.dll")]
    public static extern uint GetLastError();
}
"@
            $handle = [DllLoader]::LoadLibrary($c10Path)
            if ($handle -eq [IntPtr]::Zero) {
                $error = [DllLoader]::GetLastError()
                Write-Host "  [ERROR] No se puede cargar c10.dll. Codigo de error: $error" -ForegroundColor Red
                
                if ($error -eq 126) {
                    Write-Host "  CAUSA: Falta una DLL dependiente (msvcp120.dll, vcruntime140.dll, etc.)" -ForegroundColor Yellow
                } elseif ($error -eq 1114) {
                    Write-Host "  CAUSA: Error de inicializacion de DLL (posiblemente UPX corrupto)" -ForegroundColor Yellow
                }
            } else {
                Write-Host "  [OK] c10.dll se puede cargar correctamente" -ForegroundColor Green
                [DllLoader]::FreeLibrary($handle) | Out-Null
            }
        } catch {
            Write-Host "  [ERROR] $_" -ForegroundColor Red
        }
    }
} else {
    Write-Host "  [ERROR] c10.dll no encontrado en $c10Path" -ForegroundColor Red
}

Write-Host ""

# ==================================================================
# 5. VERIFICAR SI EL EJECUTABLE USA UPX
# ==================================================================

Write-Host "[*] Verificando si el ejecutable usa compresion UPX..." -ForegroundColor Yellow
Write-Host ""

$exePath = ".\GinnetAudioAnalyzer\GinnetAudioAnalyzer.exe"
if (-not (Test-Path $exePath)) {
    $exePath = ".\GinnetAudioAnalyzer.exe"
}

if (Test-Path $exePath) {
    $content = Get-Content $exePath -Encoding Byte -TotalCount 2048
    $stringContent = [System.Text.Encoding]::ASCII.GetString($content)
    
    if ($stringContent -match "UPX") {
        Write-Host "  [AVISO] El ejecutable ESTA COMPRIMIDO con UPX" -ForegroundColor Red
        Write-Host "  SOLUCION: Recompilar con --noupx" -ForegroundColor Yellow
    } else {
        Write-Host "  [OK] El ejecutable NO usa UPX" -ForegroundColor Green
    }
} else {
    Write-Host "  [ERROR] Ejecutable no encontrado" -ForegroundColor Red
}

Write-Host ""

# ==================================================================
# 6. INFORMACION DEL SISTEMA
# ==================================================================

Write-Host "[*] Informacion del sistema..." -ForegroundColor Yellow
Write-Host ""

$arquitectura = if ([System.Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }

Write-Host "  Sistema Operativo: $([System.Environment]::OSVersion.VersionString)" -ForegroundColor Gray
Write-Host "  Arquitectura: $arquitectura" -ForegroundColor Gray
Write-Host "  Version .NET: $([System.Environment]::Version)" -ForegroundColor Gray

Write-Host ""

# ==================================================================
# RESUMEN Y RECOMENDACIONES
# ==================================================================

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  RECOMENDACIONES:" -ForegroundColor Yellow
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Si el error persiste:" -ForegroundColor White
Write-Host "  1. Verifica que TODAS las DLLs de System32 esten marcadas como [OK]" -ForegroundColor Gray
Write-Host "  2. Si el ejecutable usa UPX, recompilarlo con --noupx" -ForegroundColor Gray
Write-Host "  3. Ejecutar como Administrador una vez" -ForegroundColor Gray
Write-Host "  4. Desactivar antivirus temporalmente" -ForegroundColor Gray
Write-Host ""

Read-Host "Presiona Enter para salir"

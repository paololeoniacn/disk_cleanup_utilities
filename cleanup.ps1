# ===============================
# Script Pulizia Windows - bpaoleon
# ===============================

# Controlla se è in esecuzione come amministratore
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $adminCheck) {
    Write-Warning "⚠️ Devi eseguire questo script come AMMINISTRATORE!"
    Write-Host "➡️ Per farlo, clicca con il tasto destro su PowerShell e scegli 'Esegui come amministratore'."
    Write-Host "❌ Chiusura script..."
    Start-Sleep -Seconds 5
    exit
}

# Percorso del file di log
$logPath = "$env:USERPROFILE\Desktop\cleanup_Log.txt"
Start-Transcript -Path $logPath -Append

function Delete-FilesInFolder($path) {
    if (Test-Path $path) {
        Write-Output "Pulizia in corso: $path"
        try {
            Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Output "✔️ Pulito: $path"
        } catch {
            Write-Output "❌ Errore durante la pulizia: $path - $_"
        }
    } else {
        Write-Output "❌ Percorso non trovato: $path"
    }
}

# 1. Pulisci cartelle
Delete-FilesInFolder "$env:TEMP"
Delete-FilesInFolder "C:\Windows\Prefetch"
Delete-FilesInFolder "C:\Windows\SoftwareDistribution"
Delete-FilesInFolder "C:\Windows\SysWOW64\CCM\Cache"
Delete-FilesInFolder "C:\Windows\CCMCache"

# 2. Svuota il Cestino
try {
    Write-Output "Svuotamento del Cestino..."
    (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Output "✔️ Cestino svuotato."
} catch {
    Write-Output "❌ Errore nello svuotamento del Cestino: $_"
}

# 3. Avvia Disk Cleanup
Write-Output "Avvio Pulizia Disco..."
Start-Process cleanmgr.exe

# 4. Avvia Windows Update - Check for updates
# Write-Output "Avvio ricerca aggiornamenti Windows..."
# Start-Process "ms-settings:windowsupdate"

# 5. Esegui SFC /scannow
Write-Output "Esecuzione di 'sfc /scannow'..."
Start-Process -FilePath "cmd.exe" -ArgumentList "/c sfc /scannow" -Verb RunAs

# Fine script
Stop-Transcript
Write-Output "`n✅ Pulizia completata. Log salvato su Desktop."

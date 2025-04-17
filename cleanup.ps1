# ===============================
# Script Pulizia Windows - versione stabile
# ===============================

# 1. Controllo privilegi amministratore
$adminCheck = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $adminCheck) {
    Write-Warning "Devi eseguire questo script come AMMINISTRATORE!"
    Write-Host "Tasto destro su PowerShell > 'Esegui come amministratore'."
    Start-Sleep -Seconds 5
    exit
}

# 2. Log su Desktop
$logPath = "$env:USERPROFILE\Desktop\Pulizia_Log.txt"
Start-Transcript -Path $logPath -Append

# 3. Funzione per eliminare i contenuti di una cartella
function Delete-FilesInFolder {
    param (
        [string]$path
    )
    
    if (Test-Path $path) {
        Write-Output "`nPulizia di: $path"
        try {
            Get-ChildItem -Path $path -Force -Recurse -ErrorAction SilentlyContinue |
                Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
            Write-Output "OK - Pulito: $path"
        } catch {
            Write-Output "X - Errore nella pulizia di: $path - $_"
        }
    } else {
        Write-Output "A - Percorso non trovato: $path"
    }
}

function Get-DiskFreeSpace {
    $drive = Get-PSDrive C
    return "{0:N2} GB disponibili su C:" -f ($drive.Free / 1GB)
}

Write-Output "`nSpazio su disco PRIMA della pulizia:"
Write-Output (Get-DiskFreeSpace)
$startTime = Get-Date


# 4. Esecuzione pulizie
$cartelleDaPulire = @(
    "$env:TEMP",
    "C:\Windows\Prefetch",
    "C:\Windows\SoftwareDistribution",
    "C:\Windows\SysWOW64\CCM\Cache",
    "C:\Windows\CCMCache"
)

foreach ($cartella in $cartelleDaPulire) {
    Delete-FilesInFolder -path $cartella
}

# 5. Svuota il cestino
try {
    Write-Output "`nSvuotamento del Cestino..."
    (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() |
        ForEach-Object { Remove-Item $_.Path -Force -Recurse -ErrorAction SilentlyContinue }
    Write-Output "OK - Cestino svuotato."
} catch {
    Write-Output "X - Errore svuotando il Cestino: $_"
}

# 6. Pulizia disco
Write-Output "Avvio Pulizia Disco..."
Start-Process cleanmgr.exe -Wait

$endTime = Get-Date
Write-Output "`nSpazio su disco DOPO la pulizia:"
Write-Output (Get-DiskFreeSpace)

$duration = $endTime - $startTime
Write-Output "Durata dello script: $($duration.ToString())"

Write-Output "---`n`nOra non resta che ricercare Aggiornamenti Windows..."

Read-Host "`npremi un tasto per uscire"
# MUST BE RUN IN ROOT FOLDER OF NXLog-AutoConfig
#
# https://live.sysinternals.com/Sysmon.exe
# https://live.sysinternals.com/Sysmon64.exe
#
# https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml
#
# https://live.sysinternals.com/autorunsc.exe
# https://live.sysinternals.com/autorunsc64.exe
#
# https://github.com/jessek/hashdeep/archive/release-4.4.zip
#
# https://download.microsoft.com/download/B/8/6/B8617908-B777-4A86-A629-FFD1094990BD/iis7psprov_x64.msi
# https://download.microsoft.com/download/E/4/B/E4B5344A-4D6F-46B1-8D82-27AA6A27D13C/iis7psprov_x86.msi


Write-Host "Downloading Required Binaries" -ForegroundColor Green

Write-Host "Downloading NXLog Community Edition" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://nxlog.co/system/files/products/files/348/nxlog-ce-2.10.2150.msi", "$PSScriptRoot/nxlog.msi")
Write-Host "Time taken to download NXLog to nxlog.msi: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading Sysmon 32bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://live.sysinternals.com/Sysmon.exe", "$PSScriptRoot/binaries/sysmon.exe")
Write-Host "Time taken to download Sysmon 32bit to binaries/sysmon.exe: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading Sysmon 64bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://live.sysinternals.com/Sysmon64.exe", "$PSScriptRoot/binaries/sysmon64.exe")
Write-Host "Time taken to download Sysmon 64bit to binaries/sysmon64.exe: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading Sysmon Config" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/master/sysmonconfig-export.xml", "$PSScriptRoot/binaries/sysmon.xml")
Write-Host "Time taken to download SwiftOnSecurity sysmon config to binaries/sysmon.xml: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading AutoRuns 32bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://live.sysinternals.com/autorunsc.exe", "$PSScriptRoot/binaries/autorunsc.exe")
Write-Host "Time taken to download Autoruns 32bit to binaries/autorunsc.exe $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading AutoRuns 64bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://live.sysinternals.com/autorunsc64.exe", "$PSScriptRoot/binaries/autorunsc64.exe")
Write-Host "Time taken to download Autoruns 64bit to binaries/autorunsc64.exe: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading IIS powershell Snap-in 32bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/E/4/B/E4B5344A-4D6F-46B1-8D82-27AA6A27D13C/iis7psprov_x86.msi", "$PSScriptRoot/binaries/iis7psprov_x86.msi")
Write-Host "Time taken to download IIS powershell Snap-in 32bit to binaries/iis7psprov_x86.msi: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading IIS powershell Snap-in 64bit" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://download.microsoft.com/download/B/8/6/B8617908-B777-4A86-A629-FFD1094990BD/iis7psprov_x64.msi", "$PSScriptRoot/binaries/iis7psprov_x64.msi")
Write-Host "Time taken to download IIS powershell Snap-in 64bit to binaries/iis7psprov_x64.msi: $((Get-Date).Subtract($start_time).Seconds) second(s)"

Write-Host "Downloading SHA1Deep" -BackgroundColor Black
$start_time = Get-Date
(New-Object System.Net.WebClient).DownloadFile("https://github.com/jessek/hashdeep/releases/download/v4.4/md5deep-4.4.zip", "$PSScriptRoot/binaries/hashdeep.zip")
Expand-Archive -Path $PSScriptRoot/binaries/hashdeep.zip -DestinationPath $PSScriptRoot/binaries/

Copy-Item -Path "$PSScriptRoot/binaries/md5deep-4.4/sha1deep*" -Destination "$PSScriptRoot/binaries/"
Remove-Item –Path "$PSScriptRoot/binaries/md5deep-4.4" –recurse
Write-Host "Time taken to download SHA1Deep to binaries/sha1deep.exe: $((Get-Date).Subtract($start_time).Seconds) second(s)"

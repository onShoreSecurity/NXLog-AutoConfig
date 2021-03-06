# FileName: nxlog_master.ps1

# This script is used to install, upgrade, and maintain nxlog config files

# Need to modify module and binary download functions to do version checks

# Define the parameters of this script.
Param(
  [string]$Version = "1.0",
  [string]$WebHost = "wef.windomain.local:8080", # << REPLACE HERE
  [string]$MSILocation = "http://$WebHost/NXLog-AutoConfig/nxlog.msi",
  [string]$script:webFileLocation = "http://$WebHost/NXLog-AutoConfig",
  [string]$script:logcollector = "192.168.38.105", # << REPLACE HERE
  [string]$script:scriptPath = "C:\Temp\nxlog"
)

# Set variables - DO NOT CHANGE
$script:binPath = "$script:scriptPath\bin"
$script:modulePath = "$script:scriptPath\modules"

# Store whether the system is 32-bit or 64-bit (AMD64)
$script:architecture = $ENV:PROCESSOR_ARCHITECTURE

# Test if $script:scriptPath exists and if not create it
if(!(Test-Path -Path $script:scriptPath)){
    New-Item -Path $script:scriptPath -ItemType directory -Force
}

# Test if $script:scriptPath\bin exists and if not create it
if(!(Test-Path -Path "$script:binPath")){
    New-Item -Path "$script:binPath" -ItemType directory    
}

# Test if $script:scriptPath\modules exists and if not create it
if(!(Test-Path -Path "$script:modulePath")){
    New-Item -Path "$script:modulePath" -ItemType directory    
}

function binaryDownload($filePath){
    if($script:architecture -eq "AMD64"){
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("$script:webFileLocation/binaries/sha1deep64.exe","$script:binPath\sha1deep64.exe")
    } else {
        $WebClient = New-Object System.Net.WebClient
        $WebClient.DownloadFile("$script:webFileLocation/binaries/sha1deep.exe","$script:binPath\sha1deep.exe")
    }
    $content = Get-Content -Path $filePath
        (Get-Content -Path $filePath) | ForEach-Object {
            $array = $_.Split(',')
            $exe = $array[0]
            $hash = $array[1]
            if(!(Test-Path -Path "$script:binPath\$exe")){
                Write-Host "Attempting to download $exe"
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile("$script:webFileLocation/binaries/$exe","$script:binPath\$exe")
            }
            if($script:architecture -eq "AMD64"){
                    $binaryHash = & "$script:binPath\sha1deep64.exe" "$script:binPath\$exe"
            } else {
                $binaryHash = & "$script:binPath\sha1deep.exe" "$script:binPath\$exe"
            }
            $binaryHash = $binaryHash.substring(0,$binaryHash.indexof(" "))
            if($binaryHash -ne $hash){
                Write-Host "Binary updated. Downloading $exe"
                $WebClient = New-Object System.Net.WebClient
                $WebClient.DownloadFile("$script:webFileLocation/binaries/$exe","$script:binPath\$exe")
            }
    }
}

function moduleDownload($filePath){
    $content = Get-Content -Path $filePath
    Get-Content -Path $filePath | ForEach-Object {
        $array = $_.Split(',')
        $module = $array[0]
        $hash = $array[1]
        if(!(Test-Path -Path "$script:modulePath\$module")){
            Write-Host "Attempting to download $module"
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("$script:webFileLocation/modules/$module","$script:modulePath\$module")
        }
        if($script:architecture -eq "AMD64"){
            $moduleHash = & "$script:binPath\sha1deep64.exe" "$script:modulePath\$module"
        } else {
            $moduleHash = & "$script:binPath\sha1deep.exe" "$script:modulePath\$module"
        }
        $moduleHash = $moduleHash.substring(0,$moduleHash.indexof(" "))
        if($moduleHash -ne $hash){
            Write-Host "Module updated. Downloading $module"
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile("$script:webFileLocation/modules/$module","$script:modulePath\$module")
        }
    }
}

# Grab list of binaries
Remove-Item -Path "$script:binPath\bin.txt" -Force -ErrorAction SilentlyContinue
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("$script:webFileLocation/binaries/bin.txt","$script:binPath\bin.txt")
binaryDownload("$script:binPath\bin.txt")

# Grab list of modules
Remove-Item -Path "$script:modulePath\module.txt" -Force -ErrorAction SilentlyContinue
$WebClient = New-Object System.Net.WebClient
$WebClient.DownloadFile("$script:webFileLocation/modules/module.txt","$script:modulePath\module.txt")
moduleDownload("$script:modulePath\module.txt")

# Check if NXLog is installed and the current version
if($script:architecture -eq "AMD64"){
    if(((Get-ItemProperty HKLM:\Software\WoW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -contains "NXLog" } | Select-Object -expand DisplayVersion) -ne $Version) -or (!(Test-Path -Path "C:\Program Files (x86)\nxlog\nxlog.exe"))){
       # Run installer to perform install or upgrade
       if(!(Test-Path -Path "$script:scriptPath\nxlog.msi")){
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($MSILocation,"$script:scriptPath\nxlog.msi")
        }
       & "msiexec.exe" @('/i', "$script:scriptPath\nxlog.msi", '/qn')
       While((Get-Service -Name nxlog -ErrorAction SilentlyContinue).Status -ne "Running"){
            Write-Host "Waiting on nxlog to finish installing"
            Sleep -Seconds 5
            Start-Service nxlog -ErrorAction SilentlyContinue
       }
       Write-Host "NXlog is installed"
       Sleep -Seconds 5
    }
} else {
    if(((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object { $_.DisplayName -contains "NXLog" } | Select-Object -expand DisplayVersion) -ne $Version) -or (!(Test-Path -Path "C:\Program Files\nxlog\nxlog.exe"))){
        # Run installer to perform install or upgrade
        if(!(Test-Path -Path "$script:scriptPath\nxlog.msi")){
            $WebClient = New-Object System.Net.WebClient
            $WebClient.DownloadFile($MSILocation,"$script:scriptPath\nxlog.msi")
        }
        & "msiexec.exe" @('/i', "$script:scriptPath\nxlog.msi", '/qn')
        While((Get-Service -Name nxlog -ErrorAction SilentlyContinue).Status -ne "Running"){
            Write-Host "Waiting on nxlog to finish installing"
            Sleep -Seconds 5
            Start-Service nxlog -ErrorAction SilentlyContinue
       }
       Write-Host "NXlog is installed"
       Sleep -Seconds 5
    }
}

$script:conf = "Panic Soft
#NoFreeOnExit TRUE
"

#Store the base configuration in $script:conf variable which will be written out to a temporary file for hash check.
if($script:architecture -eq "x86"){
    $nxlogpath = "C:\Program Files\nxlog"
    $script:conf += "define ROOT C:\Program Files\nxlog"
} else {
   $nxlogpath = "C:\Program Files (x86)\nxlog"
   $script:conf += "define ROOT C:\Program Files (x86)\nxlog"
}



$script:conf += "

ModuleDir %ROOT%\modules
CacheDir  %ROOT%\data
SpoolDir  %ROOT%\data

define CERTDIR %ROOT%\cert
define CONFDIR %ROOT%\conf

# Note that these two lines define constants only; the log file location
# is ultimately set by the `LogFile` directive (see below). The
# `MYLOGFILE` define is also used to rotate the log file automatically
# (see the `_fileop` block).
define LOGDIR %ROOT%\data
define MYLOGFILE %LOGDIR%\nxlog.log

# By default, `LogFile %MYLOGFILE%` is set in log4ensics.conf. This
# allows the log file location to be modified via NXLog Manager. If you
# are not using NXLog Manager, you can instead set `LogFile` below and
# disable the `include` line.
#LogFile %MYLOGFILE%
#include %CONFDIR%\log4ensics.conf

<Extension _syslog>
    Module  xm_syslog
</Extension>

<Extension _json>
    Module  xm_json
</Extension>

# This block rotates `%MYLOGFILE%` on a schedule. Note that if `LogFile`
# is changed in log4ensics.conf via NXLog Manager, rotation of the new
# file should also be configured there.
<Extension _fileop>
    Module  xm_fileop

    # Check the size of our log file hourly, rotate if larger than 5MB
    <Schedule>
        Every   1 hour
        <Exec>
            if ( file_exists('%MYLOGFILE%') and
                 (file_size('%MYLOGFILE%') >= 5M) )
            {
                 file_cycle('%MYLOGFILE%', 8);
            }
        </Exec>
    </Schedule>

    # Rotate our log file every week on Sunday at midnight
    <Schedule>
        When    @weekly
        Exec    if file_exists('%MYLOGFILE%') file_cycle('%MYLOGFILE%', 8);
    </Schedule>
</Extension>

<Output collector>
    Module  om_tcp
    host    $script:logcollector
    port    514
</Output>

"

# Launch modules - If parameter specificied load modules via parameter otherwise default
# to the modules folder in the current working directory
$modules = Get-ChildItem -Path $script:modulePath -Filter *.ps1

if($modules){
    foreach($module in $modules){
        . $module.FullName
    }
}

# Create temporary configuration file, hash this file, and compare to current file if any
# If match... exit.  If there is not a match, overwrite

# Create temp configuration file
$script:conf | Out-File -Force -Encoding ASCII "C:\Windows\Temp\nxlog.conf"

if($architecture -eq "AMD64"){
    $temphash = & "$script:binPath\sha1deep64.exe" "C:\Windows\Temp\nxlog.conf"
} else {
    $temphash = & "$script:binPath\sha1deep.exe" "C:\Windows\Temp\nxlog.conf"
}
$temphash = $temphash.substring(0,$temphash.indexof(" "))

if($script:architecture -eq "AMD64"){
    $prodhash = & "$script:binPath\sha1deep64.exe" "$nxlogpath\conf\nxlog.conf"
} else {
    $prodhash = & "$script:binPath\sha1deep.exe" "$nxlogpath\conf\nxlog.conf"
}

$prodhash = $prodhash.substring(0,$prodhash.indexof(" "))

# Save NXLog config
if($prodhash -ne $temphash){
    Write-Host "TempHash is: $temphash" -ForegroundColor Red
    Write-Host "ProdHash is: $prodhash" -ForegroundColor Green
    $script:conf | Out-File -force -Encoding ASCII "$nxlogpath\conf\nxlog.conf"
    Write-Host "File overwritten" -ForegroundColor Blue
    # Restart services
    Stop-Service -Force nxlog
    Remove-Item -Force "C:\Program Files (x86)\nxlog\data\nxlog.log" -ErrorAction SilentlyContinue
    Remove-Item -Force "C:\Program Files\nxlog\data\nxlog.log" -ErrorAction SilentlyContinue
    Start-Service nxlog
} else {
    Stop-Service -Force nxlog
    Start-Service nxlog
}

if((Get-Service -Name nxlog).Status -eq "Running"){
    Write-Host "NXLog is running smoothly. Ending script..." -ForegroundColor Green
} else {
    Write-Host "NXLog is not running.  Something maybe wrong" -ForegroundColor Red
}
#Install Sysmon
if($script:architecture -eq "AMD64"){
    Write-Host "Running Autoruns Module 64 bit"
    if(Test-Path "$script:binPath\autorunsc.exe"){
		Start-Process -FilePath "$script:binPath\autorunsc.exe" -ArgumentList "/accepteula -a * -ct -h -m -s -t" -RedirectStandardOutput "C:\Windows\Temp\autorun.csv" -PassThru -NoNewWindow -ErrorAction Stop | Wait-Process
	}
}else {
    Write-Host "Running Autoruns Module 32 bit"
    if(Test-Path "$script:binPath\autorunsc64.exe"){
		Start-Process -FilePath "$script:binPath\autorunsc64.exe" -ArgumentList "/accepteula -a * -ct -h -m -s -t" -RedirectStandardOutput "C:\Windows\Temp\autorun.csv" -PassThru -NoNewWindow -ErrorAction Stop | Wait-Process
	}
}
 
$conf += '<Input autorun_in>
  Module	im_file
  File		"C:\Windows\Temp\autorun.csv"
  Exec $NXLogHostname = '
  $conf += "'"
  $conf += $env:computername
  $conf += "';"
  $conf += '
  Exec to_json();
</Input>

<Processor autorun_buffer>
    Module      pm_buffer
    # 1Mb buffer
    MaxSize 1024
    Type Mem
    # warn at 512k
    WarnLimit 512
</Processor>
 
<Route autorun>
   Path autorun_in => autorun_buffer => collector
</Route>

'
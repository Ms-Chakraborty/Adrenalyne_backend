$p = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*tickets-0.0.1-SNAPSHOT.jar*' }
if ($p) {
  Write-Host "Stopping process: $($p.ProcessId)"
  Stop-Process -Id $p.ProcessId -Force
  Start-Sleep -Seconds 1
}
$env:SPRING_PROFILES_ACTIVE='dev'
$java = if ($env:JAVA_HOME) { Join-Path $env:JAVA_HOME 'bin\java.exe' } else { 'java' }
Start-Process -FilePath $java -ArgumentList '-jar','target\tickets-0.0.1-SNAPSHOT.jar' -WorkingDirectory (Get-Location) -NoNewWindow -PassThru
Start-Sleep -Seconds 3
Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*tickets-0.0.1-SNAPSHOT.jar*' } | Select-Object ProcessId, CommandLine

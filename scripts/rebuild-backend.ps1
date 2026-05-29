$p = Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like '*tickets-0.0.1-SNAPSHOT.jar*' }
if ($p) {
  Write-Host "Found process: $($p.ProcessId)"
  Stop-Process -Id $p.ProcessId -Force
  Start-Sleep -Seconds 1
} else {
  Write-Host 'No running tickets jar process found'
}
& .\mvnw.cmd -DskipTests package

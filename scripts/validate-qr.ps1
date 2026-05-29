$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body (ConvertTo-Json @{ username='validator'; password='ValidatorPass123!' }) -ContentType 'application/json' -WebSession $s
Write-Host "Logged in as validator: $($login.username)"
$qrId = 'a40f2159-cfe5-4ecb-9353-2050d4d34746'
$payload = @{ id = $qrId; method = 'QR_SCAN' } | ConvertTo-Json
try {
  $res = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/ticket-validations' -Method Post -Body $payload -ContentType 'application/json' -WebSession $s -ErrorAction Stop
  $res | ConvertTo-Json -Depth 5 | Write-Host
} catch {
  Write-Host 'Validation request failed'; if ($_.Exception.Response -ne $null) { $stream = $_.Exception.Response.GetResponseStream(); $reader = New-Object System.IO.StreamReader($stream); $body = $reader.ReadToEnd(); Write-Host 'Error body:'; Write-Host $body } else { Write-Host $_.Exception.Message }
}

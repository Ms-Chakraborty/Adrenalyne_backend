$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body (ConvertTo-Json @{ username='attendee'; password='AttendeePass123!' }) -ContentType 'application/json' -WebSession $s
Write-Host "Logged in: $($login.username)"
$ticketId='e2fefbea-610c-4eb7-9546-02272bc70c93'
$res = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/tickets/$ticketId/qr-codes/id" -Method Get -WebSession $s -ErrorAction Stop
Write-Host "QR id: $res"

$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body (ConvertTo-Json @{ username='attendee'; password='AttendeePass123!' }) -ContentType 'application/json' -WebSession $s
Write-Host "Logged in: $($login.username)"
$tickets = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/tickets' -Method Get -WebSession $s
if ($tickets -eq $null) { Write-Host 'No tickets returned'; exit 1 }
$tickets | ConvertTo-Json -Depth 6 | Write-Host
$ticketId = $tickets.content[0].id
Write-Host "TicketId: $ticketId"
Invoke-WebRequest -Uri "http://localhost:8080/api/v1/tickets/$ticketId/qr-codes" -Method Get -OutFile qr.png -WebSession $s
Write-Host "Saved qr.png"

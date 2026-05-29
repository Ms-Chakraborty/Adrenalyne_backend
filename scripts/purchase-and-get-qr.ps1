$s = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$login = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/auth/login' -Method Post -Body (ConvertTo-Json @{ username='attendee'; password='AttendeePass123!' }) -ContentType 'application/json' -WebSession $s
Write-Host "Logged in: $($login.username)"
$events = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/published-events' -Method Get -WebSession $s
$events | ConvertTo-Json -Depth 6 | Write-Host
$eventId = $events[0].id
$ticketTypeId = $events[0].ticketTypes[0].id
Write-Host "Purchasing ticket for event: $eventId, ticketType: $ticketTypeId"
$purchase = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/events/$eventId/ticket-types/$ticketTypeId/tickets" -Method Post -WebSession $s
Write-Host "Purchase response: "
$purchase | ConvertTo-Json -Depth 6 | Write-Host
# list tickets and get newest ticket id
$tickets = Invoke-RestMethod -Uri 'http://localhost:8080/api/v1/tickets' -Method Get -WebSession $s
$tickets | ConvertTo-Json -Depth 6 | Write-Host
$ticketId = $tickets.content[0].id
Write-Host "New TicketId: $ticketId"
$res = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/tickets/$ticketId/qr-codes/id" -Method Get -WebSession $s -ErrorAction Stop
Write-Host "QR id: $res"

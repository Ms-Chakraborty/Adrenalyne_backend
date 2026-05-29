# Create tickets for each event and then run full tests
$ErrorActionPreference = 'Stop'

$KeycloakTokenUrl = "http://localhost:9090/realms/event-ticket-platform/protocol/openid-connect/token"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"

function Get-AccessToken {
    $resp = Invoke-RestMethod -Uri $KeycloakTokenUrl -Method Post -ContentType "application/x-www-form-urlencoded" -Body @{grant_type="password"; client_id=$ClientId; client_secret=$ClientSecret; username=$Username; password=$Password }
    return $resp.access_token
}

$AccessToken = Get-AccessToken
$headers = @{ Authorization = "Bearer $AccessToken"; 'Content-Type' = 'application/json' }

Write-Host "Got token. Fetching admin events..."
$eventsPage = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/events" -Method Get -Headers $headers
$events = $eventsPage.content
if (-not $events) { Write-Host "No events found for organizer."; exit 0 }

foreach ($evt in $events) {
    $eventId = $evt.id
    Write-Host "Processing event: $($evt.name) ($eventId)"
    $details = Invoke-RestMethod -Uri "http://localhost:8080/api/v1/events/$eventId" -Method Get -Headers $headers -ErrorAction Stop
    if ($null -eq $details.ticketTypes -or $details.ticketTypes.Count -eq 0) { Write-Host "  No ticket types for event"; continue }
    $ticketTypeId = $details.ticketTypes[0].id
    Write-Host "  Using ticketType: $ticketTypeId"
    for ($i=1; $i -le 2; $i++) {
        try {
            Invoke-WebRequest -Uri "http://localhost:8080/api/v1/events/$eventId/ticket-types/$ticketTypeId/tickets" -Method Post -Headers $headers -ErrorAction Stop -UseBasicParsing
            Write-Host "  Purchased ticket #$i for event $($evt.name)"
        } catch {
            if ($_.Exception.Response -ne $null) {
                $status = $_.Exception.Response.StatusCode.Value__
                Write-Host "  Purchase failed (status $status)"
            } else {
                Write-Host "  Purchase failed: $($_.Exception.Message)"
            }
        }
        Start-Sleep -Milliseconds 300
    }
}

Write-Host "Ticket purchases complete. Now running full test_final.ps1..."
./test_final.ps1

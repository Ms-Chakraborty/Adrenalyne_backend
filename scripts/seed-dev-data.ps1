Param(
    [string]$ApiBase = "http://localhost:8080/api/v1",
    [string]$FrontendDb = "..\Adrenalyne_frontend\db.json",
    [string]$Username = "admin",
    [string]$Password = "AdminPass123!"
)

Write-Host "Seeding dev data from $FrontendDb to $ApiBase"

if (-not (Test-Path $FrontendDb)) {
  Write-Error "db.json not found at $FrontendDb"
  exit 1
}

# session will hold cookies
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession

function Normalize-Date($s) {
  if ([string]::IsNullOrWhiteSpace($s)) { return $null }
  try {
    $dto = [DateTimeOffset]::Parse($s)
    return $dto.LocalDateTime.ToString('yyyy-MM-ddTHH:mm:ss')
  } catch {
    try { return [DateTime]::Parse($s).ToString('yyyy-MM-ddTHH:mm:ss') } catch { return $null }
  }
}

# login
$loginUrl = "$ApiBase/auth/login"
Write-Host "Logging in as $Username..."
$body = @{ username = $Username; password = $Password } | ConvertTo-Json
try {
  $resp = Invoke-RestMethod -Uri $loginUrl -Method Post -Body $body -ContentType 'application/json' -WebSession $session -ErrorAction Stop
  Write-Host "Login response: $($resp | ConvertTo-Json -Depth 2)"
} catch {
  Write-Error "Login failed: $_"
  exit 1
}

$json = Get-Content -Raw -Path $FrontendDb | ConvertFrom-Json
$events = $json.events
if (-not $events) { Write-Error "No events array in db.json"; exit 1 }

$counter = 0
foreach ($ev in $events) {
  $payload = [ordered]@{
    name = $ev.name
    start = (Normalize-Date $ev.start)
    end = (Normalize-Date $ev.end)
    venue = $ev.venue
    salesStart = (Normalize-Date $ev.salesStart)
    salesEnd = (Normalize-Date $ev.salesEnd)
    status = $ev.status
    ticketTypes = @()
  }

  if ($ev.ticketTypes) {
    foreach ($tt in $ev.ticketTypes) {
      $payload.ticketTypes += [ordered]@{
        name = $tt.name
        price = $tt.price
        description = $tt.description
        totalAvailable = $tt.totalAvailable
      }
    }
  }

  # Ensure ticketTypes not empty per validation; if empty, add a placeholder
  if (-not $payload.ticketTypes -or $payload.ticketTypes.Count -eq 0) {
    $payload.ticketTypes = @(@{ name = 'General'; price = 0; description = 'placeholder'; totalAvailable = 0 })
  }

  $url = "$ApiBase/events"
  $jsonBody = $payload | ConvertTo-Json -Depth 5
  try {
    $res = Invoke-RestMethod -Uri $url -Method Post -Body $jsonBody -ContentType 'application/json' -WebSession $session -ErrorAction Stop
    Write-Host "Created event: $($res.name) (id: $($res.id))"
    $counter++
  } catch {
    Write-Warning "Failed to create event '$($ev.name)': $_"
  }
}

Write-Host "Seeding complete. $counter events created."
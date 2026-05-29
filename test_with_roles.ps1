# Test API with role assignment verification

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - Full Test with User Roles" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Get token
Write-Host "Step 1: Authenticating as testuser..." -ForegroundColor Yellow
$tokenResponse = Invoke-RestMethod -Uri "$KeycloakUrl/realms/$RealmName/protocol/openid-connect/token" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
        grant_type    = "password"
        client_id     = $ClientId
        client_secret = $ClientSecret
        username      = $Username
        password      = $Password
    } -ErrorAction Stop

$AccessToken = $tokenResponse.access_token
Write-Host "SUCCESS: Token obtained" -ForegroundColor Green

# Decode token to check roles
$tokenParts = $AccessToken.Split('.')
$payload = $tokenParts[1]
$padding = 4 - ($payload.Length % 4)
if ($padding -ne 4) { $payload += "=" * $padding }
$decodedPayload = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
$tokenData = $decodedPayload | ConvertFrom-Json

Write-Host "Token Info:" -ForegroundColor Cyan
Write-Host "  Issued: $(([datetime]'1970-01-01').AddSeconds($tokenData.iat))" -ForegroundColor Cyan
Write-Host "  Expires: $(([datetime]'1970-01-01').AddSeconds($tokenData.exp))" -ForegroundColor Cyan
Write-Host "  Subject: $($tokenData.sub)" -ForegroundColor Cyan
Write-Host "  Preferred Username: $($tokenData.preferred_username)" -ForegroundColor Cyan
if ($tokenData.realm_access) {
    Write-Host "  Realm Roles: $($tokenData.realm_access.roles -join ', ')" -ForegroundColor Cyan
} else {
    Write-Host "  Realm Roles: NONE" -ForegroundColor Yellow
}
Write-Host ""

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# Test endpoints
Write-Host "Step 2: Testing API endpoints..." -ForegroundColor Yellow
Write-Host ""

# Test 1: List Events
Write-Host "TEST 1: List Events" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Listed $($response.totalElements) event(s)" -ForegroundColor Green
    if ($response.content) {
        foreach ($evt in $response.content) {
            Write-Host "  - $($evt.name) (ID: $($evt.id))" -ForegroundColor Cyan
        }
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Test 2: Create Event
Write-Host "TEST 2: Create Event - TechConf 2026" -ForegroundColor Cyan
$eventPayload = @{
    name        = "TechConf 2026"
    description = "Annual technology conference"
    location    = "San Francisco"
    startDate   = (Get-Date).AddDays(45).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(47).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "  ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "  Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Test 3: Create another event
Write-Host "TEST 3: Create Event - Music Fest 2026" -ForegroundColor Cyan
$eventPayload2 = @{
    name        = "Music Fest 2026"
    description = "Outdoor music festival"
    location    = "Central Park, NY"
    startDate   = (Get-Date).AddDays(60).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(61).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload2 -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "  ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "  Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Test 4: Create a third event
Write-Host "TEST 4: Create Event - Business Expo 2026" -ForegroundColor Cyan
$eventPayload3 = @{
    name        = "Business Expo 2026"
    description = "Business and innovation exhibition"
    location    = "Boston Convention Center"
    startDate   = (Get-Date).AddDays(75).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(76).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload3 -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "  ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "  Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Test 5: List all events again
Write-Host "TEST 5: List All Events (verify creation)" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Found $($response.totalElements) total event(s)" -ForegroundColor Green
    Write-Host ""
    Write-Host "All Events:" -ForegroundColor Cyan
    foreach ($evt in $response.content) {
        Write-Host "  ID: $($evt.id)" -ForegroundColor Cyan
        Write-Host "  Name: $($evt.name)" -ForegroundColor Cyan
        Write-Host "  Description: $($evt.description)" -ForegroundColor Cyan
        Write-Host "  Location: $($evt.location)" -ForegroundColor Cyan
        Write-Host "  Dates: $($evt.startDate) to $($evt.endDate)" -ForegroundColor Cyan
        Write-Host ""
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Testing Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

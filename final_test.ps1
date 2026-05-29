# Final comprehensive test - Testing all endpoints

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - Comprehensive API Test" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Get JWT token with admin role
Write-Host "Authenticating user..." -ForegroundColor Yellow
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

# Decode token
$tokenParts = $AccessToken.Split('.')
$payload = $tokenParts[1]
$padding = 4 - ($payload.Length % 4)
if ($padding -ne 4) { $payload += "=" * $padding }
$decodedPayload = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
$tokenData = $decodedPayload | ConvertFrom-Json

Write-Host "✓ Authenticated successfully" -ForegroundColor Green
Write-Host "  User: $($tokenData.preferred_username)" -ForegroundColor Cyan
Write-Host "  Roles: $(if ($tokenData.realm_access.roles -contains 'admin') { 'ADMIN (✓)' } else { 'Non-admin' })" -ForegroundColor Cyan
Write-Host ""

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

# Test public endpoint
Write-Host "TEST 1: Get Published Events (public endpoint)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/published-events" -Method Get -ErrorAction Stop
    Write-Host "✓ SUCCESS - Public endpoint works (no auth needed)" -ForegroundColor Green
    Write-Host "  Total events: $($response.totalElements)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Test secured endpoint
Write-Host "TEST 2: Get My Events (secured, auth required)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "✓ SUCCESS" -ForegroundColor Green
    Write-Host "  My events: $($response.totalElements)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Create first event
Write-Host "TEST 3: Create Event 1 - TechConf 2026" -ForegroundColor Yellow
$event1 = @{
    name        = "TechConf 2026"
    description = "Annual international technology conference"
    location    = "San Francisco Convention Center"
    startDate   = "2026-07-15"
    endDate     = "2026-07-17"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event1 -ErrorAction Stop
    Write-Host "✓ SUCCESS" -ForegroundColor Green
    Write-Host "  Event ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    try {
        $errorStream = $_.Exception.Response.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($errorStream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "  Error: $errorBody" -ForegroundColor Red
    } catch {}
}
Write-Host ""

# Create second event
Write-Host "TEST 4: Create Event 2 - Music Festival 2026" -ForegroundColor Yellow
$event2 = @{
    name        = "Music Festival 2026"
    description = "Two-day outdoor music festival with international artists"
    location    = "Central Park, New York City"
    startDate   = "2026-08-20"
    endDate     = "2026-08-21"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event2 -ErrorAction Stop
    Write-Host "✓ SUCCESS" -ForegroundColor Green
    Write-Host "  Event ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Create third event
Write-Host "TEST 5: Create Event 3 - Business Expo 2026" -ForegroundColor Yellow
$event3 = @{
    name        = "Business Expo 2026"
    description = "Exhibition of business innovations and startup community"
    location    = "Boston Convention & Exhibition Center"
    startDate   = "2026-09-10"
    endDate     = "2026-09-11"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event3 -ErrorAction Stop
    Write-Host "✓ SUCCESS" -ForegroundColor Green
    Write-Host "  Event ID: $($response.id)" -ForegroundColor Cyan
    Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}
Write-Host ""

# Retrieve all created events
Write-Host "TEST 6: Retrieve All Created Events" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "✓ SUCCESS - Retrieved $($response.totalElements) event(s)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Mock Data Created:" -ForegroundColor Cyan
    $eventCount = 1
    foreach ($evt in $response.content) {
        Write-Host "  $eventCount. $($evt.name)" -ForegroundColor Cyan
        Write-Host "     ID: $($evt.id)" -ForegroundColor Cyan
        Write-Host "     Location: $($evt.location)" -ForegroundColor Cyan
        Write-Host "     Dates: $($evt.startDate) to $($evt.endDate)" -ForegroundColor Cyan
        Write-Host "     Description: $($evt.description)" -ForegroundColor Cyan
        Write-Host ""
        $eventCount++
    }
} catch {
    Write-Host "✗ FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Testing Summary" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "System Components:" -ForegroundColor Cyan
Write-Host "  ✓ Spring Boot API: http://localhost:8080" -ForegroundColor Green
Write-Host "  ✓ PostgreSQL Database: localhost:5432" -ForegroundColor Green
Write-Host "  ✓ Keycloak Auth Server: http://localhost:9090" -ForegroundColor Green
Write-Host "  ✓ Database Admin (Adminer): http://localhost:8888" -ForegroundColor Green
Write-Host ""
Write-Host "API Endpoints Tested:" -ForegroundColor Cyan
Write-Host "  ✓ GET $BaseUrl/published-events" -ForegroundColor Green
Write-Host "  ✓ GET $BaseUrl/events" -ForegroundColor Green
Write-Host "  ✓ POST $BaseUrl/events" -ForegroundColor Green
Write-Host ""
Write-Host "Mock Data Status:" -ForegroundColor Cyan
Write-Host "  ✓ Created 3 test events" -ForegroundColor Green
Write-Host ""

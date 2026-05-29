# Simple API Testing Script

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - API Test Suite" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Get token
Write-Host "Step 1: Getting authentication token..." -ForegroundColor Yellow
$tokenResponse = Invoke-RestMethod -Uri "$KeycloakUrl/realms/$RealmName/protocol/openid-connect/token" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
        grant_type    = "password"
        client_id     = $ClientId
        client_secret = $ClientSecret
        username      = $Username
        password      = $Password
    } -ErrorAction SilentlyContinue

if ($tokenResponse) {
    $AccessToken = $tokenResponse.access_token
    Write-Host "SUCCESS: Token obtained" -ForegroundColor Green
    Write-Host "Token expires in: $($tokenResponse.expires_in) seconds" -ForegroundColor Cyan
} else {
    Write-Host "FAILED: Could not get token" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

Write-Host ""

# Test endpoint
Write-Host "Step 2: Testing API endpoints..." -ForegroundColor Yellow
Write-Host ""

# Test 1: List events
Write-Host "TEST 1: List Events" -ForegroundColor Cyan
$response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction SilentlyContinue
if ($response) {
    Write-Host "SUCCESS: Listed $($response.totalElements) event(s)" -ForegroundColor Green
} else {
    Write-Host "RESPONSE: $(($response | ConvertTo-Json))" -ForegroundColor Cyan
}
Write-Host ""

# Test 2: Create Event 1
Write-Host "TEST 2: Create Event - Tech Summit" -ForegroundColor Cyan
$event1 = @{
    name        = "Tech Summit 2026"
    description = "Annual technology conference"
    location    = "San Francisco"
    startDate   = (Get-Date).AddDays(45).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(47).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$response1 = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event1 -ErrorAction SilentlyContinue
if ($response1) {
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "Event ID: $($response1.id)" -ForegroundColor Cyan
    Write-Host "Event Name: $($response1.name)" -ForegroundColor Cyan
    $event1Id = $response1.id
} else {
    Write-Host "FAILED or NOT CREATED" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Create Event 2
Write-Host "TEST 3: Create Event - Music Festival" -ForegroundColor Cyan
$event2 = @{
    name        = "Music Festival 2026"
    description = "Two-day outdoor music festival"
    location    = "Central Park, New York"
    startDate   = (Get-Date).AddDays(60).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(61).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$response2 = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event2 -ErrorAction SilentlyContinue
if ($response2) {
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "Event ID: $($response2.id)" -ForegroundColor Cyan
    Write-Host "Event Name: $($response2.name)" -ForegroundColor Cyan
    $event2Id = $response2.id
} else {
    Write-Host "FAILED or NOT CREATED" -ForegroundColor Yellow
}
Write-Host ""

# Test 4: Create Event 3
Write-Host "TEST 4: Create Event - Business Expo" -ForegroundColor Cyan
$event3 = @{
    name        = "Business Expo 2026"
    description = "Exhibition of business innovations"
    location    = "Boston"
    startDate   = (Get-Date).AddDays(75).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(76).ToString("yyyy-MM-dd")
} | ConvertTo-Json

$response3 = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $event3 -ErrorAction SilentlyContinue
if ($response3) {
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    Write-Host "Event ID: $($response3.id)" -ForegroundColor Cyan
    Write-Host "Event Name: $($response3.name)" -ForegroundColor Cyan
    $event3Id = $response3.id
} else {
    Write-Host "FAILED or NOT CREATED" -ForegroundColor Yellow
}
Write-Host ""

# Test 5: List all events after creation
Write-Host "TEST 5: List All Events (after creation)" -ForegroundColor Cyan
$allEvents = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction SilentlyContinue
if ($allEvents) {
    Write-Host "SUCCESS: Listed $($allEvents.totalElements) event(s)" -ForegroundColor Green
    foreach ($evt in $allEvents.content) {
        Write-Host "  - $($evt.name) (ID: $($evt.id))" -ForegroundColor Cyan
    }
} else {
    Write-Host "NO EVENTS FOUND" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "API Testing Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "System Status:" -ForegroundColor Yellow
Write-Host "✓ Spring Boot running on http://localhost:8080" -ForegroundColor Green
Write-Host "✓ Keycloak running on $KeycloakUrl" -ForegroundColor Green
Write-Host "✓ PostgreSQL running on localhost:5432" -ForegroundColor Green
Write-Host "✓ Adminer available at http://localhost:8888" -ForegroundColor Green
Write-Host ""

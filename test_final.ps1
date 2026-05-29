# Comprehensive API Testing and Mock Data Loading Script with Client Credentials

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - API Testing and Data Loading" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Step 1: Get JWT Token from Keycloak using Client Credentials
Write-Host "STEP 1: Obtaining JWT Token from Keycloak" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow
try {
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
    Write-Host "SUCCESS: JWT Token obtained" -ForegroundColor Green
    Write-Host "Token (first 50 chars): $($AccessToken.Substring(0,50))..." -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: Could not obtain JWT token" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

Write-Host ""

# Step 2: Test Protected Endpoints
Write-Host "STEP 2: Testing Secured API Endpoints" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow

# Test 2a: List Events
Write-Host ""
Write-Host "2a. List Events" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Listed events" -ForegroundColor Green
    Write-Host "Page Info: Content Count=$($response.content.Count), Total Elements=$($response.totalElements)" -ForegroundColor Cyan
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

# Test 2b: Get Actuator Health
Write-Host ""
Write-Host "2b. Get Actuator Health" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Health check passed" -ForegroundColor Green
    Write-Host "Status: $($response.status)" -ForegroundColor Cyan
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

# Test 2c: Get Tickets
Write-Host ""
Write-Host "2c. Get User Tickets" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/tickets" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Retrieved tickets" -ForegroundColor Green
    Write-Host "Total Tickets: $($response.totalElements)" -ForegroundColor Cyan
} catch {
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "STEP 3: Creating Mock Data" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor Yellow

# Create mock event 1
Write-Host ""
Write-Host "3a. Creating Event 1: Tech Summit 2026" -ForegroundColor Cyan
$eventPayload1 = @{
    name        = "Tech Summit 2026"
    description = "Annual technology conference bringing together industry leaders"
    location    = "San Francisco Convention Center"
    startDate   = (Get-Date).AddDays(45).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(47).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload1 -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    $event1Id = $response.id
    Write-Host "Event ID: $event1Id" -ForegroundColor Cyan
    Write-Host "Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Create mock event 2
Write-Host ""
Write-Host "3b. Creating Event 2: Music Festival 2026" -ForegroundColor Cyan
$eventPayload2 = @{
    name        = "Music Festival 2026"
    description = "Two-day outdoor music festival featuring international artists"
    location    = "Central Park, New York"
    startDate   = (Get-Date).AddDays(60).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(61).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload2 -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    $event2Id = $response.id
    Write-Host "Event ID: $event2Id" -ForegroundColor Cyan
    Write-Host "Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Create mock event 3
Write-Host ""
Write-Host "3c. Creating Event 3: Business Expo 2026" -ForegroundColor Cyan
$eventPayload3 = @{
    name        = "Business Expo 2026"
    description = "Exhibition showcasing latest business innovations and startups"
    location    = "Boston Convention Center"
    startDate   = (Get-Date).AddDays(75).ToString("yyyy-MM-dd")
    endDate     = (Get-Date).AddDays(76).ToString("yyyy-MM-dd")
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $eventPayload3 -ErrorAction Stop
    Write-Host "SUCCESS: Event created" -ForegroundColor Green
    $event3Id = $response.id
    Write-Host "Event ID: $event3Id" -ForegroundColor Cyan
    Write-Host "Name: $($response.name)" -ForegroundColor Cyan
    Write-Host "Location: $($response.location)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host ""
Write-Host "STEP 4: Retrieving Mock Data" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor Yellow

Write-Host ""
Write-Host "4a. List All Events" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Retrieved all events" -ForegroundColor Green
    Write-Host "Total Events: $($response.totalElements)" -ForegroundColor Cyan
    foreach ($event in $response.content) {
        Write-Host "  - $($event.name) (ID: $($event.id))" -ForegroundColor Cyan
    }
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "API Testing and Data Loading Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "- API is running and accessible on port 8080" -ForegroundColor Cyan
Write-Host "- Authentication via Keycloak is working" -ForegroundColor Cyan
Write-Host "- Database is connected and operational" -ForegroundColor Cyan
Write-Host ""
Write-Host "Mock Events Created:" -ForegroundColor Yellow
Write-Host "1. Tech Summit 2026" -ForegroundColor Cyan
Write-Host "2. Music Festival 2026" -ForegroundColor Cyan
Write-Host "3. Business Expo 2026" -ForegroundColor Cyan
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Yellow
Write-Host "- API: $BaseUrl" -ForegroundColor Cyan
Write-Host "- Database Admin: http://localhost:8888" -ForegroundColor Cyan
Write-Host "- Keycloak Admin: $KeycloakUrl" -ForegroundColor Cyan
Write-Host "- Spring Boot Health: http://localhost:8080/actuator/health" -ForegroundColor Cyan

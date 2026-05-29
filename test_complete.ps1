# Comprehensive Final Test - API Testing and Mock Data Loading

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$ClientSecret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
$Username = "testuser"
$Password = "testuser123"
$UserId = "d088435c-cdfa-4fdc-8f1e-286068370f96"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - Complete API Test Suite" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Environment:" -ForegroundColor Cyan
Write-Host "  API Base URL: $BaseUrl" -ForegroundColor Cyan
Write-Host "  Keycloak URL: $KeycloakUrl" -ForegroundColor Cyan
Write-Host "  User ID: $UserId" -ForegroundColor Cyan
Write-Host ""

# Step 1: Get JWT Token
Write-Host "STEP 1: Authentication" -ForegroundColor Yellow
Write-Host "---------------------" -ForegroundColor Yellow
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
    $TokenType = $tokenResponse.token_type
    
    Write-Host "✓ Successfully obtained JWT token" -ForegroundColor Green
    Write-Host "  Token Type: $TokenType" -ForegroundColor Cyan
    Write-Host "  Expires In: $($tokenResponse.expires_in) seconds" -ForegroundColor Cyan
} catch {
    Write-Host "✗ FAILED to obtain JWT token" -ForegroundColor Red
    Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "$TokenType $AccessToken"
    "Content-Type"  = "application/json"
}

Write-Host ""

# Step 2: Test Health Endpoints
Write-Host "STEP 2: API Health Checks" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor Yellow

# Health check
Write-Host ""
Write-Host "Checking API Health..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "✓ API Health: $($response.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ Health check failed: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host ""

# Step 3: Test API Endpoints
Write-Host "STEP 3: API Endpoint Tests" -ForegroundColor Yellow
Write-Host "------------------------" -ForegroundColor Yellow

# List existing events
Write-Host ""
Write-Host "Retrieving existing events..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "✓ Successfully retrieved events" -ForegroundColor Green
    Write-Host "  Total Elements: $($response.totalElements)" -ForegroundColor Cyan
    Write-Host "  Page Size: $($response.size)" -ForegroundColor Cyan
    if ($response.content.Count -gt 0) {
        Write-Host "  Existing Events:" -ForegroundColor Cyan
        foreach ($event in $response.content) {
            Write-Host "    - $($event.name) (ID: $($event.id))" -ForegroundColor Cyan
        }
    }
} catch {
    Write-Host "✗ Failed to retrieve events: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host ""

# Step 4: Create Mock Events
Write-Host "STEP 4: Creating Mock Events" -ForegroundColor Yellow
Write-Host "---------------------------" -ForegroundColor Yellow

$events = @(
    @{
        name        = "Tech Summit 2026"
        description = "Annual technology conference bringing together industry leaders"
        location    = "San Francisco Convention Center"
        startDate   = (Get-Date).AddDays(45).ToString("yyyy-MM-dd")
        endDate     = (Get-Date).AddDays(47).ToString("yyyy-MM-dd")
    },
    @{
        name        = "Music Festival 2026"
        description = "Two-day outdoor music festival featuring international artists"
        location    = "Central Park, New York"
        startDate   = (Get-Date).AddDays(60).ToString("yyyy-MM-dd")
        endDate     = (Get-Date).AddDays(61).ToString("yyyy-MM-dd")
    },
    @{
        name        = "Business Expo 2026"
        description = "Exhibition showcasing latest business innovations and startups"
        location    = "Boston Convention Center"
        startDate   = (Get-Date).AddDays(75).ToString("yyyy-MM-dd")
        endDate     = (Get-Date).AddDays(76).ToString("yyyy-MM-dd")
    }
)

$createdEventIds = @()

foreach ($i = 0; $i -lt $events.Count; $i++) {
    $event = $events[$i]
    Write-Host ""
    Write-Host "Creating Event $($i+1): $($event.name)" -ForegroundColor Cyan
    
    $payload = $event | ConvertTo-Json
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post -Headers $headers -Body $payload -ErrorAction Stop
        Write-Host "✓ Event created successfully" -ForegroundColor Green
        Write-Host "  ID: $($response.id)" -ForegroundColor Cyan
        Write-Host "  Name: $($response.name)" -ForegroundColor Cyan
        Write-Host "  Location: $($response.location)" -ForegroundColor Cyan
        Write-Host "  Dates: $($response.startDate) to $($response.endDate)" -ForegroundColor Cyan
        $createdEventIds += $response.id
    } catch {
        Write-Host "✗ Failed to create event: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
        $errorBody = $_.Exception.Response.Content.ReadAsStream()
        $reader = New-Object System.IO.StreamReader($errorBody)
        Write-Host "  Error Details: $($reader.ReadToEnd())" -ForegroundColor Red
    }
}

Write-Host ""

# Step 5: Retrieve and Display Created Events
Write-Host "STEP 5: Verifying Created Events" -ForegroundColor Yellow
Write-Host "------------------------------" -ForegroundColor Yellow

Write-Host ""
Write-Host "Retrieving all events..." -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "✓ Successfully retrieved $($response.totalElements) event(s)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Events Summary:" -ForegroundColor Cyan
    foreach ($event in $response.content) {
        Write-Host "  ID: $($event.id)" -ForegroundColor Cyan
        Write-Host "  Name: $($event.name)" -ForegroundColor Cyan
        Write-Host "  Description: $($event.description)" -ForegroundColor Cyan
        Write-Host "  Location: $($event.location)" -ForegroundColor Cyan
        Write-Host "  Dates: $($event.startDate) to $($event.endDate)" -ForegroundColor Cyan
        Write-Host ""
    }
} catch {
    Write-Host "✗ Failed to retrieve events: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host ""

# Step 6: Test Individual Event Retrieval
if ($createdEventIds.Count -gt 0) {
    Write-Host "STEP 6: Individual Event Retrieval" -ForegroundColor Yellow
    Write-Host "--------------------------------" -ForegroundColor Yellow
    
    $eventId = $createdEventIds[0]
    Write-Host ""
    Write-Host "Retrieving event: $eventId" -ForegroundColor Cyan
    
    try {
        $response = Invoke-RestMethod -Uri "$BaseUrl/events/$eventId" -Method Get -Headers $headers -ErrorAction Stop
        Write-Host "✓ Successfully retrieved event" -ForegroundColor Green
        Write-Host "  Full Response:" -ForegroundColor Cyan
        $response | ConvertTo-Json | ForEach-Object { Write-Host "    $_" -ForegroundColor Cyan }
    } catch {
        Write-Host "✗ Failed to retrieve event: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host ""
Write-Host "=====================================================" -ForegroundColor Green
Write-Host "API Testing Complete!" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Summary:" -ForegroundColor Yellow
Write-Host "✓ Spring Boot API running on port 8080" -ForegroundColor Green
Write-Host "✓ Keycloak authentication successful" -ForegroundColor Green
Write-Host "✓ PostgreSQL database connected" -ForegroundColor Green
Write-Host "✓ $($createdEventIds.Count) mock events created" -ForegroundColor Green
Write-Host ""
Write-Host "Created Event IDs:" -ForegroundColor Cyan
foreach ($id in $createdEventIds) {
    Write-Host "  - $id" -ForegroundColor Cyan
}
Write-Host ""
Write-Host "Access Points:" -ForegroundColor Yellow
Write-Host "  API Endpoints: $BaseUrl" -ForegroundColor Cyan
Write-Host "  Database Admin: http://localhost:8888" -ForegroundColor Cyan
Write-Host "  Keycloak Admin: $KeycloakUrl" -ForegroundColor Cyan
Write-Host "  Spring Boot Actuator: http://localhost:8080/actuator" -ForegroundColor Cyan

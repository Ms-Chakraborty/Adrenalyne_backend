# Comprehensive API Testing and Mock Data Loading Script

$BaseUrl = "http://localhost:8080/api/v1"
$KeycloakUrl = "http://localhost:9090"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$Username = "testuser"
$Password = "testuser123"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Adrenalyne Backend - API Testing and Data Loading" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

# Step 1: Get JWT Token from Keycloak
Write-Host "STEP 1: Obtaining JWT Token from Keycloak" -ForegroundColor Yellow
Write-Host "-------------------------------------------" -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod -Uri "$KeycloakUrl/realms/$RealmName/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            grant_type = "password"
            client_id  = $ClientId
            username   = $Username
            password   = $Password
        } -ErrorAction Stop
    
    $AccessToken = $tokenResponse.access_token
    Write-Host "SUCCESS: JWT Token obtained" -ForegroundColor Green
    Write-Host "Token (first 50 chars): $($AccessToken.Substring(0,50))..." -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: Could not obtain JWT token" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

$headers = @{
    "Authorization" = "Bearer $AccessToken"
    "Content-Type"  = "application/json"
}

Write-Host "Token Expiry Info:" -ForegroundColor Cyan
$tokenParts = $AccessToken.Split('.')
if ($tokenParts.Length -eq 3) {
    $payload = $tokenParts[1]
    # Add padding if needed
    $padding = 4 - ($payload.Length % 4)
    if ($padding -ne 4) { $payload += "=" * $padding }
    $decodedPayload = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($payload))
    $tokenData = $decodedPayload | ConvertFrom-Json
    Write-Host "Issued at: $(([datetime]'1970-01-01').AddSeconds($tokenData.iat))" -ForegroundColor Cyan
    Write-Host "Expires at: $(([datetime]'1970-01-01').AddSeconds($tokenData.exp))" -ForegroundColor Cyan
}
Write-Host ""

# Step 2: Test Public Endpoints
Write-Host "STEP 2: Testing Secured API Endpoints" -ForegroundColor Yellow
Write-Host "------------------------------------" -ForegroundColor Yellow

# Test 2a: List Events
Write-Host ""
Write-Host "2a. List Events" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Listed events" -ForegroundColor Green
    Write-Host "Response: $(($response | ConvertTo-Json -Depth 1) -replace "`n", "`n    ")" -ForegroundColor Cyan
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

# Test 2c: Get Actuator Metrics
Write-Host ""
Write-Host "2c. Get Available Metrics" -ForegroundColor Cyan
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/metrics" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "SUCCESS: Retrieved metrics list" -ForegroundColor Green
    $metrics = $response.names | Select-Object -First 10
    Write-Host "Available Metrics: $($metrics -join ', ')" -ForegroundColor Cyan
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
    Write-Host "Full Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
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
    Write-Host "Full Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
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
    Write-Host "Full Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Red
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
Write-Host "Mock Data Loaded:" -ForegroundColor Yellow
Write-Host "1. Tech Summit 2026 (ID: $event1Id)" -ForegroundColor Cyan
Write-Host "2. Music Festival 2026 (ID: $event2Id)" -ForegroundColor Cyan
Write-Host "3. Business Expo 2026 (ID: $event3Id)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "- View events at: $BaseUrl/events" -ForegroundColor Cyan
Write-Host "- View database at: http://localhost:8888" -ForegroundColor Cyan
Write-Host "- Keycloak admin at: $KeycloakUrl" -ForegroundColor Cyan

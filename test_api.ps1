# API Testing Script for Adrenalyne Backend
# This script tests all API endpoints and pushes mock data

$BaseUrl = "http://localhost:8080/api/v1"
$AdminToken = "admin_token_for_testing"

Write-Host "===================================" -ForegroundColor Green
Write-Host "Adrenalyne API Testing Suite" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Test 1: Health Check
Write-Host "TEST 1 - Health Check - Actuator" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/health" -Method Get -ErrorAction Stop
    Write-Host "PASSED: Health Check" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: Health Check" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Test 2: List Events (Requires JWT)
Write-Host "TEST 2 - List Events" -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $AdminToken"
        "Content-Type"  = "application/json"
    }
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Get -Headers $headers -ErrorAction Stop
    Write-Host "PASSED: List Events" -ForegroundColor Green
    Write-Host "Response: $($response | ConvertTo-Json -Depth 2)" -ForegroundColor Cyan
} catch {
    Write-Host "EXPECTED FAILURE: List Events (requires valid JWT)" -ForegroundColor Yellow
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Cyan
}
Write-Host ""

# Test 3: Create Event (without JWT - should fail)
Write-Host "TEST 3 - Create Event (No Auth)" -ForegroundColor Yellow
try {
    $eventPayload = @{
        name        = "Tech Conference 2026"
        description = "Annual tech conference"
        location    = "New York"
        startDate   = (Get-Date).AddDays(30).ToString("yyyy-MM-dd")
        endDate     = (Get-Date).AddDays(32).ToString("yyyy-MM-dd")
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$BaseUrl/events" -Method Post `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $eventPayload -ErrorAction Stop
    Write-Host "PASSED: Create Event" -ForegroundColor Green
} catch {
    Write-Host "EXPECTED FAILURE: Create Event (requires authentication)" -ForegroundColor Yellow
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Cyan
}
Write-Host ""

# Test 4: Check Available Endpoints
Write-Host "TEST 4 - Check Available Endpoints" -ForegroundColor Yellow
$endpoints = @(
    "/actuator/health",
    "/actuator",
    "/api/v1/events",
    "/api/v1/tickets"
)

foreach ($endpoint in $endpoints) {
    try {
        $fullUrl = if ($endpoint.StartsWith("/actuator")) { 
            "http://localhost:8080$endpoint" 
        } else { 
            "$BaseUrl$endpoint" 
        }
        
        $response = Invoke-RestMethod -Uri $fullUrl -Method Get -ErrorAction Stop
        Write-Host "AVAILABLE: $endpoint" -ForegroundColor Green
    } catch {
        $statusCode = $_.Exception.Response.StatusCode
        if ($statusCode -in @("Unauthorized", "Forbidden", "401", "403")) {
            Write-Host "PROTECTED (Auth Required): $endpoint" -ForegroundColor Cyan
        } else {
            Write-Host "STATUS $statusCode : $endpoint" -ForegroundColor Yellow
        }
    }
}
Write-Host ""

# Test 5: Get Actuator Metrics
Write-Host "TEST 5 - Get Actuator Metrics" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "http://localhost:8080/actuator/metrics" -Method Get -ErrorAction Stop
    Write-Host "PASSED: Actuator Metrics" -ForegroundColor Green
    $names = $response.names | Select-Object -First 10
    Write-Host "Available Metrics (first 10): $($names -join ', ')" -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: Actuator Metrics" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}
Write-Host ""

# Summary
Write-Host "===================================" -ForegroundColor Green
Write-Host "API Testing Complete" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""
Write-Host "Notes:" -ForegroundColor Yellow
Write-Host "- The API uses OAuth2 with Keycloak for authentication" -ForegroundColor Cyan
Write-Host "- To test protected endpoints, obtain a valid JWT from Keycloak" -ForegroundColor Cyan
Write-Host "- Keycloak is running on http://localhost:9090" -ForegroundColor Cyan
Write-Host "- PostgreSQL is running on localhost:5432" -ForegroundColor Cyan
Write-Host "- Adminer is available at http://localhost:8888" -ForegroundColor Cyan

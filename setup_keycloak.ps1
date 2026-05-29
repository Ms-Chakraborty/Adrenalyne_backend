# Script to setup Keycloak realm and get JWT token
# This creates the necessary Keycloak configuration for testing

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"

Write-Host "Setting up Keycloak Configuration" -ForegroundColor Green
Write-Host "===================================" -ForegroundColor Green
Write-Host ""

# Step 1: Get admin token
Write-Host "Step 1: Getting Keycloak Admin Token..." -ForegroundColor Yellow
try {
    $tokenResponse = Invoke-RestMethod -Uri "$KeycloakUrl/realms/master/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            grant_type = "password"
            client_id  = "admin-cli"
            username   = $AdminUser
            password   = $AdminPassword
        } -ErrorAction Stop
    
    $AdminAccessToken = $tokenResponse.access_token
    Write-Host "SUCCESS: Got Admin Token" -ForegroundColor Green
    Write-Host "Token (first 50 chars): $($AdminAccessToken.Substring(0,50))..." -ForegroundColor Cyan
} catch {
    Write-Host "FAILED: Could not get admin token" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "This is expected if Keycloak is still starting up." -ForegroundColor Yellow
    exit 1
}
Write-Host ""

# Step 2: Check if realm exists
Write-Host "Step 2: Checking if realm exists..." -ForegroundColor Yellow
try {
    $headers = @{
        "Authorization" = "Bearer $AdminAccessToken"
        "Content-Type"  = "application/json"
    }
    
    $realmResponse = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName" `
        -Method Get `
        -Headers $headers -ErrorAction Stop
    
    Write-Host "FOUND: Realm '$RealmName' already exists" -ForegroundColor Green
} catch {
    Write-Host "NOT FOUND: Realm needs to be created" -ForegroundColor Yellow
}
Write-Host ""

# Step 3: Get or create a user token
Write-Host "Step 3: Attempting to get user token from realm..." -ForegroundColor Yellow
try {
    $userTokenResponse = Invoke-RestMethod -Uri "$KeycloakUrl/realms/$RealmName/protocol/openid-connect/token" `
        -Method Post `
        -ContentType "application/x-www-form-urlencoded" `
        -Body @{
            grant_type = "password"
            client_id  = $ClientId
            username   = "testuser"
            password   = "testuser123"
        } -ErrorAction Stop
    
    $UserAccessToken = $userTokenResponse.access_token
    Write-Host "SUCCESS: Got User Token" -ForegroundColor Green
    Write-Host "Token (first 50 chars): $($UserAccessToken.Substring(0,50))..." -ForegroundColor Cyan
} catch {
    Write-Host "INFO: Could not get user token (realm may not be fully configured)" -ForegroundColor Yellow
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Manual Setup Required:" -ForegroundColor Yellow
    Write-Host "1. Open http://localhost:9090" -ForegroundColor Cyan
    Write-Host "2. Log in with: admin / admin" -ForegroundColor Cyan
    Write-Host "3. Create realm: $RealmName" -ForegroundColor Cyan
    Write-Host "4. Create client: $ClientId" -ForegroundColor Cyan
    Write-Host "5. Create user: testuser / testuser123" -ForegroundColor Cyan
}
Write-Host ""

# Export tokens for use in other scripts
Write-Host "Token Information:" -ForegroundColor Green
Write-Host "Admin Token: $AdminAccessToken" -ForegroundColor Cyan

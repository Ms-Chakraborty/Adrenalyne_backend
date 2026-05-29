# Script to create Keycloak realm and setup OAuth configuration

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"

Write-Host "Creating Keycloak Realm and Configuration" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Step 1: Get admin token
Write-Host "Getting admin token..." -ForegroundColor Cyan
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
$headers = @{
    "Authorization" = "Bearer $AdminAccessToken"
    "Content-Type"  = "application/json"
}

Write-Host "SUCCESS: Got admin token" -ForegroundColor Green
Write-Host ""

# Step 2: Create realm
Write-Host "Creating realm: $RealmName" -ForegroundColor Yellow
try {
    $realmPayload = @{
        id           = $RealmName
        realm        = $RealmName
        displayName  = "Event Ticket Platform"
        enabled      = $true
        accessTokenLifespan = 3600
    } | ConvertTo-Json
    
    $response = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms" `
        -Method Post `
        -Headers $headers `
        -Body $realmPayload -ErrorAction Stop
    
    Write-Host "SUCCESS: Realm created" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "INFO: Realm already exists" -ForegroundColor Yellow
    } else {
        Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    }
}
Write-Host ""

# Step 3: Create client
Write-Host "Creating client: $ClientId" -ForegroundColor Yellow
try {
    $clientPayload = @{
        clientId    = $ClientId
        name        = "Tickets App"
        enabled     = $true
        protocol    = "openid-connect"
        publicClient = $false
        redirectUris = @(
            "http://localhost:3000/*",
            "http://localhost:8080/*"
        )
    } | ConvertTo-Json -Depth 5
    
    $response = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/clients" `
        -Method Post `
        -Headers $headers `
        -Body $clientPayload -ErrorAction Stop
    
    Write-Host "SUCCESS: Client created" -ForegroundColor Green
    $clientData = $response | ConvertFrom-Json -ErrorAction SilentlyContinue
} catch {
    Write-Host "INFO: Client creation - $($_.Exception.Message)" -ForegroundColor Yellow
}
Write-Host ""

# Step 4: Create test user
Write-Host "Creating test user: testuser" -ForegroundColor Yellow
try {
    $userPayload = @{
        username       = "testuser"
        email          = "testuser@example.com"
        firstName      = "Test"
        lastName       = "User"
        enabled        = $true
        credentials    = @(
            @{
                type  = "password"
                value = "testuser123"
            }
        )
    } | ConvertTo-Json -Depth 5
    
    $response = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users" `
        -Method Post `
        -Headers $headers `
        -Body $userPayload -ErrorAction Stop
    
    Write-Host "SUCCESS: User created" -ForegroundColor Green
} catch {
    if ($_.Exception.Response.StatusCode -eq 409) {
        Write-Host "INFO: User already exists" -ForegroundColor Yellow
    } else {
        Write-Host "INFO: User creation - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "Keycloak setup complete!" -ForegroundColor Green
Write-Host "You can now test the API with the following credentials:" -ForegroundColor Cyan
Write-Host "Username: testuser" -ForegroundColor Cyan
Write-Host "Password: testuser123" -ForegroundColor Cyan
Write-Host "Keycloak Admin Console: $KeycloakUrl" -ForegroundColor Cyan

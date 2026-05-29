# Script to get client credentials and fix authentication

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"

Write-Host "Setting up Client Credentials" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

# Get admin token
Write-Host "Getting admin token..." -ForegroundColor Yellow
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

Write-Host "Got admin token successfully" -ForegroundColor Green
Write-Host ""

# Get client ID
Write-Host "Getting client details..." -ForegroundColor Yellow
$clientList = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/clients?clientId=$ClientId" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

if ($clientList.Count -gt 0) {
    $clientUUID = $clientList[0].id
    Write-Host "Found client UUID: $clientUUID" -ForegroundColor Green
    
    # Get client secrets
    Write-Host ""
    Write-Host "Getting client secret..." -ForegroundColor Yellow
    $clientSecret = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/clients/$clientUUID/client-secret" `
        -Method Get `
        -Headers $headers -ErrorAction Stop
    
    Write-Host "Client ID: $ClientId" -ForegroundColor Green
    Write-Host "Client Secret: $($clientSecret.value)" -ForegroundColor Green
    Write-Host ""
    Write-Host "Now try authentication with these credentials" -ForegroundColor Cyan
    
} else {
    Write-Host "ERROR: Client not found" -ForegroundColor Red
}

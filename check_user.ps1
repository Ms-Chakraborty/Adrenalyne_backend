# Script to configure user in Keycloak properly

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$ClientId = "tickets-app"
$Username = "testuser"

Write-Host "Configuring Keycloak User" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
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

Write-Host "Got admin token" -ForegroundColor Green
Write-Host ""

# Get user by username
Write-Host "Fetching user: $Username" -ForegroundColor Yellow
$users = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=$Username" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

if ($users.Count -gt 0) {
    $user = $users[0]
    $userId = $user.id
    Write-Host "Found user: $Username (ID: $userId)" -ForegroundColor Green
    Write-Host "User attributes:" -ForegroundColor Cyan
    $user | ConvertTo-Json | ForEach-Object { Write-Host $_ -ForegroundColor Cyan }
} else {
    Write-Host "ERROR: User not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "User ID can be used in the application" -ForegroundColor Green

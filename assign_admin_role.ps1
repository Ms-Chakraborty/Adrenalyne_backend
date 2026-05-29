# Script to assign ADMIN role to testuser

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$Username = "testuser"
$RoleName = "admin"

Write-Host "Assigning Admin Role to User" -ForegroundColor Green
Write-Host "============================" -ForegroundColor Green
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

# Get realm roles
Write-Host "Fetching realm roles..." -ForegroundColor Yellow
$rolesResponse = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

$adminRole = $rolesResponse | Where-Object { $_.name -eq $RoleName }

if ($null -eq $adminRole) {
    Write-Host "Admin role not found, creating it..." -ForegroundColor Cyan
    $rolePayload = @{
        name        = $RoleName
        description = "Administrator role"
    } | ConvertTo-Json
    
    $createRoleResponse = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" `
        -Method Post `
        -Headers $headers `
        -Body $rolePayload -ErrorAction Stop
    
    Write-Host "Admin role created" -ForegroundColor Green
} else {
    Write-Host "Admin role found" -ForegroundColor Green
}

# Get user
Write-Host ""
Write-Host "Fetching user: $Username" -ForegroundColor Yellow
$users = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=$Username" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

if ($users.Count -gt 0) {
    $user = $users[0]
    $userId = $user.id
    Write-Host "Found user: $Username (ID: $userId)" -ForegroundColor Green
} else {
    Write-Host "ERROR: User not found" -ForegroundColor Red
    exit 1
}

# Get admin role again (in case it was just created)
$rolesResponse = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

$adminRole = $rolesResponse | Where-Object { $_.name -eq $RoleName }

if ($null -eq $adminRole) {
    Write-Host "ERROR: Admin role not found after creation" -ForegroundColor Red
    exit 1
}

$roleId = $adminRole.id
Write-Host "Admin role ID: $roleId" -ForegroundColor Cyan

# Assign role to user
Write-Host ""
Write-Host "Assigning admin role to user..." -ForegroundColor Yellow
$roleAssignmentPayload = @(
    @{
        id   = $roleId
        name = $RoleName
    }
) | ConvertTo-Json

$assignResponse = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" `
    -Method Post `
    -Headers $headers `
    -Body $roleAssignmentPayload -ErrorAction Stop

Write-Host "SUCCESS: Admin role assigned to user" -ForegroundColor Green
Write-Host ""
Write-Host "User $Username now has the admin role" -ForegroundColor Cyan
Write-Host "Try authenticating again to get updated token" -ForegroundColor Cyan

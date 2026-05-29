# Properly assign admin role using Keycloak Admin API

$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"
$Username = "testuser"

Write-Host "Keycloak Role Assignment" -ForegroundColor Green
Write-Host "=======================" -ForegroundColor Green
Write-Host ""

# Get admin token
Write-Host "Step 1: Get admin token" -ForegroundColor Yellow
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
Write-Host "SUCCESS" -ForegroundColor Green
Write-Host ""

# Get user
Write-Host "Step 2: Get user by username" -ForegroundColor Yellow
$users = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=$Username&exact=true" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

if ($users.Count -eq 0) {
    Write-Host "FAILED: User not found" -ForegroundColor Red
    exit 1
}

$user = $users[0]
$userId = $user.id
Write-Host "SUCCESS: Found user $Username" -ForegroundColor Green
Write-Host "  ID: $userId" -ForegroundColor Cyan
Write-Host ""

# Get available realm roles
Write-Host "Step 3: Get available realm roles" -ForegroundColor Yellow
$realmRoles = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

Write-Host "SUCCESS: Found $(($realmRoles | Measure-Object).Count) realm role(s)" -ForegroundColor Green
foreach ($role in $realmRoles) {
    Write-Host "  - $($role.name)" -ForegroundColor Cyan
}
Write-Host ""

# Get or create admin role
Write-Host "Step 4: Ensure admin role exists" -ForegroundColor Yellow
$adminRole = $realmRoles | Where-Object { $_.name -eq "admin" }

if ($null -eq $adminRole) {
    Write-Host "Creating admin role..." -ForegroundColor Cyan
    $rolePayload = @{
        name        = "admin"
        description = "Administrator role"
    } | ConvertTo-Json
    
    Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" `
        -Method Post `
        -Headers $headers `
        -Body $rolePayload -ErrorAction Stop
    
    Write-Host "Admin role created" -ForegroundColor Green
    $adminRole = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/admin" `
        -Method Get `
        -Headers $headers -ErrorAction Stop
} else {
    Write-Host "Admin role found" -ForegroundColor Green
}
Write-Host "  ID: $($adminRole.id)" -ForegroundColor Cyan
Write-Host ""

# Get effective roles for user
Write-Host "Step 5: Check current roles for user" -ForegroundColor Yellow
$effectiveRoles = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

Write-Host "Current roles:" -ForegroundColor Cyan
if ($effectiveRoles -and $effectiveRoles.Count -gt 0) {
    foreach ($role in $effectiveRoles) {
        Write-Host "  - $($role.name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  (no roles assigned)" -ForegroundColor Yellow
}
Write-Host ""

# Assign admin role
Write-Host "Step 6: Assign admin role to user" -ForegroundColor Yellow
$roleAssignmentPayload = @(
    @{
        id   = $adminRole.id
        name = "admin"
    }
) | ConvertTo-Json

Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" `
    -Method Post `
    -Headers $headers `
    -Body $roleAssignmentPayload -ErrorAction Stop

Write-Host "SUCCESS: Role assigned" -ForegroundColor Green
Write-Host ""

# Verify assignment
Write-Host "Step 7: Verify role assignment" -ForegroundColor Yellow
$effectiveRoles = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" `
    -Method Get `
    -Headers $headers -ErrorAction Stop

Write-Host "Current roles:" -ForegroundColor Cyan
if ($effectiveRoles -and $effectiveRoles.Count -gt 0) {
    foreach ($role in $effectiveRoles) {
        Write-Host "  - $($role.name)" -ForegroundColor Cyan
    }
} else {
    Write-Host "  (no roles found)" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Admin role has been successfully assigned!" -ForegroundColor Green
Write-Host "User can now authenticate and access the admin API" -ForegroundColor Green

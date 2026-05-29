# Create demo Keycloak users and assign roles, then insert matching app DB rows
$KeycloakUrl = "http://localhost:9090"
$AdminUser = "admin"
$AdminPassword = "admin"
$RealmName = "event-ticket-platform"

$users = @(
    @{ username = 'admin_user'; password = 'AdminPass123!'; firstName='Admin'; lastName='User'; email='admin_user@example.com'; role='admin' },
    @{ username = 'attendee_user'; password = 'AttendeePass123!'; firstName='Attendee'; lastName='User'; email='attendee_user@example.com'; role='attendee' },
    @{ username = 'validator_user'; password = 'ValidatorPass123!'; firstName='Validator'; lastName='User'; email='validator_user@example.com'; role='validator' }
)

function Get-AdminToken {
    $resp = Invoke-RestMethod -Uri "$KeycloakUrl/realms/master/protocol/openid-connect/token" -Method Post -ContentType 'application/x-www-form-urlencoded' -Body @{ grant_type='password'; client_id='admin-cli'; username=$AdminUser; password=$AdminPassword }
    return $resp.access_token
}

$AdminToken = Get-AdminToken
$headers = @{ Authorization = "Bearer $AdminToken"; 'Content-Type' = 'application/json' }

# Ensure roles exist in realm
$existingRoles = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" -Method Get -Headers $headers
$roleNames = $existingRoles | ForEach-Object { $_.name }

foreach ($u in $users) {
    if (-not ($roleNames -contains $u.role)) {
        Write-Host "Creating realm role: $($u.role)"
        $payload = @{ name = $u.role } | ConvertTo-Json
        Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles" -Method Post -Headers $headers -Body $payload
    } else { Write-Host "Role exists: $($u.role)" }
}

# Create or get users, then assign role and collect IDs
$createdUsers = @()
foreach ($u in $users) {
    Write-Host "Processing user: $($u.username)"
    # Check if user exists
    $found = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=$($u.username)" -Method Get -Headers $headers
    if ($found.Count -gt 0) {
        $userId = $found[0].id
        Write-Host "User exists: $($u.username) -> $userId"
    } else {
        $userPayload = @{
            username = $u.username
            email = $u.email
            firstName = $u.firstName
            lastName = $u.lastName
            enabled = $true
            credentials = @(@{ type='password'; value=$u.password; temporary=$false })
        } | ConvertTo-Json -Depth 6
        Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users" -Method Post -Headers $headers -Body $userPayload
        Start-Sleep -Milliseconds 500
        $found = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users?username=$($u.username)" -Method Get -Headers $headers
        $userId = $found[0].id
        Write-Host "Created user: $($u.username) -> $userId"
    }

    # Assign realm role
    $role = Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/roles/$($u.role)" -Method Get -Headers $headers
    $assignment = @($role) | ConvertTo-Json
    Invoke-RestMethod -Uri "$KeycloakUrl/admin/realms/$RealmName/users/$userId/role-mappings/realm" -Method Post -Headers $headers -Body $assignment
    Write-Host "Assigned role $($u.role) to $($u.username)"

    $createdUsers += @{ username=$u.username; password=$u.password; id=$userId; role=$u.role }
}

# Insert matching rows into application DB (public.users)
# Find postgres container name (assumes docker-compose used name with 'db' service)
$container = (docker ps --filter "ancestor=postgres" --format "{{.Names}}" | Select-Object -First 1)
if (-not $container) { Write-Host "No postgres container found. Insert DB rows manually."; exit 0 }
Write-Host "Using Postgres container: $container"

foreach ($cu in $createdUsers) {
    $id = $cu.id
    $username = $cu.username
    $email = "$username@example.com"
    $name = "$($cu.username)"
    $sql = "INSERT INTO public.users (id, created_at, email, name, updated_at) VALUES ('$id'::uuid, NOW(), '$email', '$name', NOW()) ON CONFLICT (id) DO NOTHING;"
    $sql | docker exec -i $container psql -U postgres -d postgres
    Write-Host "Inserted app user row for $username"
}

# Output created accounts
Write-Host "\nCREATED ACCOUNTS:" -ForegroundColor Green
foreach ($cu in $createdUsers) { Write-Host "$($cu.username) | $($cu.password) | id=$($cu.id) | role=$($cu.role)" }

# Manual setup guide for Keycloak

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Manual Keycloak Configuration Guide" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "To manually add the admin role to testuser:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Open Keycloak Admin Console:" -ForegroundColor Cyan
Write-Host "   http://localhost:9090" -ForegroundColor Green
Write-Host ""
Write-Host "2. Login with:" -ForegroundColor Cyan
Write-Host "   Username: admin" -ForegroundColor Green
Write-Host "   Password: admin" -ForegroundColor Green
Write-Host ""
Write-Host "3. Navigate to realm: event-ticket-platform" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Go to Users, select 'testuser'" -ForegroundColor Cyan
Write-Host ""
Write-Host "5. Go to 'Role mapping' tab" -ForegroundColor Cyan
Write-Host ""
Write-Host "6. Click 'Assign role'" -ForegroundColor Cyan
Write-Host ""
Write-Host "7. Select 'admin' role and assign" -ForegroundColor Cyan
Write-Host ""
Write-Host "8. The testuser will now have the admin role" -ForegroundColor Cyan
Write-Host ""
Write-Host "After assigning the role, re-authenticate to get a new token" -ForegroundColor Yellow
Write-Host ""

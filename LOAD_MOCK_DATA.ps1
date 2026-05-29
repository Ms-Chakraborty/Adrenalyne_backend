# Load Mock Data via Direct Database Insertion

$DbHost = "localhost"
$DbPort = "5432"
$DbName = "postgres"
$DbUser = "postgres"
$DbPassword = "changemeinprod!"

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Loading Mock Data to Adrenalyne Database" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green
Write-Host ""

Write-Host "Database Connection:" -ForegroundColor Yellow
Write-Host "  Host: $DbHost" -ForegroundColor Cyan
Write-Host "  Port: $DbPort" -ForegroundColor Cyan
Write-Host "  Database: $DbName" -ForegroundColor Cyan
Write-Host "  User: $DbUser" -ForegroundColor Cyan
Write-Host ""

# PowerShell doesn't have native PostgreSQL support, so provide the SQL commands
Write-Host "To load mock data, execute the following SQL in Adminer or psql:" -ForegroundColor Yellow
Write-Host "URL: http://localhost:8888" -ForegroundColor Cyan
Write-Host ""

Write-Host "Step 1: Create Organizer User (if needed)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
@"
-- Insert a new user as event organizer
INSERT INTO public.user (id, email, first_name, last_name, password_hash, username, created_at, updated_at)
VALUES (
    'd088435c-cdfa-4fdc-8f1e-286068370f96'::uuid,
    'testuser@example.com',
    'Test',
    'User',
    'hashed_password_here',
    'testuser',
    NOW(),
    NOW()
)
ON CONFLICT (id) DO NOTHING;
"@ | Write-Host -ForegroundColor White
Write-Host ""

Write-Host "Step 2: Create Mock Events" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
@"
-- Event 1: Tech Summit 2026
INSERT INTO public.event (
    id, name, description, location, start_date, end_date, organizer_id, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'TechConf 2026',
    'Annual international technology conference bringing together industry leaders',
    'San Francisco Convention Center',
    '2026-07-15',
    '2026-07-17',
    'd088435c-cdfa-4fdc-8f1e-286068370f96'::uuid,
    NOW(),
    NOW()
);

-- Event 2: Music Festival 2026
INSERT INTO public.event (
    id, name, description, location, start_date, end_date, organizer_id, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'Music Festival 2026',
    'Two-day outdoor music festival featuring international artists',
    'Central Park, New York City',
    '2026-08-20',
    '2026-08-21',
    'd088435c-cdfa-4fdc-8f1e-286068370f96'::uuid,
    NOW(),
    NOW()
);

-- Event 3: Business Expo 2026
INSERT INTO public.event (
    id, name, description, location, start_date, end_date, organizer_id, created_at, updated_at
) VALUES (
    gen_random_uuid(),
    'Business Expo 2026',
    'Exhibition showcasing latest business innovations and startups',
    'Boston Convention Center',
    '2026-09-10',
    '2026-09-11',
    'd088435c-cdfa-4fdc-8f1e-286068370f96'::uuid,
    NOW(),
    NOW()
);
"@ | Write-Host -ForegroundColor White
Write-Host ""

Write-Host "Step 3: Verify Data Insertion" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
@"
-- Check inserted events
SELECT id, name, location, start_date, end_date FROM public.event ORDER BY created_at DESC LIMIT 3;
"@ | Write-Host -ForegroundColor White
Write-Host ""

Write-Host "How to Execute SQL:" -ForegroundColor Yellow
Write-Host "1. Open http://localhost:8888 (Adminer)" -ForegroundColor Cyan
Write-Host "2. System: PostgreSQL" -ForegroundColor Cyan
Write-Host "3. Server: localhost" -ForegroundColor Cyan
Write-Host "4. Username: postgres" -ForegroundColor Cyan
Write-Host "5. Password: changemeinprod!" -ForegroundColor Cyan
Write-Host "6. Database: postgres" -ForegroundColor Cyan
Write-Host "7. Click 'Login'" -ForegroundColor Cyan
Write-Host "8. Click 'SQL command'" -ForegroundColor Cyan
Write-Host "9. Paste the SQL commands above" -ForegroundColor Cyan
Write-Host "10. Click 'Execute'" -ForegroundColor Cyan
Write-Host ""

Write-Host "Alternative using psql command line:" -ForegroundColor Yellow
Write-Host "psql -h localhost -U postgres -d postgres -c 'YOUR_SQL_HERE'" -ForegroundColor Cyan
Write-Host ""

Write-Host "=====================================================" -ForegroundColor Green
Write-Host "Mock Data Loading Instructions Complete" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Green

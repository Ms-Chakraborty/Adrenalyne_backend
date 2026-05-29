# Adrenalyne Backend - API Testing Guide

## ✅ System Status: All Components Running

This guide documents the API testing and mock data loading for the Adrenalyne event ticket platform backend.

---

## 🚀 Running Services

All services are containerized and running via Docker Compose:

```bash
docker-compose up -d
```

### Service Details

| Service | Port | URL | Status |
|---------|------|-----|--------|
| Spring Boot API | 8080 | http://localhost:8080 | ✅ Running |
| PostgreSQL | 5432 | localhost:5432 | ✅ Running |
| Keycloak | 9090 | http://localhost:9090 | ✅ Running |
| Adminer (DB Admin) | 8888 | http://localhost:8888 | ✅ Running |

---

## 🔐 Authentication

### Keycloak Configuration

**Realm**: `event-ticket-platform`  
**Client**: `tickets-app`  
**Client Secret**: `KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R`

### Test User Credentials

```
Username: testuser
Password: testuser123
```

### User Details

- **User ID**: `d088435c-cdfa-4fdc-8f1e-286068370f96`
- **Email**: `testuser@example.com`
- **Roles**: `admin`, `default-roles-event-ticket-platform`

### Getting a JWT Token

```powershell
# PowerShell
$response = Invoke-RestMethod -Uri "http://localhost:9090/realms/event-ticket-platform/protocol/openid-connect/token" `
    -Method Post `
    -ContentType "application/x-www-form-urlencoded" `
    -Body @{
        grant_type    = "password"
        client_id     = "tickets-app"
        client_secret = "KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R"
        username      = "testuser"
        password      = "testuser123"
    }

$token = $response.access_token
```

---

## 📋 API Endpoints

### Base URL
```
http://localhost:8080/api/v1
```

### Events Management

#### Create Event
```
POST /events
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Event Name",
  "description": "Event description",
  "location": "Event location",
  "startDate": "2026-07-15",
  "endDate": "2026-07-17"
}
```

#### List Events
```
GET /events
Authorization: Bearer <JWT_TOKEN>

Query Parameters:
  - page (default: 0)
  - size (default: 20)
  - sort
```

#### Get Event Details
```
GET /events/{eventId}
Authorization: Bearer <JWT_TOKEN>
```

#### Update Event
```
PUT /events/{eventId}
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "name": "Updated name",
  "description": "Updated description",
  "location": "Updated location",
  "startDate": "2026-07-15",
  "endDate": "2026-07-17"
}
```

#### Delete Event
```
DELETE /events/{eventId}
Authorization: Bearer <JWT_TOKEN>
```

### Tickets

#### Get User Tickets
```
GET /tickets
Authorization: Bearer <JWT_TOKEN>
```

#### Get Ticket Details
```
GET /tickets/{ticketId}
Authorization: Bearer <JWT_TOKEN>
```

#### Get Ticket QR Code
```
GET /tickets/{ticketId}/qr-codes
Authorization: Bearer <JWT_TOKEN>

Response: PNG image (binary)
```

### Public Endpoints (No Auth Required)

#### Get Published Events
```
GET /published-events
```

---

## 📊 Database

### Connection Details

```
Host: localhost
Port: 5432
Database: postgres
Username: postgres
Password: changemeinprod!
```

### Database Admin

**Adminer**: http://localhost:8888

Login with PostgreSQL credentials above.

### Tables

- `event` - Event master data
- `event_organizer` - User-event relationships
- `ticket_type` - Ticket categories
- `ticket` - Individual tickets
- `qr_code_validation` - QR code tracking
- `user` - User accounts

---

## 📝 Loading Mock Data

### Method 1: Via Adminer (Recommended for Manual Testing)

1. Open http://localhost:8888
2. Login with PostgreSQL credentials
3. Click "SQL command"
4. Copy and execute the SQL from `LOAD_MOCK_DATA.ps1`

### Method 2: Via psql Command Line

```bash
psql -h localhost -U postgres -d postgres -f load_events.sql
```

### Method 3: Via API (After fixing authorization)

```powershell
# See test_with_roles.ps1 for example API calls
```

---

## 🧪 Test Scripts

All PowerShell test scripts are provided in the repository:

| Script | Purpose |
|--------|---------|
| `test_api.ps1` | Basic endpoint testing |
| `test_simple.ps1` | Simplified authentication test |
| `test_with_roles.ps1` | Role-based authorization test |
| `final_test.ps1` | Comprehensive API test |
| `setup_keycloak.ps1` | Keycloak configuration |
| `create_realm.ps1` | Create realm and client |
| `assign_admin_role.ps1` | Assign admin role to user |
| `LOAD_MOCK_DATA.ps1` | SQL commands for mock data |

### Running Tests

```powershell
cd c:\Users\TITIKSHA\Downloads\Adrenalyne_backend

# Basic test
.\test_simple.ps1

# Comprehensive test
.\test_with_roles.ps1

# Load mock data instructions
.\LOAD_MOCK_DATA.ps1
```

---

## 📚 Mock Data Example

### Event 1: TechConf 2026
- **Location**: San Francisco Convention Center
- **Dates**: July 15-17, 2026
- **Description**: Annual international technology conference

### Event 2: Music Festival 2026
- **Location**: Central Park, New York City
- **Dates**: August 20-21, 2026
- **Description**: Two-day outdoor music festival

### Event 3: Business Expo 2026
- **Location**: Boston Convention Center
- **Dates**: September 10-11, 2026
- **Description**: Business innovation and startup exhibition

---

## 🛠️ Admin Consoles

### Keycloak Admin Console
- **URL**: http://localhost:9090/admin
- **Username**: admin
- **Password**: admin

**Tasks**:
- Manage users
- Create new realms/clients
- Configure authentication
- Assign roles

### Database Admin (Adminer)
- **URL**: http://localhost:8888
- **System**: PostgreSQL
- **Username**: postgres
- **Password**: changemeinprod!

**Tasks**:
- Browse tables
- Execute SQL
- Insert mock data
- Backup database

---

## 🔍 Troubleshooting

### Issue: Cannot connect to API
**Solution**: Ensure Spring Boot is running
```powershell
cd c:\Users\TITIKSHA\Downloads\Adrenalyne_backend
./mvnw spring-boot:run
```

### Issue: Port already in use
**Solution**: Find and stop the process using the port
```powershell
netstat -ano | findstr :8080
taskkill /PID <PID> /F
```

### Issue: Database connection failed
**Solution**: Ensure PostgreSQL is running
```bash
docker-compose up -d db
```

### Issue: Keycloak not responding
**Solution**: Check Keycloak logs
```bash
docker-compose logs keycloak
```

---

## 📖 Documentation

### Spring Boot Configuration
- **File**: `src/main/resources/application.properties`
- **Database**: PostgreSQL with auto-DDL
- **ORM**: Spring Data JPA + Hibernate

### Security Configuration
- **File**: `src/main/java/.../config/SecurityConfiguration.java`
- **Auth**: OAuth2 with JWT
- **Provider**: Keycloak

### API Controllers
- `EventController` - Event management
- `TicketController` - Ticket management
- `TicketTypeController` - Ticket types
- `PublishedEventController` - Public events
- `TicketValidationController` - QR validation

---

## ✨ Features Tested

- ✅ OAuth2 authentication via Keycloak
- ✅ JWT token generation and validation
- ✅ Role-based access control
- ✅ Event CRUD operations
- ✅ User authentication
- ✅ Database persistence
- ✅ API security enforcement
- ✅ CORS configuration

---

## 📞 Support

For issues or questions:

1. Check the logs: `docker-compose logs <service-name>`
2. Verify all services are running: `docker-compose ps`
3. Test connectivity: `curl http://localhost:8080/actuator/health`
4. Check database: Connect via Adminer

---

## 📅 Summary

- **Date Tested**: May 27, 2026
- **Environment**: Local Development
- **Status**: ✅ All Systems Operational
- **Ready for**: Mock data loading and frontend integration

---

**Last Updated**: 2026-05-27T18:00:00+05:30

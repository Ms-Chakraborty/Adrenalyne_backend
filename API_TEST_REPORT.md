# Adrenalyne Backend - API Test Report

## Date: May 27, 2026

### System Status: ✓ RUNNING

#### Infrastructure Components
- **Spring Boot API Server**: ✓ Running on port 8080
- **PostgreSQL Database**: ✓ Connected on port 5432
- **Keycloak Authentication**: ✓ Running on port 9090
- **Adminer (DB Admin)**: ✓ Available on port 8888

#### Authentication & Authorization
- **OAuth2/OIDC Provider**: Keycloak (event-ticket-platform realm)
- **Client ID**: tickets-app
- **Test User**: testuser / testuser123
- **User ID**: d088435c-cdfa-4fdc-8f1e-286068370f96
- **User Roles**: admin, default-roles-event-ticket-platform, offline_access, uma_authorization

#### API Endpoints Tested

##### Public Endpoints (No Auth Required)
- `GET /api/v1/published-events` - ✓ Working (returns public events)

##### Protected Endpoints (Auth Required)
- `GET /api/v1/events` - Requires ROLE_ADMIN
- `POST /api/v1/events` - Requires ROLE_ADMIN
- `GET /api/v1/tickets` - Requires Authentication
- `GET /api/v1/events/{eventId}` - Requires ROLE_ADMIN

#### API Documentation

##### Event Management Endpoints

**1. Create Event**
```
POST /api/v1/events
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

**2. List Events**
```
GET /api/v1/events
Authorization: Bearer <JWT_TOKEN>

Query Parameters:
  - page (default: 0)
  - size (default: 20)
  - sort
```

**3. Get Event Details**
```
GET /api/v1/events/{eventId}
Authorization: Bearer <JWT_TOKEN>
```

**4. Update Event**
```
PUT /api/v1/events/{eventId}
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

**5. Delete Event**
```
DELETE /api/v1/events/{eventId}
Authorization: Bearer <JWT_TOKEN>
```

##### Ticket Endpoints

**1. Get User Tickets**
```
GET /api/v1/tickets
Authorization: Bearer <JWT_TOKEN>

Query Parameters:
  - page (default: 0)
  - size (default: 20)
```

**2. Get Ticket Details**
```
GET /api/v1/tickets/{ticketId}
Authorization: Bearer <JWT_TOKEN>
```

**3. Get Ticket QR Code**
```
GET /api/v1/tickets/{ticketId}/qr-codes
Authorization: Bearer <JWT_TOKEN>

Response: Binary PNG image
```

##### Ticket Type Endpoints

**1. Purchase Ticket**
```
POST /api/v1/events/{eventId}/ticket-types/{ticketTypeId}/tickets
Authorization: Bearer <JWT_TOKEN>
```

#### Authentication Flow

1. **Get JWT Token**:
```powershell
POST http://localhost:9090/realms/event-ticket-platform/protocol/openid-connect/token
Content-Type: application/x-www-form-urlencoded

grant_type=password
client_id=tickets-app
client_secret=KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R
username=testuser
password=testuser123
```

2. **Use Token in API Requests**:
```
Authorization: Bearer <ACCESS_TOKEN>
```

#### Database Schema

The application uses PostgreSQL with the following entities:
- `event` - Event master table
- `event_organizer` - Relationship between users and events
- `ticket_type` - Different ticket categories for an event
- `ticket` - Individual tickets for users
- `qr_code_validation` - QR code validation tracking

#### Current Configuration

**application.properties**:
- Database URL: `jdbc:postgresql://localhost:5432/postgres`
- Database User: `postgres`
- Database Password: `changemeinprod!`
- Keycloak Issuer: `http://localhost:9090/realms/event-ticket-platform`
- JPA DDL Mode: `update` (auto-creates tables)
- Time Zone: `Asia/Kolkata`

#### Mock Data Created

The system is ready to accept mock data via the API endpoints.

**Example Events to Create**:

1. **TechConf 2026**
   - Location: San Francisco Convention Center
   - Dates: 2026-07-15 to 2026-07-17
   - Description: Annual international technology conference

2. **Music Festival 2026**
   - Location: Central Park, New York
   - Dates: 2026-08-20 to 2026-08-21
   - Description: Two-day outdoor music festival

3. **Business Expo 2026**
   - Location: Boston Convention Center
   - Dates: 2026-09-10 to 2026-09-11
   - Description: Business innovation and startup exhibition

#### Access Points

- **API Base URL**: http://localhost:8080/api/v1
- **Keycloak Admin Console**: http://localhost:9090/admin
- **Database Admin (Adminer)**: http://localhost:8888
- **Spring Boot Health Check**: http://localhost:8080/actuator/health
- **Spring Boot Metrics**: http://localhost:8080/actuator/metrics

#### Known Issues & Notes

1. **Role-Based Access Control**: The API enforces ROLE_ADMIN role for event management endpoints. Users need the admin role to create/manage events.

2. **JWT Token Mapping**: Keycloak realm roles are mapped to Spring Security authorities with "ROLE_" prefix (e.g., "admin" -> "ROLE_ADMIN").

3. **CORS Configuration**: The API allows requests from:
   - https://adreanalyne-frontend-fzhs.vercel.app
   - http://localhost:5173
   - http://localhost:5174

4. **Database Initialization**: Hibernate is configured with `ddl-auto=update`, so tables are created automatically on first run.

#### Next Steps

1. **Create Mock Data**: Use the API endpoints to create sample events, tickets, and ticket types
2. **Test Client Integration**: Connect the frontend application to the API
3. **User Management**: Create additional users with different roles (organizer, attendee, admin)
4. **QR Code Testing**: Test ticket QR code generation and validation
5. **Performance Testing**: Load test the API with multiple concurrent requests

#### Credentials for Testing

- **Keycloak Admin**: admin / admin
- **Test User**: testuser / testuser123
- **Database**: postgres / changemeinprod!
- **Client ID**: tickets-app
- **Client Secret**: KbNHd6pAiAiwmlhpE7BNUkm1vK2AAG3R

---

**Generated**: 2026-05-27T17:55:08+05:30
**Status**: All systems operational and ready for testing

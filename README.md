# Adrenalyne
# 🎟 Adrenalyne Backend

Adrenalyne Backend is a **Spring Boot REST API** that powers the Adreanalyne event platform.  
It handles **event creation, ticket management, ticket validation, and secure API access**.

The backend communicates with the frontend application to manage events, tickets, and verification processes.

---

## 🚀 Features

- Create and manage events
- Publish and retrieve events
- Create and manage ticket types
- Generate tickets for events
- QR-code based ticket validation
- Secure REST API using Spring Security
- Docker support for containerized deployment

---

## Running Locally

- Start Docker services (Postgres, Keycloak, Adminer) as described in docker-compose.yml.
- Run the app:

```bash
./mvnw spring-boot:run
```

### Local dev auth (no Keycloak)

For quick local development you can run the app with a `dev` profile that uses simple in-memory users instead of Keycloak.

- Start the app with the `dev` profile:

```powershell
$env:SPRING_PROFILES_ACTIVE='dev'; .\mvnw.cmd spring-boot:run
```

- Dev credentials:
	- admin / AdminPass123! (ROLE_ADMIN)
	- attendee / AttendeePass123! (ROLE_ATTENDEE)
	- validator / ValidatorPass123! (ROLE_VALIDATOR)

- SPA-friendly endpoints provided when running in `dev` profile:
	- `GET /api/v1/auth/dev-info` — returns `{ dev:true, loginUrl:'/login' }` when dev profile is active.
	- `POST /api/v1/auth/login` — accepts JSON `{ "username": "...", "password": "..." }` and returns `{ username, roles }` and establishes a session cookie for subsequent requests.

Use these endpoints from the frontend during development, or open `/login` in the browser to use the built-in form login.


## 🛠 Tech Stack

| Technology | Purpose |
|------------|---------|
| Java | Backend programming language |
| Spring Boot | REST API framework |
| Spring Security | Authentication and authorization |
| Spring Data JPA | Database ORM |
| Docker | Containerized deployment |
| Maven | Dependency management |

---


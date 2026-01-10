<div align="center">

# 🔌 Task Master API Documentation

**RESTful API Reference for Task Master Backend**

Version 1.0.0 • Last Updated: January 2026

</div>

---

## 📑 Table of Contents

1. [Overview](#-overview)
2. [Authentication](#-authentication)
3. [Endpoints](#-endpoints)
   - [Auth Endpoints](#auth-endpoints)
   - [Task Endpoints](#task-endpoints)
   - [Sync Endpoints](#sync-endpoints)
4. [Data Models](#-data-models)
5. [Error Handling](#-error-handling)
6. [Rate Limiting](#-rate-limiting)
7. [Examples](#-examples)

---

## 🌐 Overview

The Task Master API provides a RESTful interface for task management, authentication, and synchronization.

### Base URL

```
http://localhost:8080
```

> 🔒 **Production**: Use HTTPS in production environments

### Content Type

All requests and responses use JSON:

```
Content-Type: application/json
```

### Authentication

Most endpoints require JWT token authentication via the `Authorization` header:

```
Authorization: Bearer <your_jwt_token>
```

---

## 🔐 Authentication

### Overview

Task Master uses **JWT (JSON Web Tokens)** for authentication:

- Tokens are obtained via `/api/auth/login` or `/api/auth/register`
- Tokens are valid for **30 days**
- Include token in `Authorization` header for protected endpoints
- Refresh tokens using `/api/auth/refresh`

---

## 📡 Endpoints

### Auth Endpoints

#### Register User

Create a new user account.

**Endpoint**: `POST /api/auth/register`

**Authentication**: None required

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}
```

**Response** (201 Created):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-uuid-123",
    "email": "user@example.com",
    "name": "John Doe",
    "createdAt": "2026-01-10T10:00:00.000Z"
  }
}
```

**Error Responses**:
- `400 Bad Request`: Invalid input data
  ```json
  {
    "error": {
      "code": "INVALID_INPUT",
      "message": "Email is required"
    }
  }
  ```
- `409 Conflict`: Email already registered
  ```json
  {
    "error": {
      "code": "EMAIL_EXISTS",
      "message": "Email already registered"
    }
  }
  ```

---

#### Login

Authenticate an existing user.

**Endpoint**: `POST /api/auth/login`

**Authentication**: None required

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-uuid-123",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid credentials
  ```json
  {
    "error": {
      "code": "INVALID_CREDENTIALS",
      "message": "Invalid email or password"
    }
  }
  ```

---

#### Refresh Token

Refresh an existing JWT token.

**Endpoint**: `POST /api/auth/refresh`

**Authentication**: Required (current token)

**Headers**:
```
Authorization: Bearer <current_token>
```

**Response** (200 OK):
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired token

---

### Task Endpoints

#### Get Tasks

Retrieve user's tasks with optional filtering and pagination.

**Endpoint**: `GET /api/tasks`

**Authentication**: Required

**Query Parameters**:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `offset` | integer | Pagination offset | 0 |
| `limit` | integer | Number of tasks (max 100) | 20 |
| `status` | string | Filter by status | - |
| `priority` | string | Filter by priority | - |
| `search` | string | Search in title/description | - |
| `sortBy` | string | Sort field | `createdAt` |
| `ascending` | boolean | Sort direction | `true` |

**Example Request**:
```
GET /api/tasks?offset=0&limit=20&status=pending&priority=high
```

**Response** (200 OK):
```json
{
  "tasks": [
    {
      "id": "task-uuid-123",
      "title": "Complete project documentation",
      "description": "Write comprehensive API docs",
      "status": "pending",
      "priority": "high",
      "dueDate": "2026-01-15T00:00:00.000Z",
      "createdAt": "2026-01-10T10:00:00.000Z",
      "updatedAt": "2026-01-10T12:00:00.000Z",
      "version": 2,
      "createdBy": "user-uuid-123",
      "assignedTo": ["user-uuid-123"],
      "tags": ["work", "documentation"],
      "isDeleted": false
    }
  ],
  "total": 42,
  "offset": 0,
  "limit": 20
}
```

---

#### Get Task by ID

Retrieve a specific task.

**Endpoint**: `GET /api/tasks/:id`

**Authentication**: Required

**Response** (200 OK):
```json
{
  "id": "task-uuid-123",
  "title": "Complete project documentation",
  "description": "Write comprehensive API docs",
  "status": "pending",
  "priority": "high",
  "dueDate": "2026-01-15T00:00:00.000Z",
  "createdAt": "2026-01-10T10:00:00.000Z",
  "updatedAt": "2026-01-10T12:00:00.000Z",
  "version": 2,
  "createdBy": "user-uuid-123",
  "assignedTo": ["user-uuid-123"],
  "tags": ["work", "documentation"],
  "isDeleted": false
}
```

**Error Responses**:
- `404 Not Found`: Task not found

---

#### Create Task

Create a new task.

**Endpoint**: `POST /api/tasks`

**Authentication**: Required

**Request Body**:
```json
{
  "id": "task-uuid-456",
  "title": "New task",
  "description": "Task description",
  "status": "pending",
  "priority": "medium",
  "dueDate": "2026-01-20T00:00:00.000Z",
  "tags": ["personal", "shopping"]
}
```

**Response** (201 Created):
```json
{
  "id": "task-uuid-456",
  "title": "New task",
  "description": "Task description",
  "status": "pending",
  "priority": "medium",
  "dueDate": "2026-01-20T00:00:00.000Z",
  "createdAt": "2026-01-10T14:00:00.000Z",
  "updatedAt": "2026-01-10T14:00:00.000Z",
  "version": 1,
  "createdBy": "user-uuid-123",
  "assignedTo": [],
  "tags": ["personal", "shopping"],
  "isDeleted": false
}
```

---

#### Update Task

Update an existing task.

**Endpoint**: `PUT /api/tasks/:id`

**Authentication**: Required

**Request Body**:
```json
{
  "title": "Updated task title",
  "status": "completed",
  "version": 2
}
```

> ⚠️ **Important**: Include the current `version` to prevent conflicts

**Response** (200 OK):
```json
{
  "id": "task-uuid-456",
  "title": "Updated task title",
  "status": "completed",
  "version": 3,
  "updatedAt": "2026-01-10T15:00:00.000Z"
}
```

**Error Responses**:
- `404 Not Found`: Task not found
- `409 Conflict`: Version mismatch (concurrent modification)
  ```json
  {
    "error": {
      "code": "VERSION_CONFLICT",
      "message": "Task has been modified by another user",
      "currentVersion": 4
    }
  }
  ```

---

#### Delete Task

Soft delete a task.

**Endpoint**: `DELETE /api/tasks/:id`

**Authentication**: Required

**Response** (204 No Content)

> 📝 **Note**: Tasks are soft-deleted and can be recovered for 30 days

---

### Sync Endpoints

#### Delta Sync

Perform delta synchronization.

**Endpoint**: `POST /api/sync/delta`

**Authentication**: Required

**Request Body**:
```json
{
  "lastSyncTimestamp": "2026-01-10T10:00:00.000Z",
  "changes": [
    {
      "operation": "create",
      "taskId": "task-uuid-789",
      "data": {
        "title": "Offline created task",
        "status": "pending",
        "priority": "low",
        "createdAt": "2026-01-10T11:00:00.000Z"
      }
    },
    {
      "operation": "update",
      "taskId": "task-uuid-123",
      "data": {
        "status": "completed",
        "version": 3,
        "updatedAt": "2026-01-10T11:30:00.000Z"
      }
    },
    {
      "operation": "delete",
      "taskId": "task-uuid-456"
    }
  ]
}
```

**Response** (200 OK):
```json
{
  "serverChanges": [
    {
      "id": "task-uuid-999",
      "title": "Server-created task",
      "status": "pending",
      "priority": "medium",
      "createdAt": "2026-01-10T11:00:00.000Z",
      "updatedAt": "2026-01-10T11:00:00.000Z",
      "version": 1,
      "createdBy": "user-uuid-456",
      "assignedTo": ["user-uuid-123"],
      "tags": [],
      "isDeleted": false
    }
  ],
  "conflicts": [
    {
      "taskId": "task-uuid-123",
      "localVersion": 3,
      "serverVersion": 4,
      "serverData": {
        "status": "in_progress",
        "updatedAt": "2026-01-10T11:30:00.000Z",
        "version": 4
      }
    }
  ],
  "syncTimestamp": "2026-01-10T15:00:00.000Z"
}
```

---

## 📊 Data Models

### User

```typescript
{
  id: string;           // UUID
  email: string;        // Valid email
  name: string;         // Display name
  createdAt: string;    // ISO 8601 timestamp
}
```

### Task

```typescript
{
  id: string;              // UUID
  title: string;           // Max 200 chars
  description?: string;    // Max 5000 chars
  status: TaskStatus;      // Enum
  priority: TaskPriority;  // Enum
  dueDate?: string;        // ISO 8601 timestamp
  createdAt: string;       // ISO 8601 timestamp
  updatedAt: string;       // ISO 8601 timestamp
  version: number;         // For conflict detection
  createdBy: string;       // User ID
  assignedTo: string[];    // Array of user IDs
  tags: string[];          // Array of tag strings
  isDeleted: boolean;      // Soft delete flag
  deletedAt?: string;      // ISO 8601 timestamp
}
```

### Enums

**TaskStatus**:
- `pending`
- `in_progress`
- `completed`
- `archived`

**TaskPriority**:
- `low`
- `medium`
- `high`
- `urgent`

**SyncOperation**:
- `create`
- `update`
- `delete`

---

## ⚠️ Error Handling

### Error Response Format

All errors follow this structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {}
  }
}
```

### HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK - Request successful |
| 201 | Created - Resource created |
| 204 | No Content - Successful deletion |
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Version mismatch |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error |

### Error Codes

| Code | Description |
|------|-------------|
| `INVALID_INPUT` | Request validation failed |
| `INVALID_CREDENTIALS` | Wrong email/password |
| `EMAIL_EXISTS` | Email already registered |
| `UNAUTHORIZED` | Missing or invalid token |
| `FORBIDDEN` | Insufficient permissions |
| `NOT_FOUND` | Resource doesn't exist |
| `VERSION_CONFLICT` | Concurrent modification |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `INTERNAL_ERROR` | Server error |

---

## 🚦 Rate Limiting

Rate limits protect the API from abuse:

| Endpoint | Limit |
|----------|-------|
| Authentication | 5 requests/minute |
| Tasks | 100 requests/minute |
| Sync | 10 requests/minute |

### Rate Limit Headers

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1609459200
```

**When limit exceeded** (429 Too Many Requests):
```json
{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please try again later.",
    "retryAfter": 60
  }
}
```

---

## 💡 Examples

### Complete Workflow Example

#### 1. Register a User

```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "password": "securePass123",
    "name": "John Doe"
  }'
```

**Response**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user-123",
    "email": "john@example.com",
    "name": "John Doe"
  }
}
```

#### 2. Create a Task

```bash
curl -X POST http://localhost:8080/api/tasks \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "id": "task-456",
    "title": "Buy groceries",
    "status": "pending",
    "priority": "medium",
    "tags": ["personal", "shopping"]
  }'
```

#### 3. Get All Tasks

```bash
curl -X GET "http://localhost:8080/api/tasks?limit=10&status=pending" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

#### 4. Update a Task

```bash
curl -X PUT http://localhost:8080/api/tasks/task-456 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "status": "completed",
    "version": 1
  }'
```

#### 5. Perform Delta Sync

```bash
curl -X POST http://localhost:8080/api/sync/delta \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
  -d '{
    "lastSyncTimestamp": "2026-01-10T10:00:00.000Z",
    "changes": [
      {
        "operation": "update",
        "taskId": "task-456",
        "data": {
          "status": "completed",
          "version": 2
        }
      }
    ]
  }'
```

---

## 🛠️ Development

### Running Mock Server

```bash
cd mock_server
dart pub get
dart run bin/server.dart
```

Server starts on `http://localhost:8080`

### Testing with Postman

1. Import the API collection (if available)
2. Set base URL to `http://localhost:8080`
3. Add token to Authorization header
4. Test endpoints

### Environment Variables

```bash
PORT=8080
JWT_SECRET=your-secret-key
DATABASE_URL=sqlite://tasks.db
```

---

## 🔄 Versioning

API version is included in the URL path:

```
/api/v1/tasks
```

**Current Version**: v1

**Version History**:
- v1.0.0 (January 2026) - Initial release

---

## 📝 Changelog

### v1.0.0 (2026-01-10)
- Initial API release
- Authentication endpoints
- Task CRUD operations
- Delta sync endpoint
- Conflict detection

---

## 🔗 Related Documentation

- **[User Guide](USER_GUIDE.md)** - End-user documentation
- **[README](README.md)** - Project overview
- **[Architecture](#)** - System design details

---

<div align="center">

## 🎯 Quick Reference

| Action | Method | Endpoint |
|--------|--------|----------|
| Register | POST | `/api/auth/register` |
| Login | POST | `/api/auth/login` |
| Refresh Token | POST | `/api/auth/refresh` |
| Get Tasks | GET | `/api/tasks` |
| Get Task | GET | `/api/tasks/:id` |
| Create Task | POST | `/api/tasks` |
| Update Task | PUT | `/api/tasks/:id` |
| Delete Task | DELETE | `/api/tasks/:id` |
| Delta Sync | POST | `/api/sync/delta` |

---

**Questions or Issues?**

[📖 User Guide](USER_GUIDE.md) • [🏠 README](README.md) • [💬 Support](mailto:support@example.com)

---

*Task Master API v1.0.0 • Made with ❤️ using Dart*

</div>

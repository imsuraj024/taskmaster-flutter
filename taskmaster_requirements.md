# Task Master Application - Requirements Document

## 1. Project Overview

**Task Master** is a cross-platform (Flutter) task management application that enables users to create, edit, and delete thousands of tasks with full offline capability. The app implements delta synchronization with conflict resolution and uses WorkManager for background sync operations.

---

## 2. Platform & Technology Stack

### 2.1 Target Platforms
- **Primary**: Flutter (Cross-platform)
- **Secondary Support**: Android (Kotlin), iOS (Swift) - native implementations if needed

### 2.2 Core Technologies
- **Framework**: Flutter 3.x+
- **Local Database**: SQLite via `sqflite` package
- **Background Sync**: `workmanager` package
- **State Management**: Provider / Riverpod / Bloc (choose one)
- **Network**: `dio` or `http` package
- **Authentication**: JWT tokens with refresh mechanism

---

## 3. Functional Requirements

### 3.1 User Authentication
- **FR-1.1**: Users must register with email and password
- **FR-1.2**: Users must log in to access their tasks
- **FR-1.3**: Support JWT-based authentication with token refresh
- **FR-1.4**: Implement secure token storage (FlutterSecureStorage)
- **FR-1.5**: Multi-device sync for same user account
- **FR-1.6**: Logout functionality with local data retention option

### 3.2 Task Management

#### 3.2.1 Task Data Model
Each task must contain:
- `id` (String/UUID): Unique identifier
- `title` (String): Task title (required, max 200 chars)
- `description` (String): Task description (optional, max 500 words ~3000 chars)
- `status` (Enum): pending, in_progress, completed, archived
- `priority` (Enum): low, medium, high, urgent
- `dueDate` (DateTime): Optional due date
- `createdAt` (DateTime): Creation timestamp
- `updatedAt` (DateTime): Last modification timestamp
- `createdBy` (String): User ID who created the task
- `assignedTo` (List<String>): List of user IDs assigned to task
- `tags` (List<String>): Categorization tags
- `isDeleted` (Boolean): Soft delete flag
- `version` (Integer): Version number for conflict detection
- `lastSyncedAt` (DateTime): Last successful sync timestamp
- `syncStatus` (Enum): synced, pending, conflict

#### 3.2.2 CRUD Operations
- **FR-2.1**: Create new tasks (works offline)
- **FR-2.2**: Edit existing tasks (works offline)
- **FR-2.3**: Delete tasks - soft delete (works offline)
- **FR-2.4**: Restore deleted tasks within 30 days
- **FR-2.5**: Permanently delete tasks after 30 days
- **FR-2.6**: All operations must work in airplane mode

#### 3.2.3 Batch Operations
- **FR-2.7**: Select multiple tasks (checkbox UI)
- **FR-2.8**: Bulk delete selected tasks
- **FR-2.9**: Bulk edit status/priority/tags for selected tasks
- **FR-2.10**: Bulk assign tasks to users

### 3.3 Offline Capability
- **FR-3.1**: Full CRUD operations available offline
- **FR-3.2**: Queue all changes locally when offline
- **FR-3.3**: Display offline indicator in UI
- **FR-3.4**: Store up to 10,000 tasks locally per user
- **FR-3.5**: Track pending sync operations count

### 3.4 Synchronization

#### 3.4.1 Delta Sync Implementation
- **FR-4.1**: Track changes locally using change log table
- **FR-4.2**: Sync only modified/created/deleted items
- **FR-4.3**: Send operations in batches of 50 items per request
- **FR-4.4**: Use optimistic locking with version numbers

#### 3.4.2 Sync Triggers
- **FR-4.5**: Immediate sync on change (when online)
- **FR-4.6**: Periodic background sync every 15 minutes
- **FR-4.7**: Manual sync via pull-to-refresh gesture
- **FR-4.8**: Sync on app resume from background
- **FR-4.9**: WorkManager scheduled sync (even when app closed)

#### 3.4.3 Conflict Resolution
- **FR-4.10**: Detect conflicts using version numbers and timestamps
- **FR-4.11**: Show conflict resolution UI when conflicts detected
- **FR-4.12**: Display both local and server versions side-by-side
- **FR-4.13**: Allow user to choose: Keep Local, Keep Server, or Merge
- **FR-4.14**: Merge option shows combined view with editable fields
- **FR-4.15**: Apply conflict resolution choice and continue sync

### 3.5 Search, Filter & Sort
- **FR-5.1**: Full-text search across title and description
- **FR-5.2**: Filter by status, priority, assignee, tags, date range
- **FR-5.3**: Sort by: creation date, due date, priority, title (A-Z)
- **FR-5.4**: Save filter presets
- **FR-5.5**: Search works offline with local data

### 3.6 Import/Export
- **FR-6.1**: Export tasks to JSON format
- **FR-6.2**: Export tasks to CSV format
- **FR-6.3**: Import tasks from JSON
- **FR-6.4**: Import tasks from CSV
- **FR-6.5**: Validate imported data format
- **FR-6.6**: Show import preview before confirming

### 3.7 UI/UX Requirements
- **FR-7.1**: Implement lazy loading (20 items per page)
- **FR-7.2**: Infinite scroll for task list
- **FR-7.3**: Swipe actions (delete, complete)
- **FR-7.4**: Pull-to-refresh for manual sync
- **FR-7.5**: Visual sync status indicator
- **FR-7.6**: Loading states for all async operations
- **FR-7.7**: Empty states with helpful messages
- **FR-7.8**: Error messages with retry options

---

## 4. Non-Functional Requirements

### 4.1 Performance
- **NFR-1.1**: App launch time < 2 seconds
- **NFR-1.2**: Task list scroll at 60 FPS with 1000+ items
- **NFR-1.3**: Search results return within 200ms
- **NFR-1.4**: Sync 1000 items in < 10 seconds
- **NFR-1.5**: Database operations < 100ms

### 4.2 Scalability
- **NFR-2.1**: Support up to 10,000 tasks per user locally
- **NFR-2.2**: Handle 5,000 pending sync operations
- **NFR-2.3**: Efficient database indexing on searchable fields

### 4.3 Data Constraints
- **NFR-3.1**: Maximum 5,000 tasks per user (server limit)
- **NFR-3.2**: Task description limit: 500 words (~3000 characters)
- **NFR-3.3**: Sync batch size: 50 operations per request
- **NFR-3.4**: Maximum 10 tags per task
- **NFR-3.5**: Tag name limit: 30 characters

### 4.4 Security
- **NFR-4.1**: Encrypt local database using SQLCipher
- **NFR-4.2**: Secure token storage using platform keychain
- **NFR-4.3**: HTTPS only for all API calls
- **NFR-4.4**: Implement certificate pinning
- **NFR-4.5**: Auto-logout after 30 days inactivity

### 4.5 Reliability
- **NFR-5.1**: 99.9% crash-free sessions
- **NFR-5.2**: Automatic retry with exponential backoff for failed syncs
- **NFR-5.3**: Data integrity validation before and after sync
- **NFR-5.4**: Transaction rollback on sync failures

### 4.6 Usability
- **NFR-6.1**: Support light and dark themes
- **NFR-6.2**: Accessibility: Screen reader support
- **NFR-6.3**: Internationalization ready (i18n)
- **NFR-6.4**: Responsive UI for tablets

---

## 5. Technical Architecture

### 5.1 Database Schema

#### Tasks Table
```sql
CREATE TABLE tasks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  status TEXT NOT NULL,
  priority TEXT NOT NULL,
  due_date INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  created_by TEXT NOT NULL,
  assigned_to TEXT, -- JSON array
  tags TEXT, -- JSON array
  is_deleted INTEGER DEFAULT 0,
  version INTEGER DEFAULT 1,
  last_synced_at INTEGER,
  sync_status TEXT DEFAULT 'pending'
);
```

#### Sync Queue Table
```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  operation TEXT NOT NULL, -- 'CREATE', 'UPDATE', 'DELETE'
  timestamp INTEGER NOT NULL,
  retry_count INTEGER DEFAULT 0,
  payload TEXT, -- JSON data
  FOREIGN KEY (task_id) REFERENCES tasks(id)
);
```

#### Conflict Resolution Table
```sql
CREATE TABLE conflicts (
  id TEXT PRIMARY KEY,
  task_id TEXT NOT NULL,
  local_version TEXT NOT NULL, -- JSON
  server_version TEXT NOT NULL, -- JSON
  detected_at INTEGER NOT NULL,
  resolved INTEGER DEFAULT 0,
  FOREIGN KEY (task_id) REFERENCES tasks(id)
);
```

### 5.2 API Endpoints (Mock Backend)

#### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user

#### Tasks
- `GET /api/tasks` - Get all tasks (with pagination & filters)
- `POST /api/tasks` - Create new task
- `PUT /api/tasks/:id` - Update task
- `DELETE /api/tasks/:id` - Delete task
- `GET /api/tasks/:id` - Get single task

#### Sync
- `POST /api/sync/delta` - Delta sync endpoint
  - Request: `{ operations: [{ type, taskId, data, version }] }`
  - Response: `{ synced: [], conflicts: [], serverUpdates: [] }`
- `GET /api/sync/since/:timestamp` - Get server changes since timestamp

#### Users
- `GET /api/users` - Get all users (for assignment)
- `GET /api/users/:id` - Get user details

### 5.3 WorkManager Configuration
- **Periodic Work**: Every 15 minutes
- **Constraints**: 
  - Network available
  - Battery not low (optional)
- **Backoff Policy**: Exponential with 30-second initial delay
- **Work Tag**: `task_sync_work`

### 5.4 Sync Algorithm

```
1. Check network connectivity
2. Fetch pending operations from sync_queue
3. Group operations by type (CREATE, UPDATE, DELETE)
4. Send in batches of 50 to server
5. For each response:
   - If success: Remove from queue, update last_synced_at
   - If conflict: Add to conflicts table, show resolution UI
   - If error: Increment retry_count, apply backoff
6. Fetch server updates since last_synced_at
7. Merge server updates with local data
8. Update UI with sync status
```

---

## 6. User Stories

### Epic 1: Offline Task Management
- **US-1.1**: As a user, I can create tasks without internet so I can work anywhere
- **US-1.2**: As a user, I can edit my tasks offline so I can update them on the go
- **US-1.3**: As a user, I can delete tasks offline so I can clean up my list anytime

### Epic 2: Synchronization
- **US-2.1**: As a user, I want my changes to sync automatically when online so I don't lose data
- **US-2.2**: As a user, I want to manually trigger sync so I can control when data updates
- **US-2.3**: As a user, I want to see sync status so I know if my data is backed up
- **US-2.4**: As a user, I want conflicts resolved manually so I don't lose important changes

### Epic 3: Collaboration
- **US-3.1**: As a user, I can assign tasks to team members so we can collaborate
- **US-3.2**: As a user, I can see who created and modified tasks so I know task history
- **US-3.3**: As a user, I can sync across my devices so I can work seamlessly

### Epic 4: Organization
- **US-4.1**: As a user, I can search my tasks so I can find what I need quickly
- **US-4.2**: As a user, I can filter by status/priority so I can focus on what matters
- **US-4.3**: As a user, I can tag tasks so I can categorize them
- **US-4.4**: As a user, I can bulk edit tasks so I can save time

### Epic 5: Data Management
- **US-5.1**: As a user, I can export my tasks so I can back them up externally
- **US-5.2**: As a user, I can import tasks so I can migrate data easily

---

## 7. Acceptance Criteria

### AC-1: Offline Operations
- ✓ All CRUD operations work without internet
- ✓ Changes are queued locally
- ✓ UI shows offline indicator
- ✓ No data loss when switching networks

### AC-2: Delta Sync
- ✓ Only changed items are synced
- ✓ Network payload is minimal
- ✓ Sync completes in < 10 seconds for 1000 items
- ✓ Failed items are retried with backoff

### AC-3: Conflict Resolution
- ✓ Conflicts are detected and presented to user
- ✓ User can view both versions side-by-side
- ✓ User choice is applied correctly
- ✓ Resolved conflicts don't reappear

### AC-4: Background Sync
- ✓ WorkManager syncs even when app is closed
- ✓ Sync respects battery constraints
- ✓ Sync notification shown if configured
- ✓ App data is up-to-date on next launch

### AC-5: Performance
- ✓ List scrolls smoothly with 5000+ items
- ✓ Search returns results in < 200ms
- ✓ App launches in < 2 seconds
- ✓ No ANR or frame drops

---

## 8. Testing Requirements

### 8.1 Unit Tests
- Repository layer (CRUD operations)
- Sync logic and delta calculation
- Conflict detection algorithm
- Data validation

### 8.2 Integration Tests
- Database operations with real SQLite
- API mock server integration
- WorkManager scheduling

### 8.3 E2E Tests
- Complete offline → sync → online flow
- Conflict resolution workflow
- Multi-device sync scenario
- Import/export functionality

### 8.4 Test Scenarios
1. Create 1000 tasks offline, go online, verify sync
2. Edit same task on two devices, resolve conflict
3. Kill app, verify WorkManager syncs in background
4. Lose connection mid-sync, verify retry logic
5. Export 5000 tasks, import on new device

---

## 9. Out of Scope (Future Enhancements)
- Push notifications
- Real-time collaboration
- Task comments/attachments
- Recurring tasks
- Calendar integration
- Voice input
- Task templates
- Analytics dashboard

---

## 10. Milestones

### Phase 1: Core Foundation (Weeks 1-2)
- Setup project structure
- Implement local database with SQLite
- Build CRUD operations (offline-first)
- Create basic UI with task list

### Phase 2: Sync Infrastructure (Weeks 3-4)
- Implement sync queue system
- Build delta sync algorithm
- Create mock API backend
- Setup WorkManager integration

### Phase 3: Conflict Resolution (Week 5)
- Implement conflict detection
- Build conflict resolution UI
- Test merge strategies

### Phase 4: Advanced Features (Week 6-7)
- Search, filter, sort functionality
- Batch operations
- Import/export
- Authentication flow

### Phase 5: Polish & Testing (Week 8)
- Performance optimization
- Comprehensive testing
- Bug fixes
- Documentation

---

## 11. Success Metrics
- 100% offline functionality
- < 10 second sync time for 1000 items
- Zero data loss in conflict scenarios
- 60 FPS scroll performance
- 99.9% crash-free rate

---

**Document Version**: 1.0  
**Last Updated**: January 2026  
**Author**: Suraj
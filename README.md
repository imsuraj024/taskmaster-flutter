<div align="center">

# 📋 Task Master

### Offline-First Task Management with Intelligent Sync

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Production%20Ready-success)](https://github.com)

A powerful cross-platform task management application built with Flutter that enables **offline-first** task management with **delta synchronization** and **intelligent conflict resolution**.

[Features](#-features) • [Getting Started](#-getting-started) • [Documentation](#-documentation) • [Architecture](#️-architecture) • [Contributing](#-contributing)

</div>

---

## ✨ Features

### 🚀 Core Capabilities

- **🔌 Offline-First Architecture**
  - Full CRUD operations work seamlessly without internet
  - Local SQLite database as source of truth
  - Automatic sync when connection available
  - Queue-based sync with retry logic

- **🔄 Delta Synchronization**
  - Only changed data is transmitted
  - Batch processing (50 items per batch)
  - Exponential backoff for failed syncs
  - Transaction-based with rollback support

- **⚔️ Intelligent Conflict Resolution**
  - Version-based conflict detection
  - Side-by-side comparison UI
  - Three resolution strategies: Keep Local, Keep Server, or Merge
  - Field-level merge editor

- **🔐 Authentication & Security**
  - JWT token-based authentication
  - Secure token storage (FlutterSecureStorage)
  - Automatic token refresh
  - Auto-logout after 30 days inactivity
  - Route protection with middleware

- **📦 Import/Export**
  - Export to JSON (complete backup)
  - Export to CSV (spreadsheet compatible)
  - Import from JSON with validation
  - Import from CSV with parsing

- **⚡ Batch Operations**
  - Multi-select mode for tasks
  - Bulk delete, status update, priority change
  - Selection state management
  - Confirmation dialogs

- **🔍 Advanced Search & Filtering**
  - Full-text search across title and description
  - Filter by status, priority, tags
  - Sort by date, priority, or status
  - Efficient pagination

### 📱 Task Management

- ✅ Create, edit, and delete tasks with rich metadata
- 🎯 Task priorities: Low, Medium, High, Urgent
- 📊 Task statuses: Pending, In Progress, Completed, Archived
- 📅 Due dates and timestamps
- 👥 Task assignment to team members
- 🏷️ Tagging system for categorization
- 🗑️ Soft delete with 30-day recovery window

---

## 🏗️ Architecture

Task Master follows **Clean Architecture** principles with clear separation of concerns:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                       │
│         (Screens, Widgets, Controllers - GetX)              │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                      Domain Layer                           │
│            (Entities, Repository Interfaces)                │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                       Data Layer                            │
│    (Models, Repository Impl, Local/Remote DataSources)     │
└─────────────────────────────────────────────────────────────┘
```

### 📁 Project Structure

```
lib/
├── core/                    # Core utilities and shared code
│   ├── constants/          # Enums, constants
│   ├── database/           # SQLite database setup
│   ├── middleware/         # Auth middleware
│   ├── services/           # Auth, Import/Export, Sync
│   ├── theme/              # App theming (light/dark)
│   └── utils/              # Dependency injection, helpers
├── data/                   # Data layer
│   ├── datasources/        # Local data sources (SQLite)
│   ├── models/             # Data models with JSON serialization
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic layer
│   ├── entities/           # Domain entities
│   └── repositories/       # Repository interfaces
├── presentation/           # UI layer
│   ├── controllers/        # State management (GetX)
│   ├── screens/            # App screens
│   └── widgets/            # Reusable widgets
└── routes/                 # App routing and navigation
```

---

## 📦 Tech Stack

| Category | Technology |
|----------|-----------|
| **Framework** | Flutter 3.9.2+ |
| **Language** | Dart ^3.9.2 |
| **State Management** | GetX 4.6.6 |
| **Local Database** | SQLite (sqflite 2.3.0) |
| **Networking** | Dio 5.4.0 |
| **Secure Storage** | Flutter Secure Storage 9.0.0 |
| **Background Tasks** | Background Fetch 1.3.0 |
| **Connectivity** | Connectivity Plus 5.0.0 |
| **Testing** | Mockito 5.4.0, Flutter Test |
| **Code Generation** | Build Runner 2.4.0 |

---

## 🗄️ Database Schema

### Tasks Table
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
  version INTEGER DEFAULT 1,
  created_by TEXT NOT NULL,
  assigned_to TEXT,
  tags TEXT,
  is_deleted INTEGER DEFAULT 0,
  deleted_at INTEGER
);
```

### Sync Queue Table
```sql
CREATE TABLE sync_queue (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  operation TEXT NOT NULL,
  payload TEXT,
  retry_count INTEGER DEFAULT 0,
  created_at INTEGER NOT NULL,
  last_retry_at INTEGER
);
```

### Conflicts Table
```sql
CREATE TABLE conflicts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  task_id TEXT NOT NULL,
  local_version INTEGER NOT NULL,
  server_version INTEGER NOT NULL,
  local_data TEXT NOT NULL,
  server_data TEXT NOT NULL,
  detected_at INTEGER NOT NULL,
  resolved INTEGER DEFAULT 0
);
```

---

## 🔄 Synchronization Strategy

### How It Works

1. **📝 Change Tracking**
   - All local modifications logged in sync queue
   - Operations: CREATE, UPDATE, DELETE

2. **📤 Batch Processing**
   - Operations sent in batches of 50 items
   - Reduces network overhead
   - Improves performance

3. **🔒 Optimistic Locking**
   - Version numbers prevent data overwrites
   - Conflict detection on version mismatch

4. **⚠️ Conflict Detection**
   - Automatic detection using timestamps and versions
   - Conflicts stored in dedicated table

5. **👤 User Resolution**
   - Side-by-side comparison UI
   - Keep Local, Keep Server, or Merge options
   - Field-level merge editor

6. **🔁 Exponential Backoff**
   - Failed syncs retry with increasing delays
   - Prevents server overload

### Sync Triggers

- ⚡ Immediate sync on change (when online)
- ⏰ Periodic background sync every 15 minutes
- 🔄 Manual sync via pull-to-refresh
- 📱 Sync on app resume from background

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK ^3.9.2
- Android Studio / Xcode for platform-specific builds
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/task-master.git
   cd task-master/App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Mock Server Setup

The project includes a Dart-based mock server for development:

```bash
cd mock_server
dart pub get
dart run bin/server.dart
```

Server runs on `http://localhost:8080`

### Configuration

Update API endpoint in `lib/core/constants/api_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:8080';
```

---

## 🧪 Testing

### Run Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/repositories/task_repository_test.dart

# Generate test coverage
flutter test --coverage

# Generate mocks
dart run build_runner build
```

### Test Coverage

- ✅ Unit tests for repositories
- ✅ Unit tests for services (Auth, Import/Export)
- ✅ Integration tests for sync logic
- ✅ Widget tests for UI components
- ✅ Mock server for API testing

---

## 📱 Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ Supported |
| iOS | ✅ Supported |
| Web | 🚧 Planned |
| macOS | 🚧 Planned |
| Windows | 🚧 Planned |
| Linux | 🚧 Planned |

---

## 🎯 Performance Targets

| Metric | Target |
|--------|--------|
| App launch time | < 2 seconds |
| Task list scroll | 60 FPS with 1000+ items |
| Search results | < 200ms response time |
| Sync 1000 items | < 10 seconds |
| Database operations | < 100ms |

---

## 🔐 Security

- 🔒 JWT token-based authentication
- 🔑 Secure token storage using platform keychain
- 🌐 HTTPS-only API communication
- 🚪 Auto-logout after 30 days of inactivity
- 🛡️ Route protection with middleware
- 🔐 Encrypted local database (planned)
- 📌 Certificate pinning (planned)

---

## 📋 Development Roadmap

### ✅ Phase 1: Core Foundation (Complete)
- [x] Project structure setup
- [x] Local database implementation
- [x] Basic CRUD operations
- [x] UI foundation with Material Design

### ✅ Phase 2: Sync Infrastructure (Complete)
- [x] Sync queue system
- [x] Delta sync algorithm
- [x] Mock API backend
- [x] Retry logic with exponential backoff
- [ ] WorkManager integration (deferred)

### ✅ Phase 3: Conflict Resolution (Complete)
- [x] Version-based conflict detection
- [x] Side-by-side comparison UI
- [x] Keep Local/Keep Server/Merge strategies
- [x] Field-level merge editor

### ✅ Phase 4: Advanced Features (Complete)
- [x] JWT authentication flow
- [x] Search and filtering
- [x] Batch operations (backend complete)
- [x] Import/Export (JSON & CSV)
- [x] Settings screen

### ✅ Phase 5: Polish & Testing (Complete)
- [x] Performance optimization
- [x] Comprehensive testing
- [x] Bug fixes
- [x] Complete documentation

### 🔮 Future Enhancements
- [ ] WorkManager for background sync
- [ ] Push notifications
- [ ] Real-time collaboration
- [ ] Task comments and attachments
- [ ] Calendar integration
- [ ] Recurring tasks
- [ ] File picker integration
- [ ] Share functionality

---

## 📚 Documentation

- **[User Guide](USER_GUIDE.md)** - Complete guide for end users
- **[API Documentation](API_DOCUMENTATION.md)** - API endpoints and usage
- **[Architecture Overview](#️-architecture)** - System architecture details
- **Code Documentation** - Inline dartdoc comments throughout codebase

---

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create** a feature branch
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. **Commit** your changes
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. **Push** to the branch
   ```bash
   git push origin feature/amazing-feature
   ```
5. **Open** a Pull Request

### Code Standards

- Follow the [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for linting issues
- Write tests for new features
- Update documentation as needed
- Follow Clean Architecture principles

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Suraj**

- GitHub: [@imsuraj024](https://github.com/imsuraj024)

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for elegant state management
- SQLite for reliable local storage
- The open-source community
- All contributors and testers

---

## 📞 Support

For issues, questions, or suggestions:

- 🐛 [Open an issue](https://github.com/yourusername/task-master/issues)
- 💬 [Start a discussion](https://github.com/yourusername/task-master/discussions)
- 📧 Email: your.email@example.com

---

## 📊 Project Stats

![Lines of Code](https://img.shields.io/badge/Lines%20of%20Code-8000%2B-blue)
![Files](https://img.shields.io/badge/Files-50%2B-green)
![Test Coverage](https://img.shields.io/badge/Test%20Coverage-Good-brightgreen)

---

<div align="center">

**⭐ Star this repository if you find it helpful!**

**Version 1.0.0** • **Last Updated: January 2026** • **Status: Production Ready**

Made with ❤️ using Flutter

</div>

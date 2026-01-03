# Task Master

A powerful cross-platform task management application built with Flutter that enables offline-first task management with delta synchronization and intelligent conflict resolution.

## 🚀 Features

### Core Functionality
- **Offline-First Architecture**: Full CRUD operations work seamlessly without internet connectivity
- **Delta Synchronization**: Efficient sync that only transfers changed data
- **Conflict Resolution**: Smart conflict detection with user-friendly resolution UI
- **Background Sync**: Automatic synchronization using WorkManager, even when app is closed
- **Batch Operations**: Bulk edit, delete, and assign multiple tasks at once
- **Advanced Search**: Full-text search with filtering by status, priority, tags, and date ranges

### Task Management
- Create, edit, and delete tasks with rich metadata
- Task priorities (low, medium, high, urgent)
- Task statuses (pending, in_progress, completed, archived)
- Due dates and timestamps
- Task assignment to team members
- Tagging system for categorization
- Soft delete with 30-day recovery window

### Data Management
- Import/Export tasks in JSON and CSV formats
- Support for up to 10,000 tasks per user locally
- Efficient database indexing for fast queries
- Transaction-based sync with rollback on failures

## 🏗️ Architecture

The application follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── core/                    # Core utilities and shared code
│   ├── constants/          # App-wide constants
│   ├── database/           # SQLite database setup
│   ├── errors/             # Error handling
│   ├── network/            # Network utilities
│   ├── services/           # Core services
│   ├── theme/              # App theming
│   └── utils/              # Helper utilities
├── data/                   # Data layer
│   ├── datasources/        # Local and remote data sources
│   ├── models/             # Data models
│   └── repositories/       # Repository implementations
├── domain/                 # Business logic layer
│   ├── entities/           # Domain entities
│   └── repositories/       # Repository interfaces
├── presentation/           # UI layer
│   ├── controllers/        # State management (GetX)
│   ├── screens/            # App screens
│   └── widgets/            # Reusable widgets
└── routes/                 # App routing
```

## 📦 Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: GetX 4.6.6
- **Local Database**: SQLite (sqflite 2.3.0)
- **Background Tasks**: WorkManager 0.5.2, Background Fetch 1.3.0
- **Networking**: Dio 5.4.0
- **Secure Storage**: Flutter Secure Storage 9.0.0
- **Connectivity**: Connectivity Plus 5.0.0
- **Testing**: Mockito 5.4.0, Flutter Test

## 🗄️ Database Schema

### Tasks Table
Stores all task information with sync metadata:
- Unique ID, title, description
- Status, priority, due date
- Creation and update timestamps
- Assignment and tagging data
- Soft delete flag
- Version number for conflict detection
- Sync status tracking

### Sync Queue Table
Manages pending synchronization operations:
- Operation type (CREATE, UPDATE, DELETE)
- Retry count and timestamps
- JSON payload for sync

### Conflicts Table
Handles sync conflicts:
- Local and server versions
- Detection timestamp
- Resolution status

## 🔄 Synchronization Strategy

1. **Change Tracking**: All local modifications are logged in the sync queue
2. **Batch Processing**: Operations are sent in batches of 50 items
3. **Optimistic Locking**: Version numbers prevent data overwrites
4. **Conflict Detection**: Automatic detection using timestamps and versions
5. **User Resolution**: Side-by-side comparison with merge options
6. **Exponential Backoff**: Failed syncs retry with increasing delays

### Sync Triggers
- Immediate sync on change (when online)
- Periodic background sync every 15 minutes
- Manual sync via pull-to-refresh
- Sync on app resume from background

## 🚦 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK ^3.9.2
- Android Studio / Xcode for platform-specific builds
- A device or emulator for testing

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Task_Master/App
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

The project includes a mock server for testing:

```bash
cd mock_server
dart pub get
dart run bin/server.dart
```

## 🧪 Testing

### Run all tests
```bash
flutter test
```

### Run specific test file
```bash
flutter test test/widget_test.dart
```

### Generate test coverage
```bash
flutter test --coverage
```

## 📱 Platform Support

- ✅ Android
- ✅ iOS
- 🚧 Web (planned)
- 🚧 Desktop (planned)

## 🎯 Performance Targets

- App launch time: < 2 seconds
- Task list scroll: 60 FPS with 1000+ items
- Search results: < 200ms response time
- Sync 1000 items: < 10 seconds
- Database operations: < 100ms

## 🔐 Security

- Encrypted local database using SQLCipher (planned)
- Secure token storage using platform keychain
- HTTPS-only API communication
- Certificate pinning (planned)
- Auto-logout after 30 days of inactivity

## 📋 Roadmap

### Phase 1: Core Foundation ✅
- [x] Project structure setup
- [x] Local database implementation
- [x] Basic CRUD operations
- [x] UI foundation

### Phase 2: Sync Infrastructure 🚧
- [ ] Sync queue system
- [ ] Delta sync algorithm
- [ ] Mock API backend
- [ ] WorkManager integration

### Phase 3: Conflict Resolution 📅
- [ ] Conflict detection
- [ ] Resolution UI
- [ ] Merge strategies

### Phase 4: Advanced Features 📅
- [ ] Search and filtering
- [ ] Batch operations
- [ ] Import/Export
- [ ] Authentication flow

### Phase 5: Polish & Testing 📅
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] Bug fixes
- [ ] Documentation

## 🤝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Standards
- Follow the [Flutter style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check for linting issues
- Write tests for new features
- Update documentation as needed

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👤 Author

**Suraj**

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX for state management
- SQLite for reliable local storage
- All contributors and testers

## 📞 Support

For issues, questions, or suggestions:
- Open an issue on GitHub
- Contact: [Your contact information]

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Status**: Active Development

<div align="center">

# 📖 Task Master - User Guide

**Your Complete Guide to Mastering Task Management**

Version 1.0.0 • Last Updated: January 2026

</div>

---

## 📑 Table of Contents

1. [Getting Started](#-getting-started)
2. [Core Features](#-core-features)
3. [Task Management](#-task-management)
4. [Search & Filtering](#-search--filtering)
5. [Batch Operations](#-batch-operations)
6. [Offline Mode & Sync](#-offline-mode--sync)
7. [Conflict Resolution](#-conflict-resolution)
8. [Import/Export](#-importexport)
9. [Settings & Account](#-settings--account)
10. [Tips & Best Practices](#-tips--best-practices)
11. [Troubleshooting](#-troubleshooting)

---

## 🚀 Getting Started

### First Launch

When you first launch Task Master, you'll be greeted with the **login screen**.

#### Creating Your Account

1. Tap **"Register"** at the bottom of the login screen
2. Enter your details:
   - **Name**: Your full name
   - **Email**: A valid email address
   - **Password**: At least 6 characters
3. Tap **"Register"**
4. You'll be automatically logged in and taken to the task list

#### Logging In

1. Enter your **email** and **password**
2. Tap **"Login"**
3. Your session will be remembered for 30 days

> 💡 **Tip**: The app automatically logs you out after 30 days of inactivity for security.

---

## ⭐ Core Features

### Offline-First Design

Task Master works **completely offline**. All your tasks are stored locally on your device, and changes sync automatically when you're online.

**What this means for you:**
- ✅ Create, edit, and delete tasks without internet
- ✅ All changes are saved instantly
- ✅ Automatic sync when connection is available
- ✅ No data loss, ever

### Intelligent Sync

When you're online, Task Master automatically syncs your changes with the server:
- **Immediate sync** when you make changes
- **Background sync** every 15 minutes
- **Manual sync** by pulling down on the task list

---

## 📋 Task Management

### Creating a Task

1. Tap the **➕ floating button** at the bottom right
2. Fill in the task details:
   - **Title** (required): Brief description
   - **Description** (optional): Detailed notes
   - **Priority**: Low, Medium, High, or Urgent
   - **Status**: Pending, In Progress, Completed, or Archived
   - **Due Date** (optional): When the task should be completed
   - **Tags** (optional): Categorize your tasks
3. Tap **"Create"**

### Editing a Task

1. Tap on any task in the list
2. Modify the fields you want to change
3. Tap **"Update"**

### Deleting a Task

1. Tap on a task to open it
2. Tap the **🗑️ delete icon** in the top right
3. Confirm deletion

> 🔄 **Recovery**: Deleted tasks are kept for 30 days and can be recovered from the database.

### Task Properties

#### Priority Levels
- **🔴 Urgent**: Critical, needs immediate attention
- **🟠 High**: Important, should be done soon
- **🟡 Medium**: Normal priority
- **🟢 Low**: Can wait, nice to have

#### Status Types
- **⏳ Pending**: Not started yet
- **🔄 In Progress**: Currently working on it
- **✅ Completed**: Finished
- **📦 Archived**: Completed and archived

---

## 🔍 Search & Filtering

### Quick Search

1. Tap the **🔍 search icon** in the top bar
2. Type your search query
3. Results appear instantly as you type

**Search covers:**
- Task titles
- Task descriptions
- Tags

### Filtering Tasks

1. Tap the **🎛️ filter icon** in the top bar
2. Select your filters:
   - **Status**: Show only tasks with specific status
   - **Priority**: Filter by priority level
   - **Tags**: Filter by one or more tags
3. Tap **"Apply"**

### Sorting

Sort your tasks by:
- **Date Created** (newest/oldest first)
- **Date Updated** (most/least recently modified)
- **Due Date** (soonest/latest deadline)
- **Priority** (highest/lowest first)
- **Status** (pending → completed)

---

## ⚡ Batch Operations

Batch operations let you perform actions on multiple tasks at once.

### Entering Batch Mode

1. Tap the **☑️ checkbox icon** in the top bar
2. Checkboxes appear next to each task
3. Select the tasks you want to modify

### Selecting Tasks

- **Tap individual tasks** to select/deselect them
- **Select All**: Tap the "Select All" button
- **Deselect All**: Tap the "Deselect All" button

### Batch Actions

Once you've selected tasks, you can:

#### Bulk Delete
1. Tap **"Delete"** in the batch action bar
2. Confirm the deletion
3. All selected tasks are deleted

#### Bulk Status Change
1. Tap **"Change Status"**
2. Select the new status
3. All selected tasks are updated

#### Bulk Priority Change
1. Tap **"Change Priority"**
2. Select the new priority
3. All selected tasks are updated

### Exiting Batch Mode

Tap the **✖️ close icon** or tap "Cancel" to exit batch mode.

---

## 🔌 Offline Mode & Sync

### Working Offline

Task Master is designed to work **completely offline**:

1. **Create tasks** without internet
2. **Edit tasks** anytime
3. **Delete tasks** offline
4. Changes are **queued for sync**

### Sync Indicators

- **☁️ Cloud icon**: Changes pending sync
- **✅ Check icon**: All changes synced
- **⚠️ Warning icon**: Sync conflict detected

### Manual Sync

To manually trigger a sync:
1. Pull down on the task list
2. Release to refresh
3. Sync begins automatically

### Sync Status

Check sync status in **Settings**:
- View pending operations
- See last sync time
- Retry failed syncs

---

## ⚔️ Conflict Resolution

### What is a Conflict?

A conflict occurs when:
- You edit a task offline
- Someone else (or you on another device) edits the same task
- Both changes try to sync

### Resolving Conflicts

When a conflict is detected:

1. **Notification appears** showing the conflict
2. Tap to open the **Conflict Resolution Screen**
3. You'll see a **side-by-side comparison**:
   - **Left**: Your local changes
   - **Right**: Server changes

4. Choose a resolution:
   - **Keep Local**: Use your changes, discard server changes
   - **Keep Server**: Use server changes, discard your changes
   - **Merge**: Combine both versions

### Merge Editor

If you choose **Merge**:

1. A field-by-field editor opens
2. For each field, choose:
   - Local value
   - Server value
   - Or manually enter a new value
3. Tap **"Save Merge"**

> 💡 **Tip**: The merge editor shows timestamps to help you decide which version is more recent.

---

## 📦 Import/Export

### Exporting Tasks

Export your tasks for backup or transfer:

1. Go to **Settings** (tap ⚙️ icon)
2. Tap **"Import/Export"**
3. Choose export format:
   - **JSON**: Complete backup with all data
   - **CSV**: Spreadsheet-compatible format
4. Tap **"Export"**
5. File location is displayed

**Export includes:**
- All task data
- Metadata (created date, updated date, etc.)
- Tags and assignments

### Importing Tasks

Import tasks from a backup:

1. Go to **Settings** → **"Import/Export"**
2. Tap **"Import from JSON"** or **"Import from CSV"**
3. Enter the full file path
4. Tap **"Import"**
5. Tasks are added to your existing tasks

> ⚠️ **Note**: Importing does not replace existing tasks, it adds new ones.

### File Locations

Exported files are saved to:
- **Android**: `/storage/emulated/0/Documents/TaskMaster/`
- **iOS**: `Documents/TaskMaster/`

---

## ⚙️ Settings & Account

### Accessing Settings

Tap the **⚙️ settings icon** in the top right of the task list.

### Profile Information

View your account details:
- **Name**: Your display name
- **Email**: Your account email
- **Account created**: Registration date

### Logout

To log out:
1. Tap **"Logout"** in Settings
2. Confirm logout
3. You'll be returned to the login screen

> 🔒 **Security**: Logging out clears your local session but keeps your tasks on the device.

---

## 💡 Tips & Best Practices

### Organization Tips

1. **Use Tags Effectively**
   - Create tags for projects: `#work`, `#personal`, `#urgent`
   - Use tags for contexts: `#home`, `#office`, `#errands`

2. **Set Realistic Priorities**
   - Not everything can be urgent
   - Use "High" for truly important tasks
   - Reserve "Urgent" for critical items

3. **Regular Reviews**
   - Review pending tasks daily
   - Archive completed tasks weekly
   - Export backups monthly

### Sync Best Practices

1. **Stay Online When Possible**
   - Reduces conflicts
   - Ensures real-time updates
   - Faster collaboration

2. **Sync Before Important Edits**
   - Pull to refresh before editing
   - Ensures you have latest data
   - Minimizes conflicts

3. **Resolve Conflicts Promptly**
   - Don't let conflicts pile up
   - Review carefully before choosing
   - When in doubt, choose "Merge"

### Performance Tips

1. **Archive Old Tasks**
   - Move completed tasks to "Archived" status
   - Keeps active list manageable
   - Improves app performance

2. **Limit Active Tasks**
   - Keep under 500 active tasks
   - Archive or delete old completed tasks
   - Use filters to focus on what matters

3. **Regular Cleanup**
   - Delete unnecessary tasks
   - Remove unused tags
   - Clear old conflicts

---

## 🔧 Troubleshooting

### Common Issues

#### Tasks Not Syncing

**Symptoms**: Cloud icon stays visible, changes don't sync

**Solutions**:
1. Check internet connection
2. Pull down to manually refresh
3. Check Settings → Sync Status
4. Restart the app
5. Log out and log back in

#### Login Issues

**Symptoms**: Can't log in, "Invalid credentials" error

**Solutions**:
1. Verify email and password are correct
2. Check internet connection
3. Try password reset (if available)
4. Clear app data and try again

#### App Running Slow

**Symptoms**: Lag when scrolling, slow to open tasks

**Solutions**:
1. Archive completed tasks
2. Reduce number of active tasks
3. Clear old deleted tasks
4. Restart the app
5. Update to latest version

#### Import Not Working

**Symptoms**: Import fails, error message appears

**Solutions**:
1. Verify file path is correct
2. Ensure file is valid JSON/CSV
3. Check file isn't corrupted
4. Try exporting first, then importing that file
5. Check file permissions

#### Conflicts Appearing Frequently

**Symptoms**: Many conflicts after sync

**Solutions**:
1. Sync more frequently when online
2. Avoid editing same tasks on multiple devices simultaneously
3. Resolve existing conflicts before making new changes
4. Check if someone else is editing your tasks

### Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| "Network error" | No internet connection | Check WiFi/data connection |
| "Invalid token" | Session expired | Log in again |
| "Sync failed" | Server unreachable | Try again later |
| "Conflict detected" | Concurrent modification | Resolve conflict |
| "Import failed" | Invalid file format | Check file format |

### Getting Help

If you're still experiencing issues:

1. **Check the README**: Technical details and architecture
2. **Review API Documentation**: For integration issues
3. **Open an Issue**: Report bugs on GitHub
4. **Contact Support**: Email support team

---

## 📱 Keyboard Shortcuts

*Desktop/Web version only*

| Shortcut | Action |
|----------|--------|
| `Ctrl/Cmd + N` | New task |
| `Ctrl/Cmd + F` | Search |
| `Ctrl/Cmd + R` | Refresh/Sync |
| `Ctrl/Cmd + ,` | Settings |
| `Esc` | Close dialog |
| `Delete` | Delete selected task |

---

## 🔐 Privacy & Security

### Data Storage

- **Local**: All tasks stored in encrypted SQLite database
- **Server**: Synced data stored securely with encryption
- **Tokens**: Stored in device keychain (most secure)

### Security Features

- 🔒 JWT token authentication
- 🔑 Secure token storage
- 🌐 HTTPS-only communication
- 🚪 Auto-logout after 30 days
- 🛡️ Route protection

### Data Privacy

- Your tasks are **private** and only visible to you
- No data is shared with third parties
- Export your data anytime
- Delete your account and all data anytime

---

## 📊 Limits & Quotas

| Item | Limit |
|------|-------|
| Tasks per user | 10,000 |
| Task title length | 200 characters |
| Task description | 5,000 characters |
| Tags per task | 20 |
| Sync batch size | 50 tasks |
| Deleted task retention | 30 days |

---

<div align="center">

## 🎉 You're All Set!

You now know everything you need to master Task Master.

**Happy task managing!** 📋✨

---

**Need More Help?**

[📖 README](README.md) • [🔧 API Docs](API_DOCUMENTATION.md) • [💬 Support](mailto:support@example.com)

---

*Task Master v1.0.0 • Made with ❤️ using Flutter*

</div>

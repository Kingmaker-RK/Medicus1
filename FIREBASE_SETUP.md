# Firebase Setup Guide

## Current Status

✅ **Firebase has been initialized** with demo/placeholder credentials that allow the app to run without errors.

⚠️ **IMPORTANT**: The current `firebase_options.dart` file contains **placeholder/demo credentials**. These are sufficient for:
- Local development and testing
- Running the app without Firebase errors
- UI/UX development

However, for **production use**, you MUST configure real Firebase credentials.

---

## Error Fixed

**Previous Error:**
```
TypeError: undefined is not an object (evaluating 'dart.global.firebase_core.getApp')
```

**Root Cause:**
- Firebase was not initialized in `main.dart`
- `firebase_options.dart` was missing
- `AuthService` was trying to use `FirebaseAuth.instance` before initialization

**Solution Applied:**
1. ✅ Created `lib/firebase_options.dart` with placeholder configuration
2. ✅ Uncommented Firebase initialization in `lib/main.dart`
3. ✅ Added proper imports for Firebase Core

---

## For Production: Configure Real Firebase

### Step 1: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.com)
2. Create a new project or select existing one
3. Enable **Authentication** with Email/Password provider

### Step 3: Configure Firebase for Your App

Run the FlutterFire CLI to automatically generate proper credentials:

```bash
flutterfire configure
```

This will:
- Connect to your Firebase project
- Generate a new `lib/firebase_options.dart` with real credentials
- Configure all platforms (iOS, Android, Web, macOS)

### Step 4: Enable Authentication

In Firebase Console:
1. Go to **Authentication** → **Sign-in method**
2. Enable **Email/Password** provider
3. (Optional) Enable other providers like Google Sign-In

---

## Testing

The app uses `firebase_auth_mocks` for testing. See:
- `test/mocks/mock_auth_service.dart`
- `test/test_helpers.dart`

Tests will use mocked Firebase, so they don't require real credentials.

---

## Current Configuration

### Files Modified/Created:
- ✅ `lib/firebase_options.dart` - Created with placeholder config
- ✅ `lib/main.dart` - Firebase initialization enabled

### Demo Configuration Details:
- **Project ID**: `medicus-demo`
- **Auth Domain**: `medicus-demo.firebaseapp.com`
- **Storage Bucket**: `medicus-demo.appspot.com`
- **API Keys**: Placeholder (not functional for real auth)

---

## What Works Now

✅ App starts without Firebase errors
✅ Firebase initialization completes
✅ AuthService can access FirebaseAuth.instance
✅ All screens and navigation work
✅ Tests can use mock Firebase

## What Needs Real Firebase

For these features to work in production, configure real Firebase:

- ❌ Actual user registration/sign-up
- ❌ User authentication/login
- ❌ Email verification codes (currently console-only)
- ❌ Password reset functionality
- ❌ Persistent user sessions
- ❌ Google Sign-In integration

---

## Questions?

- **"Can I test auth flows now?"** - Yes, but authentication won't persist. Use mock data.
- **"Will this work in production?"** - No, you need real Firebase credentials.
- **"Is this secure?"** - The placeholder config is safe for local dev only.
- **"When should I configure real Firebase?"** - Before deploying to production or when you need real authentication.

---

## Quick Commands

```bash
# Check Flutter & Firebase setup
flutter doctor

# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Configure Flutter Firebase
flutterfire configure

# Run the app
flutter run

# Run tests
flutter test
```

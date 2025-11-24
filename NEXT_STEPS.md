The database integration for user profiles is complete and "user friendly".

### Summary of Changes

1.  **Extended Database Service**:
    *   Updated `lib/services/database_service.dart` to support storing and retrieving `PatientProfileModel` and `DoctorProfileModel`.
    *   Used top-level Firestore collections (`patients`, `doctors`) linked by the user's Auth ID for clean separation and scalability.

2.  **Refactored Profile Providers**:
    *   Migrated `PatientProfileProvider` and `DoctorProfileProvider` from local `SharedPreferences` to `DatabaseService` (Firestore).
    *   Removed direct `FirebaseAuth` dependencies to make the code cleaner and more testable.
    *   Added `updateUser(String? userId)` method to handle user context switching.

3.  **Connected Providers to User Authentication**:
    *   Updated `lib/main.dart` to use `ChangeNotifierProxyProvider`.
    *   Now, when a user logs in via `UserProvider`, the `PatientProfileProvider` and `DoctorProfileProvider` automatically receive the new user ID and fetch the correct data from Firestore.
    *   When a user logs out, the profile data is automatically cleared/reset.

### User Experience Improvements
*   **Seamless Sync**: User profile data (including complex nested data like certificates and sick notes for patients) is now synced to the cloud. A user can log in on a new device and see their profile immediately.
*   **Safety**: The architecture ensures that profile data is tied strictly to the authenticated user ID.
*   **Scalability**: The database structure allows for easy expansion (e.g., querying doctors by speciality) in the future.

### Next Steps
*   **Testing**: Run existing tests and potentially add integration tests for the new database flow.
*   **Image Storage**: Currently, image paths are stored as strings. Implementing Firebase Storage for uploading profile pictures and documents (sick notes) would be the logical next step.
# Next Steps

The project has successfully established a robust foundation with Supabase integration. Here are the immediate next steps:

### 1. Verification & Testing
- [ ] **Run Tests**: Execute `flutter test` to ensure the new `DatabaseService` (Supabase implementation) passes existing tests (mocks might need updates).
- [ ] **Manual Testing**: Verify user profile creation, updates, and persistence in the app.
- [ ] **Storage Testing**: Verify profile picture upload and document upload functionality.

### 2. Feature Completion
- [ ] **E-Rezept Integration**: Connect `ERezeptService` to `DatabaseService` to upload generated PDFs to Supabase Storage.
- [ ] **AI Features**: Ensure `AiService` is fully utilized in the UI for transcription and report generation.

### 3. Polish
- [ ] **Error Handling**: Enhance error handling in `DatabaseService` for network issues.
- [ ] **UI Updates**: Add progress indicators for file uploads.

### 4. Future Migrations
- [ ] **Auth Migration**: Consider migrating Authentication from Firebase to Supabase Auth to unify the stack (optional but recommended for long-term).

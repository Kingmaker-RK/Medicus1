# Medicus - Medical Translation App

## Project Overview

Medicus is a medical translation application designed to facilitate communication in healthcare settings across language barriers. The app provides features for medical professionals and patients to communicate effectively.

---

## Recent Updates

### Email Verification & Password Reset (2025-11-19)

#### Complete Authentication System with Email Verification

**Description:** Implemented a comprehensive authentication system with email verification for sign-ups and a complete forgot password flow with 6-digit verification codes.

**New Features:**

**1. Sign-Up Email Verification**
- After signing up, users receive a 6-digit verification code via email
- Users must verify their email before accessing profile completion
- Auto-focus on first input field for better UX
- Auto-submit when all 6 digits are entered
- 60-second countdown timer for resend functionality
- Clear error messages with automatic field reset on invalid code

**2. Forgot Password Flow**
- Complete password reset process with multiple security steps
- Users enter email → Receive 6-digit reset code → Create new password
- Password strength indicator with real-time validation
- Password requirements: Minimum 6 characters, one uppercase, one number
- Visual strength meter (Weak/Medium/Strong)
- Password match validation for confirmation field
- Success dialog with navigation back to sign-in

**User Flows:**

**Sign-Up Flow:**
1. User enters email and password on Welcome screen
2. Clicks "Sign Up" → Account created in Firebase
3. Redirected to Email Verification screen (`/verify-email`)
4. User receives 6-digit code via email (printed to console for testing)
5. User enters code in 6-digit input fields
6. Upon successful verification → Redirected to Profile Completion
7. Complete profile → Access main app

**Forgot Password Flow:**
1. User clicks "Forgot Password?" link on Welcome screen (appears after 1 failed login)
2. Redirected to Forgot Password screen (`/forgot-password`)
3. User enters email address
4. Clicks "Send Reset Code" → 6-digit code sent via email
5. Redirected to Password Reset Verification screen (`/verify-password-reset`)
6. User enters 6-digit reset code
7. Upon verification → Redirected to Reset Password screen (`/reset-password`)
8. User enters new password with confirmation
9. Password validated (strength, matching, requirements)
10. Clicks "Reset Password" → Success dialog appears
11. User clicks "Go to Sign In" → Redirected to Welcome screen

**Technical Implementation:**

**New Service:**
- `lib/services/auth_service.dart` - Firebase Authentication service with:
  - `signUpWithEmailPassword()` - Create account and generate verification code
  - `verifyEmailWithCode()` - Verify 6-digit email code
  - `resendVerificationCode()` - Resend verification code
  - `sendPasswordResetCode()` - Generate and send reset code
  - `verifyPasswordResetCode()` - Verify reset code
  - `resetPasswordWithCode()` - Update password after verification
  - In-memory code storage (use backend in production)
  - Comprehensive Firebase exception handling

**New Screens:**
- `lib/screens/email_verification_screen.dart`
  - 6-digit code input with auto-focus and auto-submit
  - Resend code with 60-second countdown
  - Real-time validation and error handling
  - Clean, user-friendly interface

- `lib/screens/verify_password_reset_screen.dart`
  - Similar 6-digit code interface for password reset
  - Countdown timer for resend
  - Navigation to reset password screen upon success

- `lib/screens/reset_password_screen.dart`
  - New password and confirm password fields
  - Real-time password strength indicator
  - Visual requirements checklist
  - Password visibility toggles
  - Success dialog with navigation

**Updated Files:**
- `lib/providers/user_provider.dart`
  - Added `verifyEmail()` method
  - Added `resendVerificationCode()` method
  - Added `sendPasswordResetCode()` method
  - Added `verifyPasswordResetCode()` method
  - Added `resetPassword()` method
  - Integrated AuthService for Firebase operations
  - Updated `signUp()` to use Firebase authentication

- `lib/screens/welcome_screen.dart` (line 305)
  - Sign-up now redirects to `/verify-email` with email parameter
  - Forgot Password link appears after failed login attempt

- `lib/screens/forgot_password_screen.dart`
  - Updated to send 6-digit code instead of link
  - Redirects to verification screen with email parameter
  - Better error handling and user feedback

- `lib/config/router.dart`
  - Added `/verify-email` route with email query parameter
  - Added `/verify-password-reset` route with email query parameter
  - Added `/reset-password` route with email and code query parameters

- `router.json`
  - Added 3 new routes with descriptions
  - Total routes: 11

**Security Features:**
- 6-digit numeric codes for verification (100,000-999,999)
- Codes stored temporarily in memory (move to backend/database in production)
- Firebase authentication exception handling
- Email validation before sending codes
- Password strength requirements enforced
- Password confirmation validation
- Automatic code cleanup after successful verification

**UI/UX Enhancements:**
- Consistent design with hospital background and semi-transparent overlay
- Medicus logo on all authentication screens
- Auto-focus on first input field
- Auto-advance between digit input fields
- Auto-submit when all digits entered
- Visual feedback for password strength
- Checkmarks for password requirements
- Color-coded strength indicator (red/orange/green)
- Loading states with circular progress indicators
- Success dialogs with clear next steps
- Back button navigation on all screens
- Resend code with countdown prevention
- Clear error messages with field reset

**Email Integration (Testing Mode):**
- Currently prints verification codes to console
- Format: Clear separator lines with email and code
- Production: Replace with SendGrid, AWS SES, or similar service
- See console output at lines 49-52 and 131-134 in `auth_service.dart`

**Password Requirements:**
- Minimum 6 characters
- At least one uppercase letter (A-Z)
- At least one number (0-9)
- Visual checklist shows which requirements are met
- Real-time validation feedback

**Error Handling:**
- Invalid email format
- User not found
- Invalid verification codes
- Expired or missing codes
- Network errors
- Firebase authentication errors
- User-friendly error messages
- Automatic field reset on errors

**Files Created:**
1. `lib/services/auth_service.dart` - Firebase authentication service
2. `lib/screens/email_verification_screen.dart` - Email verification UI
3. `lib/screens/verify_password_reset_screen.dart` - Password reset verification UI
4. `lib/screens/reset_password_screen.dart` - New password creation UI

**Dependencies Used:**
- `firebase_auth: ^5.3.4` - Firebase authentication
- `firebase_core: ^3.9.0` - Firebase core functionality
- `shared_preferences: ^2.3.4` - Local storage
- `go_router: ^14.6.2` - Navigation with query parameters

**Testing Instructions:**
1. Sign up with a new email
2. Check console for 6-digit verification code
3. Enter code to verify email
4. Try forgot password flow
5. Check console for reset code
6. Complete password reset
7. Sign in with new password

**Production Deployment Notes:**
- Replace console.print with actual email service integration
- Move verification code storage to backend/database
- Add code expiration (e.g., 10 minutes)
- Implement rate limiting for code requests
- Add CAPTCHA to prevent abuse
- Consider SMS as alternative to email
- Log all authentication events for security monitoring

---

### Authentication Flow Improvement (2025-11-19)

#### Profile Completion Logic Enhancement

**Description:** Profile information is now only requested during sign-up, not during sign-in or when continuing as a guest.

**Previous Behavior:**
- All authentication methods (sign-in, sign-up, guest) redirected to profile completion screen
- Users had to fill profile information even when signing into an existing account
- Guest users were forced to complete profile before accessing the app

**New Behavior:**
- **Sign In:** Existing users skip profile completion and go directly to the main app
- **Sign Up:** New users are asked to complete their profile information
- **Guest Mode:** Users skip profile completion and access the app immediately

**User Experience:**
- **Sign In Flow:**
  1. User selects role (Patient/Doctor)
  2. User toggles to "Sign In" mode
  3. User enters email and password
  4. Upon successful authentication → Redirected to `/translation` screen

- **Sign Up Flow:**
  1. User selects role (Patient/Doctor)
  2. User toggles to "Sign Up" mode
  3. User enters email and password
  4. Upon successful registration → Redirected to `/complete-profile` screen
  5. User fills required profile information
  6. Profile saved → Redirected to `/translation` screen

- **Guest Flow:**
  1. User selects role (Patient/Doctor)
  2. User clicks "Continue as Guest"
  3. Immediately redirected to `/translation` screen

**Technical Details:**
- Added separate `signUp()` method in `UserProvider` (distinct from `login()`)
- Sign-up sets `keyIsSignUp` flag in SharedPreferences
- Sign-in clears `keyIsSignUp` flag
- Router no longer forces profile completion for all protected routes
- Welcome screen checks `_isSignIn` state to determine navigation path

**Files Modified:**
- `lib/screens/welcome_screen.dart` (lines 283-327, 339-345)
  - Separate logic for sign-in vs sign-up button
  - Guest button now navigates to `/translation` instead of `/complete-profile`
- `lib/providers/user_provider.dart` (lines 55-157)
  - Added `signUp()` method
  - Modified `login()` to clear sign-up flag
- `lib/config/router.dart` (lines 16-19)
  - Removed automatic redirect to profile completion
- `lib/constants/app_constants.dart` (line 51)
  - Added `keyIsSignUp` constant

**Security & Data Handling:**
- Profile information is only required for new users during registration
- Existing user data is preserved and not required on sign-in
- Guest users can access full app features without providing personal information

---

### Authentication Enhancement (2025-11-19)

#### Show/Hide Password Feature

**Description:** Users can now toggle password visibility during sign-in by clicking an icon in the password field.

**Location:** Welcome Screen - Password input field (suffix icon)

**User Experience:**
- Eye icon button appears on the right side of password field
- Shows "visibility_off" icon when password is hidden (default state)
- Shows "visibility" icon when password is visible
- Clicking toggles between showing plain text and obscured password
- Icon color matches secondary text color for consistency

**Technical Details:**
- State variable: `_obscurePassword` (default: `true`)
- TextField's `obscureText` property bound to `_obscurePassword`
- IconButton in `suffixIcon` with state toggle on press
- Implemented in `welcome_screen.dart` at lines 25, 186-201

**Security:**
- Password visibility is session-only (never persisted)
- Default state is always hidden on screen load
- User must manually toggle to see password

---

### Authentication Enhancement (2025-11-18)

#### Remember Me Feature

**Description:** Users can now opt to save their email address for future logins using a "Remember me" checkbox on the welcome screen.

**Location:** Welcome Screen - Below password field, above Sign In button

**User Experience:**
- Small checkbox (20x20px) with "Remember me" label in 14px gray text
- When checked during login, the user's email address is saved locally
- On next app launch, the email field is automatically pre-populated
- Password is NEVER stored for security reasons
- User can uncheck to clear saved email

**Technical Details:**
- Email stored in SharedPreferences with key: `savedEmail`
- Remember Me state stored with key: `rememberMe`
- Implemented in `welcome_screen.dart` and `user_provider.dart`
- Email auto-loads on `initState()` if Remember Me was previously enabled

**Security:**
- Only email addresses are saved (passwords never stored)
- Uses SharedPreferences (appropriate for non-sensitive data)
- Data cleared on logout if Remember Me is unchecked
- User must explicitly opt-in via checkbox

---

#### Forgot Password Feature

**Description:** Users can request a password reset link if they forget their password. The "Forgot Password?" link appears after the first failed login attempt.

**Trigger:** Appears conditionally after one wrong login entry

**User Flow:**
1. User enters incorrect credentials
2. Login attempt fails
3. "Forgot Password?" link appears next to "Remember me" checkbox
4. User clicks link to navigate to password reset screen
5. User enters email address
6. System validates email and sends reset link
7. Success message displayed
8. Auto-navigates back to welcome screen

**Forgot Password Screen Features:**
- Back button to return to welcome screen
- Email input field with validation
- "Send Reset Link" button
- Success/error feedback via SnackBar
- Form validation (email format check)

**Technical Details:**
- Route: `/forgot-password`
- Screen: `ForgotPasswordScreen`
- Located in: `lib/screens/forgot_password_screen.dart`
- Login failure tracking: `_loginAttempts` counter in welcome screen
- Conditional rendering: Link only shows when `_showForgotPassword` is true

**Backend Integration (TODO):**
- Currently simulates API call with 2-second delay
- Needs integration with password reset service
- Email sending service required for production

---

#### Files Modified

**Created:**
- `lib/screens/forgot_password_screen.dart` - New password reset screen

**Modified:**
- `lib/screens/welcome_screen.dart` - Added Remember Me checkbox, Forgot Password link, email pre-population
- `lib/providers/user_provider.dart` - Added Remember Me parameter, email storage functionality
- `lib/config/router.dart` - Added `/forgot-password` route
- `router.json` - Documented forgot-password route

**Routes Updated:**
```json
{
  "path": "/forgot-password",
  "name": "forgot-password",
  "screen": "ForgotPasswordScreen",
  "description": "Password reset screen where users can request a password reset link"
}
```

---

#### SharedPreferences Keys

- `rememberMe` (bool) - Remember Me checkbox state
- `savedEmail` (String) - Saved email address for pre-population

---

#### Design Specifications

**Remember Me Checkbox:**
- Size: 20x20px
- Font: 14px, normal weight
- Color: `AppColors.textSecondary` (gray)
- Active color: `AppColors.primary`
- Border radius: 4px

**Forgot Password Link:**
- Font: 14px, medium weight (w500)
- Color: `AppColors.primary` (blue)
- Placement: Right-aligned in row with Remember Me
- Spacing: 16px after password field, 24px before Sign In button

---

## Project Structure

```
lib/
├── screens/
│   ├── welcome_screen.dart          # Login/signup with Remember Me and Forgot Password
│   ├── forgot_password_screen.dart  # Password reset screen
│   └── ...
├── providers/
│   └── user_provider.dart           # User state management with Remember Me support
├── config/
│   └── router.dart                  # App routing configuration
└── ...
```

---

## Future Enhancements

### Authentication
- [ ] Integrate Firebase Authentication backend
- [ ] Implement actual password reset email service
- [ ] Add rate limiting for login attempts
- [ ] Add biometric authentication support
- [ ] Add "Sign out from all devices" option

---

## Testing Checklist

### Profile Completion Flow
- [ ] Sign-in bypasses profile completion screen
- [ ] Sign-in redirects to `/translation` screen
- [ ] Sign-up shows profile completion screen
- [ ] Sign-up collects appropriate information (Patient vs Doctor)
- [ ] Profile completion redirects to `/translation` after saving
- [ ] Guest mode bypasses profile completion screen
- [ ] Guest mode redirects to `/translation` screen
- [ ] Patient profile collects: first name, last name, insurance number, insurance provider
- [ ] Doctor profile collects: name, specialty, qualification, experience, clinic address, etc.

### Remember Me Feature
- [ ] Checkbox can be toggled on/off
- [ ] Email saves when checked and login succeeds
- [ ] Email does not save when unchecked
- [ ] Saved email persists across app restarts
- [ ] Email auto-populates on next launch
- [ ] Password is never saved
- [ ] Logout respects Remember Me preference

### Forgot Password Feature
- [ ] Link hidden on initial page load
- [ ] Link appears after first failed login
- [ ] Navigation to forgot password screen works
- [ ] Email validation works correctly
- [ ] Success message displays
- [ ] Auto-navigation back to welcome works
- [ ] Back button works correctly

---

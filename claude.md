# Medicus - Medical Translation App

## Project Overview

Medicus is a medical translation application designed to facilitate communication in healthcare settings across language barriers. The app provides features for medical professionals and patients to communicate effectively.

---

## Recent Updates

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

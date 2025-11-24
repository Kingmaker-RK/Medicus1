import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/user_provider.dart';
import '../widgets/ai_gris_logo.dart';
import '../widgets/hospital_background.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_routes.dart';
import 'package:ai_gris/screens/language_selection_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String _selectedRole = AppConstants.rolePatient;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignIn = true;
  bool _rememberMe = false;
  int _loginAttempts = 0;
  bool _showForgotPassword = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail();
  }

  Future<void> _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      final savedEmail = prefs.getString('savedEmail');
      if (savedEmail != null && mounted) {
        setState(() {
          _emailController.text = savedEmail;
          _rememberMe = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: HospitalBackground(
        opacity: 0.15,
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Space for the language selector
                      const SizedBox(height: 48),

                      // Logo - Reduced size and moved up
                      const Center(child: AiGrisLogo(size: 70, showText: true)),
                  const SizedBox(height: 12),

                  // Welcome text
                  Text(
                    l10n.welcomeTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.welcomeSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Role selection
                  _buildRoleSelector(l10n),
                  const SizedBox(height: 16),

                  // Sign in / Sign up toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignIn = true;
                          });
                        },
                        child: Text(
                          l10n.signIn,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: _isSignIn
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _isSignIn
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '|',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isSignIn = false;
                          });
                        },
                        child: Text(
                          l10n.signUp,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: !_isSignIn
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: !_isSignIn
                                ? AppColors.primary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                                    const SizedBox(height: 16),
                  
                                    if (_isSignIn) ...[
                                      // Email field
                                      TextField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: InputDecoration(
                                          labelText: l10n.emailLabel,
                                          prefixIcon: const Icon(Icons.email),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                  
                                      // Password field
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: l10n.passwordLabel,
                                          prefixIcon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off
                                                  : Icons.visibility,
                                              color: AppColors.textSecondary,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
                                              });
                                            },
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                  
                                      // Remember Me + Forgot Password Row
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Remember Me Checkbox
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: Checkbox(
                                                    value: _rememberMe,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _rememberMe = value ?? false;
                                                      });
                                                    },
                                                    activeColor: AppColors.primary,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  l10n.rememberMe,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                    fontWeight: FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                  
                                            // Forgot Password Link (conditionally shown)
                                            if (_showForgotPassword)
                                              TextButton(
                                                onPressed: () {
                                                  context.go('/forgot-password');
                                                },
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  minimumSize: const Size(0, 0),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                ),
                                                child: Text(
                                                  l10n.forgotPassword,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                  
                                      const SizedBox(height: 16),
                  
                                      // Terms and Conditions Checkbox (Required for Login)
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 16.0),
                                        child: Row(
                                          children: [
                                            Checkbox(
                                              value: _agreedToTerms,
                                              onChanged: (value) {
                                                setState(() {
                                                  _agreedToTerms = value ?? false;
                                                });
                                              },
                                              activeColor: AppColors.primary,
                                            ),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  context.push('/${AppRoutes.privacyPolicy}');
                                                },
                                                child: Text(
                                                  l10n.agreeToTerms,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: AppColors.primary,
                                                    decoration: TextDecoration.underline,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ] else ...[
                                      // Register Mode - Call to Action
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(Icons.person_add, size: 48, color: AppColors.primary),
                                            const SizedBox(height: 16),
                                            Text(
                                              "Create your account",
                                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.textPrimary,
                                                  ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              "Join us to access personalized healthcare services.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(color: AppColors.textSecondary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                    ],
                  
                                    // Sign in / Sign up button
                                    ElevatedButton(
                                      onPressed: userProvider.isLoading
                                          ? null
                                          : () async {
                                              if (_isSignIn) {
                                                // SIGN IN FLOW
                                                if (!_agreedToTerms) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        l10n.pleaseAgreeToTerms,
                                                      ),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }
                                                try {
                                                  // Existing user - Sign In
                                                  await userProvider.login(
                                                    email: _emailController.text,
                                                    password: _passwordController.text,
                                                    role: _selectedRole,
                                                    rememberMe: _rememberMe,
                                                  );
                                                  if (!mounted) return;
                                                  if (userProvider.isLoggedIn) {
                                                    // Sign In: Skip profile completion, go directly to app
                                                    if (userProvider.currentUser?.role ==
                                                        AppConstants.roleDoctor) {
                                                      context.go('/doctor-home');
                                                    } else {
                                                      context.go('/translation');
                                                    }
                                                  }
                                                } catch (e) {
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _loginAttempts++;
                                                    if (_loginAttempts >= 1) {
                                                      _showForgotPassword = true;
                                                    }
                                                  });
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text(l10n.loginFailed),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              } else {
                                                // SIGN UP FLOW - Navigate to new registration screens
                                                context.pushNamed(
                                                  AppRoutes.registerPersonal,
                                                  extra: {'role': _selectedRole},
                                                );
                                              }
                                            },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: userProvider.isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _isSignIn ? l10n.signIn : l10n.signUp,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                    const SizedBox(height: 12),
                  // Continue as guest button
                  OutlinedButton(
                    onPressed: () async {
                      final agreed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(l10n.termsAndConditions),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.guestTermsMessage),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  context.push('/${AppRoutes.privacyPolicy}');
                                },
                                child: Text(l10n.viewPolicy),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(l10n.iAgree),
                            ),
                          ],
                        ),
                      );

                      if (agreed == true) {
                        await userProvider.continueAsGuest(_selectedRole);
                        if (!mounted) return;
                        if (userProvider.currentUser?.role ==
                            AppConstants.roleDoctor) {
                          context.go('/doctor-home');
                        } else {
                          context.go('/translation');
                        }
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: Text(
                      l10n.continueAsGuest,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          _buildLanguageSelector(userProvider),
        ],
      ),
    ),
  );
}

  Widget _buildLanguageSelector(UserProvider userProvider) {
    return Positioned(
      top: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LanguageSelectionScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language, color: AppColors.primary, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    userProvider.selectedLanguage.toUpperCase(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildRoleOption(
              role: AppConstants.rolePatient,
              label: l10n.rolePatient,
              icon: Icons.person,
              color: AppColors.patientColor,
            ),
          ),
          Expanded(
            child: _buildRoleOption(
              role: AppConstants.roleDoctor,
              label: l10n.roleDoctor,
              icon: Icons.local_hospital,
              color: AppColors.doctorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required String role,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == role;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../widgets/ai_gris_logo.dart';
import '../widgets/hospital_background.dart';
import '../widgets/translated_widget.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';
import 'package:ai_gris/screens/language_selection_screen.dart';
import '../services/localization_service.dart';

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

    return Scaffold(
      body: HospitalBackground(
        opacity: 0.15,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language selector at top left
                  Row(
                    children: [
                      _buildLanguageSelector(userProvider),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Logo - Reduced size and moved up
                  const Center(child: AiGrisLogo(size: 70, showText: true)),
                  const SizedBox(height: 12),

                  // Welcome text - More compact with instant translation
                  AutoTranslateText(
                    'Welcome to AI-Gris',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  AutoTranslateText(
                    'Breaking language barriers in healthcare',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Role selection
                  _buildRoleSelector(),
                  const SizedBox(height: 16),

                  // Sign in / Sign up toggle with translation
                  LanguageBuilder(
                    builder: (context, _) => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignIn = true;
                            });
                          },
                          child: AutoTranslateText(
                            'Sign In',
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
                          child: AutoTranslateText(
                            'Sign Up',
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
                  ),
                  const SizedBox(height: 16),

                  // Email field with translation
                  TranslatedInputDecoration(
                  labelText: 'Email',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                  const SizedBox(height: 12),

                  // Password field with translation
                  TranslatedInputDecoration(
                  labelText: 'Password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
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
                ),
                  const SizedBox(height: 12),

                  // Remember Me + Forgot Password Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Remember Me Checkbox with translation
                        LanguageBuilder(
                          builder: (context, _) => Row(
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
                              AutoTranslateText(
                                'Remember me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Forgot Password Link (conditionally shown) with translation
                        if (_showForgotPassword)
                          LanguageBuilder(
                            builder: (context, _) => TextButton(
                              onPressed: () {
                                context.go('/forgot-password');
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: AutoTranslateText(
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign in / Sign up button
                  ElevatedButton(
                    onPressed: userProvider.isLoading
                        ? null
                        : () async {
                            try {
                              if (_isSignIn) {
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
                                  context.go('/translation');
                                }
                              } else {
                                // New user - Sign Up
                                await userProvider.signUp(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                  role: _selectedRole,
                                  rememberMe: _rememberMe,
                                );
                                if (!mounted) return;
                                if (userProvider.isLoggedIn) {
                                  // Sign Up: Navigate to email verification
                                  context.go(
                                    '/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}',
                                  );
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
                                  content: AutoTranslateText(
                                    _isSignIn
                                        ? 'Login failed. Please check your credentials.'
                                        : 'Sign up failed. Please try again.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
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
                        : AutoTranslateText(
                            _isSignIn ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 12),

                  // Continue as guest button with translation
                  OutlinedButton(
                    onPressed: () async {
                      await userProvider.continueAsGuest(_selectedRole);
                      if (!mounted) return;
                      context.go('/translation');
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    child: const AutoTranslateText(
                      'Continue as Guest',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildLanguageSelector(UserProvider userProvider) {
    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            userProvider.selectedLanguage.toUpperCase(),
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
        );
      },
    );
  }

  Widget _buildRoleSelector() {
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
              label: 'Patient',
              icon: Icons.person,
              color: AppColors.patientColor,
            ),
          ),
          Expanded(
            child: _buildRoleOption(
              role: AppConstants.roleDoctor,
              label: 'Doctor',
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
            AutoTranslateText(
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

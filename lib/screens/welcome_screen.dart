import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/user_provider.dart';
import '../widgets/medicus_logo.dart';
import '../constants/colors.dart';
import '../constants/app_constants.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/hospital_background.jpg'),
            fit: BoxFit.cover,
            // If image doesn't load, will show background color
            onError: null,
          ),
        ),
        child: Container(
          // Semi-transparent overlay for better readability
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85)),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo at top with 200 units spacing
                    const SizedBox(height: 200),
                    const Center(child: MedicusLogo(size: 90, showText: true)),
                    const SizedBox(height: 30),

                    // Language selector moved below logo
                    Row(
                      children: [
                        _buildLanguageSelector(userProvider),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Welcome text
                    Text(
                      'Welcome to Medicus',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Breaking language barriers in healthcare',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),

                    // Role selection
                    _buildRoleSelector(),
                    const SizedBox(height: 24),

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
                            'Sign In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: _isSignIn
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _isSignIn
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '|',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(width: 20),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignIn = false;
                            });
                          },
                          child: Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
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
                    const SizedBox(height: 24),

                    // Email field
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                    const SizedBox(height: 16),

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
                                'Remember me',
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
                                'Forgot Password?',
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

                    const SizedBox(height: 24),

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
                                  if (mounted && userProvider.isLoggedIn) {
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
                                  if (mounted && userProvider.isLoggedIn) {
                                    // Sign Up: Navigate to email verification
                                    context.go(
                                      '/verify-email?email=${Uri.encodeComponent(_emailController.text.trim())}',
                                    );
                                  }
                                }
                              } catch (e) {
                                setState(() {
                                  _loginAttempts++;
                                  if (_loginAttempts >= 1) {
                                    _showForgotPassword = true;
                                  }
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        _isSignIn
                                            ? 'Login failed. Please check your credentials.'
                                            : 'Sign up failed. Please try again.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: userProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _isSignIn ? 'Sign In' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),

                    // Continue as guest button
                    OutlinedButton(
                      onPressed: () async {
                        await userProvider.continueAsGuest(_selectedRole);
                        if (mounted) {
                          // Guest: Skip profile completion, go directly to app
                          context.go('/translation');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: AppColors.primary),
                      ),
                      child: const Text(
                        'Continue as Guest',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(UserProvider userProvider) {
    return PopupMenuButton<String>(
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
      onSelected: (String languageCode) {
        userProvider.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) {
        return AppConstants.supportedLanguages.map((lang) {
          return PopupMenuItem<String>(
            value: lang['code'],
            child: Text('${lang['nativeName']} (${lang['name']})'),
          );
        }).toList();
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
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
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
              size: 40,
              color: isSelected ? color : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
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

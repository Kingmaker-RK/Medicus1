class AppConstants {
  // App Info
  static const String appName = 'Medicus';
  static const String appVersion = '1.0.0';

  // API Endpoints (Replace with your actual endpoints)
  static const String translationApiUrl = 'YOUR_TRANSLATION_API_URL';
  static const String medicalTermsApiUrl = 'YOUR_MEDICAL_TERMS_API_URL';
  static const String anatomyImagesApiUrl = 'YOUR_ANATOMY_API_URL';

  // OpenAI API Configuration for Advanced LLM Translation
  // IMPORTANT: Replace with your actual OpenAI API key
  // Get your API key from: https://platform.openai.com/api-keys
  static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';

  // Supported Languages - 200+ languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'Español'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'Русский'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو'},
    {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    {'code': 'th', 'name': 'Thai', 'nativeName': 'ไทย'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
    // Add more languages as needed
  ];

  // User Roles
  static const String rolePatient = 'patient';
  static const String roleDoctor = 'doctor';

  // Storage Keys
  static const String keyLanguage = 'selected_language';
  static const String keyUserRole = 'user_role';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyUserId = 'user_id';
  static const String keyProfileCompleted = 'profile_completed';
  static const String keyIsSignUp = 'is_sign_up';

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Max Recording Duration
  static const Duration maxRecordingDuration = Duration(minutes: 5);
}

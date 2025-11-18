# Medicus - Integration Guide

This guide will help you integrate real translation APIs and 3D anatomy visualization into the Medicus app.

## Table of Contents
1. [LLM Translation Integration](#llm-translation-integration)
2. [3D Anatomy Visualization](#3d-anatomy-visualization)
3. [Firebase Authentication](#firebase-authentication)
4. [Medical Terms Database](#medical-terms-database)

---

## LLM Translation Integration

### Option 1: OpenAI GPT-4 (Recommended)

**Step 1: Get API Key**
- Sign up at https://platform.openai.com
- Generate API key from API settings

**Step 2: Update Constants**
```dart
// lib/constants/app_constants.dart
static const String translationApiUrl = 'https://api.openai.com/v1/chat/completions';
```

**Step 3: Implement Translation Service**
```dart
// lib/services/translation_service.dart

Future<TranslationResult> translateText({
  required String text,
  required String sourceLanguage,
  required String targetLanguage,
  bool isMedicalContext = true,
}) async {
  try {
    final response = await _dio.post(
      'https://api.openai.com/v1/chat/completions',
      data: {
        'model': 'gpt-4',
        'messages': [
          {
            'role': 'system',
            'content': '''You are a medical translator specializing in patient-doctor communication.
            Translate accurately while preserving medical terminology.
            Extract medical terms and suggest relevant anatomy references.'''
          },
          {
            'role': 'user',
            'content': '''Translate this medical text:
            From: $sourceLanguage
            To: $targetLanguage
            Text: $text

            Respond in JSON format:
            {
              "translation": "translated text",
              "medicalTerms": ["term1", "term2"],
              "anatomyReferences": ["organ1", "organ2"]
            }'''
          }
        ],
        'temperature': 0.3,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer YOUR_OPENAI_API_KEY',
          'Content-Type': 'application/json',
        },
      ),
    );

    final content = response.data['choices'][0]['message']['content'];
    final parsed = json.decode(content);

    return TranslationResult(
      originalText: text,
      translatedText: parsed['translation'],
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      medicalTerms: List<String>.from(parsed['medicalTerms'] ?? []),
      anatomyImages: _getAnatomyUrls(parsed['anatomyReferences'] ?? []),
    );
  } catch (e) {
    print('Translation error: $e');
    rethrow;
  }
}
```

### Option 2: Google Cloud Translation API

**Step 1: Setup**
```bash
# Enable Cloud Translation API
gcloud services enable translate.googleapis.com

# Create service account and download JSON key
```

**Step 2: Add Package**
```yaml
# pubspec.yaml
dependencies:
  google_mlkit_translation: ^0.12.0
```

**Step 3: Implement**
```dart
Future<TranslationResult> translateText({
  required String text,
  required String sourceLanguage,
  required String targetLanguage,
}) async {
  final response = await _dio.post(
    'https://translation.googleapis.com/language/translate/v2',
    queryParameters: {
      'key': 'YOUR_GOOGLE_API_KEY',
    },
    data: {
      'q': text,
      'source': sourceLanguage,
      'target': targetLanguage,
      'format': 'text',
    },
  );

  final translatedText = response.data['data']['translations'][0]['translatedText'];

  return TranslationResult(
    originalText: text,
    translatedText: translatedText,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );
}
```

### Option 3: Azure Translator

**Step 1: Create Resource**
- Create Translator resource in Azure Portal
- Copy key and endpoint

**Step 2: Implement**
```dart
Future<TranslationResult> translateText({
  required String text,
  required String sourceLanguage,
  required String targetLanguage,
}) async {
  final response = await _dio.post(
    'https://api.cognitive.microsofttranslator.com/translate',
    queryParameters: {
      'api-version': '3.0',
      'from': sourceLanguage,
      'to': targetLanguage,
    },
    data: [
      {'text': text}
    ],
    options: Options(
      headers: {
        'Ocp-Apim-Subscription-Key': 'YOUR_AZURE_KEY',
        'Ocp-Apim-Subscription-Region': 'YOUR_REGION',
        'Content-Type': 'application/json',
      },
    ),
  );

  final translatedText = response.data[0]['translations'][0]['text'];

  return TranslationResult(
    originalText: text,
    translatedText: translatedText,
    sourceLanguage: sourceLanguage,
    targetLanguage: targetLanguage,
  );
}
```

---

## 3D Anatomy Visualization

### Option 1: Using Model Viewer Plus

**Step 1: Prepare 3D Models**
- Use GLB or GLTF format
- Host models on a server or use URLs
- Recommended sources:
  - https://sketchfab.com (search for medical/anatomy models)
  - https://www.cgtrader.com
  - BioDigital Human API

**Step 2: Update Anatomy Viewer**
```dart
// lib/widgets/anatomy_viewer.dart

import 'package:model_viewer_plus/model_viewer_plus.dart';

Widget _build3DView(String modelUrl) {
  return ModelViewer(
    src: modelUrl, // GLB/GLTF URL
    alt: "3D Anatomy Model",
    autoRotate: true,
    cameraControls: true,
    backgroundColor: Color(0xFFEEEEEE),
    loading: Loading.eager,
    ar: true, // Enable AR mode
    arModes: ['scene-viewer', 'webxr', 'quick-look'],
    cameraOrbit: '0deg 75deg 105%',
    minCameraOrbit: 'auto auto 5%',
  );
}
```

**Step 3: Create Model URL Mapping**
```dart
// lib/services/anatomy_service.dart

class AnatomyService {
  static const Map<String, String> anatomyModels = {
    'heart': 'https://your-cdn.com/models/heart.glb',
    'lung': 'https://your-cdn.com/models/lung.glb',
    'brain': 'https://your-cdn.com/models/brain.glb',
    'liver': 'https://your-cdn.com/models/liver.glb',
    'kidney': 'https://your-cdn.com/models/kidney.glb',
    // Add more organs
  };

  static List<String> getModelUrls(List<String> terms) {
    return terms
        .map((term) => anatomyModels[term.toLowerCase()])
        .where((url) => url != null)
        .cast<String>()
        .toList();
  }
}
```

### Option 2: BioDigital Human API

**Step 1: Sign Up**
- Register at https://www.biodigital.com/

**Step 2: Integrate**
```dart
Future<List<String>> getAnatomyVisualization(String bodyPart) async {
  final response = await _dio.get(
    'https://apis.biodigital.com/services/v2/search',
    queryParameters: {
      'query': bodyPart,
    },
    options: Options(
      headers: {
        'Authorization': 'Bearer YOUR_BIODIGITAL_API_KEY',
      },
    ),
  );

  return response.data['results']
      .map((result) => result['embedUrl'])
      .toList();
}
```

---

## Firebase Authentication

**Step 1: Create Firebase Project**
1. Go to https://console.firebase.google.com
2. Create new project
3. Add Android/iOS apps

**Step 2: Download Config Files**
- Android: `google-services.json` → `android/app/`
- iOS: `GoogleService-Info.plist` → `ios/Runner/`

**Step 3: Update main.dart**
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MedicusApp());
}
```

**Step 4: Implement Auth Service**
```dart
// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

## Medical Terms Database

### Option 1: Local Database with UMLS

**Step 1: Download UMLS**
- Register at https://www.nlm.nih.gov/research/umls/
- Download medical terminology database

**Step 2: Add to Assets**
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/medical_terms.db
```

**Step 3: Use SQLite**
```dart
import 'package:sqflite/sqflite.dart';

class MedicalTermsService {
  Database? _database;

  Future<List<String>> extractMedicalTerms(String text) async {
    final db = await _getDatabase();
    final words = text.toLowerCase().split(' ');

    final terms = <String>[];
    for (final word in words) {
      final result = await db.query(
        'medical_terms',
        where: 'term LIKE ?',
        whereArgs: ['%$word%'],
      );

      if (result.isNotEmpty) {
        terms.add(word);
      }
    }

    return terms;
  }
}
```

### Option 2: Medical NLP API

Use services like:
- **MetaMap**: https://metamap.nlm.nih.gov/
- **cTAKES**: https://ctakes.apache.org/
- **MedSpaCy**: https://github.com/medspacy/medspacy

---

## Testing Your Integration

### Test Translation
```dart
void testTranslation() async {
  final service = TranslationService();

  final result = await service.translateText(
    text: 'I have a severe headache and fever',
    sourceLanguage: 'en',
    targetLanguage: 'es',
  );

  print('Original: ${result.originalText}');
  print('Translated: ${result.translatedText}');
  print('Medical Terms: ${result.medicalTerms}');
}
```

### Test Speech Recognition
```dart
void testSpeech() async {
  final service = SpeechService();
  await service.initialize();

  await service.startListening(
    languageCode: 'en-US',
    onResult: (text) {
      print('Recognized: $text');
    },
  );
}
```

---

## Production Checklist

- [ ] Add real translation API integration
- [ ] Configure 3D anatomy models
- [ ] Set up Firebase authentication
- [ ] Add medical terms database
- [ ] Configure API keys securely (use environment variables)
- [ ] Test all permissions on real devices
- [ ] Test speech recognition in noisy environments
- [ ] Validate medical terminology accuracy
- [ ] Set up error tracking (Sentry, Firebase Crashlytics)
- [ ] Add analytics (Firebase Analytics, Mixpanel)
- [ ] Implement rate limiting for API calls
- [ ] Add offline mode support
- [ ] Test on multiple devices and OS versions
- [ ] Review and comply with HIPAA/medical data regulations

---

## Cost Estimates (Monthly)

### For 10,000 Translations/Month

**OpenAI GPT-4**
- ~$30-50 (depending on token usage)

**Google Cloud Translation**
- ~$200 ($20 per million characters)

**Azure Translator**
- ~$100 (first 2M characters free, then $10 per million)

**BioDigital Human**
- Contact for enterprise pricing

---

## Support

For integration help:
- Email: dev@medicus.app
- Discord: https://discord.gg/medicus
- Documentation: https://docs.medicus.app

---

**Happy Integrating!** 🚀

import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ai_gris/providers/user_provider.dart';
import 'package:ai_gris/services/llm_translation_service.dart';
import 'package:ai_gris/constants/app_constants.dart';
import 'test_helpers.dart';
import 'registration_email_integration_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late UserProvider userProvider;
  late MockClient mockClient;

  setUpAll(() {
    setupFirebaseMocks();
  });

  setUp(() {
    mockClient = MockClient();
    LLMTranslationService().setHttpClient(mockClient);
    
    // Setup a mock user provider (which uses a real AuthService wrapping a MockFirebaseAuth)
    userProvider = createMockUserProvider();
    
    // Force Llama configuration for testing
    LLMTranslationService().setLlamaConfigured(true);
  });

  test('signUp triggers LLM email generation', () async {
    // 1. Mock the LLM response for email generation
    final mockEmailResponse = {
      'choices': [
        {
          'message': {
            'content': jsonEncode({
              'subject': 'Test Subject',
              'body': 'Test Body with Code'
            })
          }
        }
      ]
    };

    when(mockClient.post(
      any,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(jsonEncode(mockEmailResponse), 200));

    // 2. Call signUp
    await userProvider.signUp(
      email: 'test_new@example.com',
      password: 'password123',
      role: 'patient',
      firstName: 'John',
      lastName: 'Doe',
      dateOfBirth: DateTime(1990, 1, 1),
      gender: 'Male',
    );

    // 3. Verify that LLM service was called (which implies emailGenerator was executed)
    verify(mockClient.post(
      Uri.parse(AppConstants.llamaApiUrl),
      headers: anyNamed('headers'),
      body: argThat(contains('Write a professional and welcoming email'), named: 'body'),
    )).called(1);

    // 4. Verify user was created
    expect(userProvider.currentUser, isNotNull);
    expect(userProvider.currentUser!.email, 'test_new@example.com');
  });
}

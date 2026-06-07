# AI-Gris - Medical Translation App

AI-Gris is a comprehensive medical translation application designed to break language barriers in healthcare communication between patients and doctors who speak different languages.

## Features

### Core Features
- **Multi-lingual Translation**: Supports 200+ languages with medical context awareness
- **Voice Translation**: Real-time speech-to-text and text-to-speech capabilities
- **Medical Terminology**: Automatic extraction and highlighting of medical terms
- **Anatomy Visualization**: 2D/3D anatomy images to enhance understanding
- **Role-Based Interface**: Separate views for patients and doctors
- **Guest Mode**: Use the app without creating an account

### Pages
1. **Welcome Page**: Sign up, sign in, or continue as guest with language selection
2. **Translation Page**: Main interface for real-time translation with anatomy visualization
3. **Settings Page**: Manage permissions (microphone, camera, location, notifications)
4. **Services Hub**: Access a variety of medical services. This screen was recently refactored to use a data-driven architecture, making it more scalable and maintainable.

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Configuration

### API Integration Required

To make the translation functional, you need to integrate with an LLM service:

1. Edit `lib/constants/app_constants.dart` - Add your API endpoints
2. Edit `lib/services/translation_service.dart` - Implement your LLM integration

Supported services: OpenAI GPT-4, Google Cloud Translation, Azure Translator, or custom medical LLM.

See full documentation in the README for detailed integration steps.

## Project Structure

```
lib/
├── config/          # App configuration
├── constants/       # Constants and colors
├── data/            # Decoupled data sources
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # Business logic
└── widgets/         # Reusable components
```

## License

MIT License - Built with ❤️ for better healthcare communication worldwide
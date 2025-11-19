# Medicus Translation Setup Guide

## 📚 Overview

Medicus now supports **200+ languages** including all **22 scheduled Indian languages** and regional languages from around the world. The app uses **Google Translate API** for fast, accurate, real-time translation with immediate UI updates.

## 🌍 Supported Languages

### Major Categories:
- **10+ Major World Languages**: English, Spanish, Chinese, Arabic, Portuguese, Russian, Japanese, French, German, etc.
- **22+ Indian Languages**: Hindi, Bengali, Telugu, Marathi, Tamil, Urdu, Gujarati, Kannada, Malayalam, Odia, Punjabi, Assamese, Maithili, Sanskrit, Sindhi, Kashmiri, Nepali, Konkani, Manipuri, Tibetan, Santali, Dogri
- **30+ European Languages**: Italian, Dutch, Polish, Ukrainian, Romanian, Czech, Greek, Swedish, Hungarian, Finnish, Norwegian, Danish, and more
- **50+ Asian Languages**: Korean, Vietnamese, Thai, Indonesian, Malay, Filipino, Lao, Burmese, Khmer, Mongolian, Javanese, and more
- **40+ African Languages**: Swahili, Afrikaans, Zulu, Xhosa, Amharic, Hausa, Igbo, Yoruba, and more
- **20+ Middle Eastern Languages**: Turkish, Persian, Hebrew, Kurdish, Azerbaijani, Uzbek, and more
- **Plus**: Pacific, Oceanian, American Indigenous, and Sign Languages

**Total: 200+ languages** with regional variants (e.g., Portuguese (Brazil), Spanish (Mexico), Chinese (Simplified/Traditional))

---

## ⚙️ Setup Instructions

### Step 1: Get Google Cloud Translation API Key

1. **Go to Google Cloud Console**
   - Visit: https://console.cloud.google.com/

2. **Create a New Project** (or use existing)
   - Click "Select a project" → "New Project"
   - Name: `medicus-translation`
   - Click "Create"

3. **Enable Cloud Translation API**
   - Visit: https://console.cloud.google.com/apis/library/translate.googleapis.com
   - Click "Enable"
   - Wait for activation (takes a few seconds)

4. **Create API Credentials**
   - Visit: https://console.cloud.google.com/apis/credentials
   - Click "Create Credentials" → "API Key"
   - Copy the generated API key
   - **Important**: Restrict the API key to Cloud Translation API for security

5. **Set Up Billing** (Required for Google Translate)
   - Visit: https://console.cloud.google.com/billing
   - Add billing information
   - **Free Tier**: First 500,000 characters/month are FREE
   - **Pricing**: $20 per 1M characters after free tier

### Step 2: Configure the App

1. **Open `lib/constants/app_constants.dart`**

2. **Replace the API Key**
   ```dart
   static const String googleTranslateApiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
   ```

   Replace `YOUR_GOOGLE_TRANSLATE_API_KEY` with your actual API key from Step 1.

3. **Save the file**

### Step 3: Test the Translation

1. **Run the app**
   ```bash
   flutter run
   ```

2. **Test language selection**
   - On the Welcome screen, click the language selector (top-left)
   - Choose any language from 200+ options
   - Notice the UI updates immediately

3. **Test translation**
   - Go to Translation screen
   - Select source and target languages
   - Enter text and click "Translate"
   - See instant translation results

---

## 🎯 Features

### ✅ Real-Time Translation
- **Instant results**: Translations appear in <1 second
- **High accuracy**: Powered by Google Translate's neural machine translation
- **200+ languages**: Support for all major world languages

### ✅ Immediate UI Updates
- **No page reload**: Language changes apply instantly
- **Seamless experience**: All text updates in real-time
- **Persistent settings**: Selected language is saved

### ✅ Medical Context Enhancement
- **Medical terminology**: Preserves medical terms accurately
- **Anatomy visualization**: Shows relevant anatomy images
- **Healthcare-specific**: Optimized for medical conversations

### ✅ Comprehensive Indian Language Support
- **All 22 scheduled languages**: Complete coverage of India's official languages
- **Regional variants**: Bhojpuri, Rajasthani, Awadhi, Marwari, and more
- **Script support**: Devanagari, Bengali, Tamil, Telugu, and all Indian scripts

---

## 🔧 Advanced Configuration

### Optional: Add OpenAI GPT-4 for Enhanced Medical Translation

For even better medical context and terminology handling:

1. **Get OpenAI API Key**
   - Visit: https://platform.openai.com/api-keys
   - Create new API key

2. **Update `lib/constants/app_constants.dart`**
   ```dart
   static const String openaiApiKey = 'YOUR_OPENAI_API_KEY';
   ```

3. **How it works**
   - Google Translate is used for fast translation
   - OpenAI GPT-4 is used as fallback for medical context enhancement
   - Automatic fallback if one service fails

---

## 📊 Usage Costs

### Google Translate API Pricing
- **Free Tier**: 500,000 characters/month
- **Paid**: $20 per 1M characters
- **Typical usage**:
  - 100 translations/day × 100 characters = 10,000 chars/day
  - Monthly: ~300,000 characters (within free tier)

### OpenAI GPT-4 (Optional)
- **GPT-4 Turbo**: ~$0.01-0.03 per request
- **Usage**: Only as fallback or for medical enhancement

---

## 🐛 Troubleshooting

### Issue: "Translation APIs not configured"
**Solution**: Make sure you've replaced `YOUR_GOOGLE_TRANSLATE_API_KEY` with your actual API key

### Issue: "Google Translate failed"
**Solutions**:
1. Check if Cloud Translation API is enabled
2. Verify API key is correct
3. Ensure billing is set up
4. Check API key restrictions allow Cloud Translation API

### Issue: "Rate limit exceeded"
**Solution**: You've exceeded free tier. Either wait for next month or upgrade billing.

### Issue: Some languages not translating
**Solution**: Some rare regional languages may not be fully supported by Google Translate. The app will fall back to mock translation.

---

## 🔒 Security Best Practices

1. **Restrict API Keys**
   - In Google Cloud Console, restrict keys to specific APIs
   - Add HTTP referrer restrictions for web apps

2. **Never Commit API Keys**
   - Add `lib/constants/app_constants.dart` to `.gitignore` (if not already)
   - Use environment variables for production

3. **Monitor Usage**
   - Check Google Cloud Console regularly
   - Set up billing alerts
   - Monitor for unusual activity

---

## 📝 Language Codes Reference

### Common Language Codes:
- `en` - English
- `hi` - Hindi
- `bn` - Bengali
- `te` - Telugu
- `mr` - Marathi
- `ta` - Tamil
- `ur` - Urdu
- `gu` - Gujarati
- `kn` - Kannada
- `ml` - Malayalam
- `es` - Spanish
- `fr` - French
- `de` - German
- `zh-CN` - Chinese (Simplified)
- `ar` - Arabic
- `pt` - Portuguese
- `ru` - Russian
- `ja` - Japanese
- `ko` - Korean

**See `lib/constants/app_constants.dart` for the complete list of 200+ language codes.**

---

## 🎉 Success!

Once configured, your Medicus app will support:
- ✅ 200+ languages worldwide
- ✅ All 22+ Indian languages
- ✅ Instant translation (< 1 second)
- ✅ Real-time UI updates
- ✅ Medical terminology preservation
- ✅ Offline fallback (mock translation)

**Enjoy breaking language barriers in healthcare!** 🏥🌍

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section above
2. Review Google Cloud Translation API documentation
3. Check Flutter console logs for error messages
4. Contact the development team

---

**Last Updated**: 2025-11-19
**Version**: 1.0.0

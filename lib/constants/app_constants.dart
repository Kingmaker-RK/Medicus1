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

  // Google Translate API Configuration
  // IMPORTANT: Replace with your actual Google Cloud API key
  // Get your API key from: https://console.cloud.google.com/apis/credentials
  // Enable Cloud Translation API: https://console.cloud.google.com/apis/library/translate.googleapis.com
  static const String googleTranslateApiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
  static const String googleTranslateApiUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // Google Gemini API Configuration for Advanced LLM Translation
  // IMPORTANT: Replace with your actual Google AI Studio API key
  // Get your API key from: https://aistudio.google.com/app/apikey
  // This provides state-of-the-art translation with cultural context and medical accuracy
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // DeepL API Configuration for Professional Translation
  // IMPORTANT: Replace with your actual DeepL API key
  // Get your API key from: https://www.deepl.com/pro-api
  // DeepL provides high-quality neural machine translation for 30+ languages
  static const String deeplApiKey = 'YOUR_DEEPL_API_KEY';

  // Supported Languages - 200+ languages including all Indian languages
  // Language codes follow ISO 639-1 standard
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'aa', 'name': 'Afar', 'nativeName': 'Afaraf'},
    {'code': 'ab', 'name': 'Abkhaz', 'nativeName': 'аҧсуа бызшәа'},
    {'code': 'ae', 'name': 'Avestan', 'nativeName': 'avesta'},
    {'code': 'af', 'name': 'Afrikaans', 'nativeName': 'Afrikaans'},
    {'code': 'ak', 'name': 'Akan', 'nativeName': 'Akan'},
    {'code': 'am', 'name': 'Amharic', 'nativeName': 'አማርኛ'},
    {'code': 'an', 'name': 'Aragonese', 'nativeName': 'aragonés'},
    {'code': 'ar', 'name': 'Arabic', 'nativeName': 'العربية'},
    {'code': 'as', 'name': 'Assamese', 'nativeName': 'অসমীয়া'},
    {'code': 'av', 'name': 'Avaric', 'nativeName': 'авар мацӀ'},
    {'code': 'ay', 'name': 'Aymara', 'nativeName': 'aymar aru'},
    {'code': 'az', 'name': 'Azerbaijani', 'nativeName': 'azərbaycan dili'},
    {'code': 'ba', 'name': 'Bashkir', 'nativeName': 'башҡорт теле'},
    {'code': 'be', 'name': 'Belarusian', 'nativeName': 'беларуская мова'},
    {'code': 'bg', 'name': 'Bulgarian', 'nativeName': 'български език'},
    {'code': 'bh', 'name': 'Bihari', 'nativeName': 'भोजपुरी'},
    {'code': 'bi', 'name': 'Bislama', 'nativeName': 'Bislama'},
    {'code': 'bm', 'name': 'Bambara', 'nativeName': 'bamanankan'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা'},
    {'code': 'bo', 'name': 'Tibetan', 'nativeName': 'བོད་ཡིག'},
    {'code': 'br', 'name': 'Breton', 'nativeName': 'brezhoneg'},
    {'code': 'bs', 'name': 'Bosnian', 'nativeName': 'bosanski jezik'},
    {'code': 'ca', 'name': 'Catalan', 'nativeName': 'Català'},
    {'code': 'ce', 'name': 'Chechen', 'nativeName': 'нохчийн мотт'},
    {'code': 'ch', 'name': 'Chamorro', 'nativeName': 'Chamoru'},
    {'code': 'co', 'name': 'Corsican', 'nativeName': 'corsu'},
    {'code': 'cr', 'name': 'Cree', 'nativeName': 'ᓀᐦᐃᔭᐍᐏᐣ'},
    {'code': 'cs', 'name': 'Czech', 'nativeName': 'čeština'},
    {'code': 'cu', 'name': 'Old Church Slavonic', 'nativeName': 'ѩзыкъ словѣньскъ'},
    {'code': 'cv', 'name': 'Chuvash', 'nativeName': 'чӑваш чӗлхи'},
    {'code': 'cy', 'name': 'Welsh', 'nativeName': 'Cymraeg'},
    {'code': 'da', 'name': 'Danish', 'nativeName': 'dansk'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
    {'code': 'dv', 'name': 'Divehi', 'nativeName': 'ދިވެހި'},
    {'code': 'dz', 'name': 'Dzongkha', 'nativeName': 'རྫོང་ཁ'},
    {'code': 'ee', 'name': 'Ewe', 'nativeName': 'Ɛʋɛgbɛ'},
    {'code': 'el', 'name': 'Greek', 'nativeName': 'Ελληνικά'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'eo', 'name': 'Esperanto', 'nativeName': 'Esperanto'},
    {'code': 'es', 'name': 'Spanish', 'nativeName': 'español'},
    {'code': 'et', 'name': 'Estonian', 'nativeName': 'Eesti keel'},
    {'code': 'eu', 'name': 'Basque', 'nativeName': 'euskara'},
    {'code': 'fa', 'name': 'Persian', 'nativeName': 'فارسی'},
    {'code': 'ff', 'name': 'Fulah', 'nativeName': 'Fulfulde'},
    {'code': 'fi', 'name': 'Finnish', 'nativeName': 'Suomen kieli'},
    {'code': 'fj', 'name': 'Fijian', 'nativeName': 'vosa Vakaviti'},
    {'code': 'fo', 'name': 'Faroese', 'nativeName': 'Føroyskt'},
    {'code': 'fr', 'name': 'French', 'nativeName': 'français'},
    {'code': 'fy', 'name': 'Western Frisian', 'nativeName': 'Frysk'},
    {'code': 'ga', 'name': 'Irish', 'nativeName': 'Gaeilge'},
    {'code': 'gd', 'name': 'Gaelic', 'nativeName': 'Gàidhlig'},
    {'code': 'gl', 'name': 'Galician', 'nativeName': 'Galego'},
    {'code': 'gn', 'name': 'Guaraní', 'nativeName': 'Avañe\'\\u1EBD'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી'},
    {'code': 'gv', 'name': 'Manx', 'nativeName': 'Ghaelg'},
    {'code': 'ha', 'name': 'Hausa', 'nativeName': 'هَوُسَ'},
    {'code': 'he', 'name': 'Hebrew', 'nativeName': 'עברית'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिन्दी'},
    {'code': 'ho', 'name': 'Hiri Motu', 'nativeName': 'Hiri Motu'},
    {'code': 'hr', 'name': 'Croatian', 'nativeName': 'Hrvatski'},
    {'code': 'ht', 'name': 'Haitian', 'nativeName': 'Kreyòl ayisyen'},
    {'code': 'hu', 'name': 'Hungarian', 'nativeName': 'Magyar'},
    {'code': 'hy', 'name': 'Armenian', 'nativeName': 'Հայերեն'},
    {'code': 'ia', 'name': 'Interlingua', 'nativeName': 'Interlingua'},
    {'code': 'id', 'name': 'Indonesian', 'nativeName': 'Bahasa Indonesia'},
    {'code': 'ie', 'name': 'Interlingue', 'nativeName': 'Interlingue'},
    {'code': 'ig', 'name': 'Igbo', 'nativeName': 'Igbo'},
    {'code': 'ii', 'name': 'Sichuan Yi', 'nativeName': 'ꆇꉙ'},
    {'code': 'ik', 'name': 'Inupiaq', 'nativeName': 'Iñupiaq'},
    {'code': 'io', 'name': 'Ido', 'nativeName': 'Ido'},
    {'code': 'is', 'name': 'Icelandic', 'nativeName': 'Íslenska'},
    {'code': 'it', 'name': 'Italian', 'nativeName': 'Italiano'},
    {'code': 'iu', 'name': 'Inuktitut', 'nativeName': 'ᐃᓄᒃᑎᑐᑦ'},
    {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
    {'code': 'jv', 'name': 'Javanese', 'nativeName': 'Basa Jawa'},
    {'code': 'ka', 'name': 'Georgian', 'nativeName': 'ქართული'},
    {'code': 'kg', 'name': 'Kongo', 'nativeName': 'Kikongo'},
    {'code': 'ki', 'name': 'Kikuyu', 'nativeName': 'Gikuyu'},
    {'code': 'kj', 'name': 'Kuanyama', 'nativeName': 'Kuanyama'},
    {'code': 'kk', 'name': 'Kazakh', 'nativeName': 'қазақ тілі'},
    {'code': 'kl', 'name': 'Kalaallisut', 'nativeName': 'Kalaallisut'},
    {'code': 'km', 'name': 'Khmer', 'nativeName': 'ភាសាខ្មែរ'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ'},
    {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
    {'code': 'kr', 'name': 'Kanuri', 'nativeName': 'Kanuri'},
    {'code': 'ks', 'name': 'Kashmiri', 'nativeName': 'कश्मीरी'},
    {'code': 'ku', 'name': 'Kurdish', 'nativeName': 'Kurdî'},
    {'code': 'kv', 'name': 'Komi', 'nativeName': 'Коми кыв'},
    {'code': 'kw', 'name': 'Cornish', 'nativeName': 'Kernewek'},
    {'code': 'ky', 'name': 'Kyrgyz', 'nativeName': 'Кыргызча'},
    {'code': 'la', 'name': 'Latin', 'nativeName': 'Latina'},
    {'code': 'lb', 'name': 'Luxembourgish', 'nativeName': 'Lëtzebuergesch'},
    {'code': 'lg', 'name': 'Ganda', 'nativeName': 'Luganda'},
    {'code': 'li', 'name': 'Limburgan', 'nativeName': 'Limburgs'},
    {'code': 'ln', 'name': 'Lingala', 'nativeName': 'Lingála'},
    {'code': 'lo', 'name': 'Lao', 'nativeName': 'ພາສາລາວ'},
    {'code': 'lt', 'name': 'Lithuanian', 'nativeName': 'Lietuvių'},
    {'code': 'lu', 'name': 'Luba-Katanga', 'nativeName': 'Tshiluba'},
    {'code': 'lv', 'name': 'Latvian', 'nativeName': 'Latviešu'},
    {'code': 'mg', 'name': 'Malagasy', 'nativeName': 'Malagasy'},
    {'code': 'mh', 'name': 'Marshallese', 'nativeName': 'Kajin M̧ajeļ'},
    {'code': 'mi', 'name': 'Māori', 'nativeName': 'Te Reo Māori'},
    {'code': 'mk', 'name': 'Macedonian', 'nativeName': 'македонски јазик'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം'},
    {'code': 'mn', 'name': 'Mongolian', 'nativeName': 'монгол'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी'},
    {'code': 'ms', 'name': 'Malay', 'nativeName': 'Bahasa Melayu'},
    {'code': 'mt', 'name': 'Maltese', 'nativeName': 'Malti'},
    {'code': 'my', 'name': 'Burmese', 'nativeName': 'မြန်မာဘာသာ'},
    {'code': 'na', 'name': 'Nauru', 'nativeName': 'Dorerin Naoero'},
    {'code': 'nb', 'name': 'Norwegian Bokmål', 'nativeName': 'Norsk bokmål'},
    {'code': 'nd', 'name': 'North Ndebele', 'nativeName': 'isiNdebele'},
    {'code': 'ne', 'name': 'Nepali', 'nativeName': 'नेपाली'},
    {'code': 'ng', 'name': 'Ndonga', 'nativeName': 'Oshiwambo'},
    {'code': 'nl', 'name': 'Dutch', 'nativeName': 'Nederlands'},
    {'code': 'nn', 'name': 'Norwegian Nynorsk', 'nativeName': 'Norsk nynorsk'},
    {'code': 'no', 'name': 'Norwegian', 'nativeName': 'Norsk'},
    {'code': 'nr', 'name': 'South Ndebele', 'nativeName': 'isiNdebele'},
    {'code': 'nv', 'name': 'Navajo', 'nativeName': 'Diné bizaad'},
    {'code': 'ny', 'name': 'Nyanja', 'nativeName': 'ChiChewa'},
    {'code': 'oc', 'name': 'Occitan', 'nativeName': 'Occitan'},
    {'code': 'oj', 'name': 'Ojibwa', 'nativeName': 'Anishinaabemowin'},
    {'code': 'om', 'name': 'Oromo', 'nativeName': 'Oromoo'},
    {'code': 'or', 'name': 'Oriya', 'nativeName': 'ଓଡ଼ିଆ'},
    {'code': 'os', 'name': 'Ossetian', 'nativeName': 'Ирон æвзаг'},
    {'code': 'pa', 'name': 'Panjabi', 'nativeName': 'ਪੰਜਾਬੀ'},
    {'code': 'pi', 'name': 'Pali', 'nativeName': 'Pāli'},
    {'code': 'pl', 'name': 'Polish', 'nativeName': 'Polski'},
    {'code': 'ps', 'name': 'Pashto', 'nativeName': 'پښتو'},
    {'code': 'pt', 'name': 'Portuguese', 'nativeName': 'Português'},
    {'code': 'qu', 'name': 'Quechua', 'nativeName': 'Runa simi'},
    {'code': 'rm', 'name': 'Romansh', 'nativeName': 'Rumantsch'},
    {'code': 'rn', 'name': 'Kirundi', 'nativeName': 'Ikirundi'},
    {'code': 'ro', 'name': 'Romanian', 'nativeName': 'română'},
    {'code': 'ru', 'name': 'Russian', 'nativeName': 'русский язык'},
    {'code': 'rw', 'name': 'Kinyarwanda', 'nativeName': 'Kinyarwanda'},
    {'code': 'sa', 'name': 'Sanskrit', 'nativeName': 'संस्कृतम्'},
    {'code': 'sc', 'name': 'Sardinian', 'nativeName': 'Sardu'},
    {'code': 'sd', 'name': 'Sindhi', 'nativeName': 'سنڌي'},
    {'code': 'se', 'name': 'Northern Sami', 'nativeName': 'Sámegiella'},
    {'code': 'sg', 'name': 'Sango', 'nativeName': 'Sängö'},
    {'code': 'si', 'name': 'Sinhala', 'nativeName': 'සිංහල'},
    {'code': 'sk', 'name': 'Slovak', 'nativeName': 'Slovenčina'},
    {'code': 'sl', 'name': 'Slovenian', 'nativeName': 'Slovenščina'},
    {'code': 'sm', 'name': 'Samoan', 'nativeName': 'Gagana Sāmoa'},
    {'code': 'sn', 'name': 'Shona', 'nativeName': 'chiShona'},
    {'code': 'so', 'name': 'Somali', 'nativeName': 'Soomaaliga'},
    {'code': 'sq', 'name': 'Albanian', 'nativeName': 'Shqip'},
    {'code': 'sr', 'name': 'Serbian', 'nativeName': 'српски језик'},
    {'code': 'ss', 'name': 'Swati', 'nativeName': 'SiSwati'},
    {'code': 'st', 'name': 'Southern Sotho', 'nativeName': 'Sesotho'},
    {'code': 'su', 'name': 'Sundanese', 'nativeName': 'Basa Sunda'},
    {'code': 'sv', 'name': 'Swedish', 'nativeName': 'Svenska'},
    {'code': 'sw', 'name': 'Swahili', 'nativeName': 'Kiswahili'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు'},
    {'code': 'tg', 'name': 'Tajik', 'nativeName': 'тоҷикӣ'},
    {'code': 'th', 'name': 'Thai', 'nativeName': 'ไทย'},
    {'code': 'ti', 'name': 'Tigrinya', 'nativeName': 'ትግርኛ'},
    {'code': 'tk', 'name': 'Turkmen', 'nativeName': 'Türkmençe'},
    {'code': 'tl', 'name': 'Tagalog', 'nativeName': 'Tagalog'},
    {'code': 'tn', 'name': 'Tswana', 'nativeName': 'Setswana'},
    {'code': 'to', 'name': 'Tongan', 'nativeName': 'lea faka-Tonga'},
    {'code': 'tr', 'name': 'Turkish', 'nativeName': 'Türkçe'},
    {'code': 'ts', 'name': 'Tsonga', 'nativeName': 'Xitsonga'},
    {'code': 'tt', 'name': 'Tatar', 'nativeName': 'татарча'},
    {'code': 'tw', 'name': 'Twi', 'nativeName': 'Twi'},
    {'code': 'ty', 'name': 'Tahitian', 'nativeName': 'Reo Tahiti'},
    {'code': 'ug', 'name': 'Uyghur', 'nativeName': 'ئۇيغۇرچە'},
    {'code': 'uk', 'name': 'Ukrainian', 'nativeName': 'українська мова'},
    {'code': 'ur', 'name': 'Urdu', 'nativeName': 'اردو'},
    {'code': 'uz', 'name': 'Uzbek', 'nativeName': 'Oʻzbekcha'},
    {'code': 've', 'name': 'Venda', 'nativeName': 'Tshivenḓa'},
    {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    {'code': 'vo', 'name': 'Volapük', 'nativeName': 'Volapük'},
    {'code': 'wa', 'name': 'Walloon', 'nativeName': 'Walon'},
    {'code': 'wo', 'name': 'Wolof', 'nativeName': 'Wolof'},
    {'code': 'xh', 'name': 'Xhosa', 'nativeName': 'isiXhosa'},
    {'code': 'yi', 'name': 'Yiddish', 'nativeName': 'ייִדיש'},
    {'code': 'yo', 'name': 'Yoruba', 'nativeName': 'Yorùbá'},
    {'code': 'za', 'name': 'Zhuang', 'nativeName': 'Saw cuengh'},
    {'code': 'zh', 'name': 'Chinese', 'nativeName': '中文'},
    {'code': 'zu', 'name': 'Zulu', 'nativeName': 'isiZulu'}
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
/// Languages the app and API support. Add a code here, a map in strings_data.dart,
/// names in models.dart and sample text in assets/sample/stories.json to add another.
const kLanguages = <({String code, String native})>[
  (code: 'en', native: 'English'),
  (code: 'hi', native: 'हिन्दी'),
  (code: 'mr', native: 'मराठी'),
];

/// Hindi and Marathi share the Devanagari fonts and taller line heights.
bool isDevanagari(String code) => code == 'hi' || code == 'mr';

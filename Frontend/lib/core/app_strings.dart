class AppStrings {
  static const Map<String, Map<String, String>> _data = {
    /// ================= ENGLISH =================
    'en': {
      'location': 'Location',
      'current_weather': 'Current Weather',
      'quick_access': 'Quick Access',
      'crop_prices': 'Crop Prices',
      'weather': 'Weather',
      'clear': 'Clear',
      'ask_ai': 'Ask AI',
      'dashboard': 'Dashboard',
      'last_updated': 'Last updated',
      'language': 'Language',
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'logout': 'Logout',
      'notifications': 'Notifications',
      'help_support': 'Help & Support',
      'village': 'Village',
      'save_changes': 'Save Changes',
      'change_language': 'Change Language',
    },

    /// ================= HINDI (DEFAULT) =================
    'hi': {
      'location': 'स्थान',
      'current_weather': 'मौसम की जानकारी',
      'quick_access': 'त्वरित सेवाएं',
      'crop_prices': 'फसल के दाम',
      'weather': 'मौसम',
      'clear': 'साफ',
      'ask_ai': 'AI से पूछें',
      'dashboard': 'डैशबोर्ड',
      'last_updated': 'अंतिम अपडेट',
      'language': 'भाषा',
      'profile': 'प्रोफ़ाइल',
      'edit_profile': 'प्रोफ़ाइल संपादित करें',
      'logout': 'लॉग आउट',
      'notifications': 'सूचनाएं',
      'help_support': 'मदद और सहायता',
      'village': 'गांव',
      'save_changes': 'बदलाव सहेजें',
      'change_language': 'भाषा बदलें',
    },
  };

  /// 🔑 Universal text getter
  /// Usage: AppStrings.text('key', languageCode)
  static String text(String key, String lang) {
    return _data[lang]?[key] ?? _data['hi']?[key] ?? key;
  }
}
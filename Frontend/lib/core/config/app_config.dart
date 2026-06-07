/// AppConfig — single source of truth for all environment-specific values.
///
/// Values are injected at build time via --dart-define-from-file=env.json
/// so no secrets ever live in source code.
///
/// Usage:
///   AppConfig.chatApiBase          → chat/AI endpoint
///   AppConfig.weatherApiBase       → weather + location endpoint
///   AppConfig.diseaseApiBase       → crop disease ML endpoint
///   AppConfig.cropPriceApiBase     → mandi price endpoint
///
/// Setup (developer):
///   1. Copy env.json.example → env.json  (already in .gitignore)
///   2. Fill in your Render / Railway / cloud URLs
///   3. Run:  flutter run --dart-define-from-file=env.json
class AppConfig {
  AppConfig._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // API base URLs
  // ---------------------------------------------------------------------------

  static const String chatApiBase = String.fromEnvironment(
    'CHAT_API_BASE',
    defaultValue: 'https://krishimitra-ai-6.onrender.com',
  );

  static const String weatherApiBase = String.fromEnvironment(
    'WEATHER_API_BASE',
    defaultValue: 'https://krishimitra-ai-7.onrender.com',
  );

  /// Disease-detection ML backend (Flask/FastAPI with /predict endpoint).
  /// In development this is your local server; in CI/prod it's the deployed URL.
  static const String diseaseApiBase = String.fromEnvironment(
    'DISEASE_API_BASE',
    defaultValue: 'http://127.0.0.1:8000', // overridden via env.json in prod
  );

  /// Mandi / crop-price backend (/mandi, /districts, /mandis endpoints).
  static const String cropPriceApiBase = String.fromEnvironment(
    'CROP_PRICE_API_BASE',
    defaultValue: 'http://127.0.0.1:5000', // overridden via env.json in prod
  );

  // ---------------------------------------------------------------------------
  // Feature flags (easy to flip per environment)
  // ---------------------------------------------------------------------------

  /// Set to 'true' in env.json to enable verbose API logging in debug builds.
  static const bool enableApiLogging = bool.fromEnvironment(
    'ENABLE_API_LOGGING',
    defaultValue: false,
  );
}
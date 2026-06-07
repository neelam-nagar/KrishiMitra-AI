/// AppConfig — single source of truth for all environment-specific values.
///
/// Values are injected at build time via --dart-define-from-file=env.json
/// so no secrets ever live in source code.
///
/// Setup (developer):
///   1. Copy env.json.example → env.json  (already in .gitignore)
///   2. Fill in your deployed backend URL
///   3. Run:  flutter run --dart-define-from-file=env.json
///
/// All modules now share a SINGLE unified backend URL.
class AppConfig {
  AppConfig._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Unified backend base URL
  // In production, point this to your deployed backend (Render, Railway, etc.)
  // ---------------------------------------------------------------------------
  static const String _backendBase = String.fromEnvironment(
    'BACKEND_BASE',
    defaultValue: 'https://krishimitra-hrrf.onrender.com', // Android emulator → host localhost
  );

  // ---------------------------------------------------------------------------
  // Individual module API bases — all derived from the unified backend.
  // Keep separate constants for clarity and future independent scaling.
  // ---------------------------------------------------------------------------

  static const String chatApiBase = String.fromEnvironment(
    'CHAT_API_BASE',
    defaultValue: _backendBase,
  );

  static const String weatherApiBase = String.fromEnvironment(
    'WEATHER_API_BASE',
    defaultValue: _backendBase,
  );

  static const String diseaseApiBase = String.fromEnvironment(
    'DISEASE_API_BASE',
    defaultValue: _backendBase,
  );

  static const String cropPriceApiBase = String.fromEnvironment(
    'CROP_PRICE_API_BASE',
    defaultValue: _backendBase,
  );

  // ---------------------------------------------------------------------------
  // Feature flags (easy to flip per environment)
  // ---------------------------------------------------------------------------

  static const bool enableApiLogging = bool.fromEnvironment(
    'ENABLE_API_LOGGING',
    defaultValue: false,
  );
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/language_provider.dart';
import '../../core/location_provider.dart';
import '../../core/auth/auth_service.dart';
import '../main_shell/main_shell_screen.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _phone = '';
  String _photoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      // Name: prefer saved custom name, then Firebase displayName, then fallback
      _name = prefs.getString('profile_name') ??
          user?.displayName ??
          (user?.phoneNumber != null ? 'Farmer' : 'Farmer Name');

      // Phone: from Firebase Auth (E.164 format)
      _phone = user?.phoneNumber ?? prefs.getString('last_phone_number') ?? '';

      // Photo URL: prefer saved, then Firebase photoURL
      _photoUrl = prefs.getString('profile_photo') ?? user?.photoURL ?? '';
    });
  }

  Future<void> _logout() async {
    await AuthService.instance.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.mobileLogin,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;
    final locationProvider = context.watch<LocationProvider>();

    return MainShellScreen(
      currentItem: CustomBottomBarItem.profile,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F7F9),
        appBar: AppBar(
          backgroundColor: theme.colorScheme.primary,
          elevation: 0,
          title: Text(
            lang == 'en' ? 'Profile' : 'प्रोफ़ाइल',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        backgroundImage: _photoUrl.isNotEmpty
                            ? NetworkImage(_photoUrl)
                            : null,
                        child: _photoUrl.isEmpty
                            ? Icon(
                                Icons.person_outline,
                                size: 48,
                                color: theme.colorScheme.primary,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _name.isNotEmpty
                          ? _name
                          : (lang == 'en' ? 'Farmer' : 'किसान'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (_phone.isNotEmpty)
                      Text(
                        _phone,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          letterSpacing: 0.3,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ProfileStat(
                            title: lang == 'en' ? 'Location' : 'स्थान',
                            value: locationProvider.village.isNotEmpty
                                ? locationProvider.village
                                : (lang == 'en' ? 'Not set' : 'नहीं चुना'),
                          ),
                          const SizedBox(width: 24),
                          _ProfileStat(
                            title: lang == 'en' ? 'Language' : 'भाषा',
                            value: lang == 'en' ? 'English' : 'हिंदी',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Menu tiles ────────────────────────────────
              _profileTile(
                icon: Icons.edit,
                title: lang == 'en' ? 'Edit Profile' : 'प्रोफ़ाइल संपादित करें',
                onTap: () async {
                  final result = await Navigator.pushNamed(
                    context,
                    AppRoutes.editProfile,
                  );
                  if (result is Map) {
                    final prefs = await SharedPreferences.getInstance();
                    if (result['name'] != null) {
                      await prefs.setString(
                          'profile_name', result['name'] as String);
                    }
                    if (result['photo'] != null) {
                      await prefs.setString(
                          'profile_photo', result['photo'] as String);
                    }
                    _loadProfile();
                  }
                },
              ),
              _profileTile(
                icon: Icons.language,
                title: lang == 'en' ? 'Change Language' : 'भाषा बदलें',
                onTap: () {
                  final provider = context.read<LanguageProvider>();
                  provider.changeLanguage(
                    provider.currentLanguage == 'en' ? 'hi' : 'en',
                  );
                },
              ),
              _profileTile(
                icon: Icons.logout,
                title: lang == 'en' ? 'Logout' : 'लॉग आउट',
                isLogout: true,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title:
                          Text(lang == 'en' ? 'Logout' : 'लॉग आउट'),
                      content: Text(
                        lang == 'en'
                            ? 'Are you sure you want to logout?'
                            : 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                              lang == 'en' ? 'Cancel' : 'रद्द करें'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _logout();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: Text(
                            lang == 'en' ? 'Logout' : 'लॉग आउट',
                            style:
                                const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _profileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Builder(
        builder: (context) => InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout
                      ? Colors.red
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? Colors.red : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String title;
  final String value;
  const _ProfileStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

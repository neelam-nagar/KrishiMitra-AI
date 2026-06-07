import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/language_provider.dart';
import '../main_shell/main_shell_screen.dart';
import '../../widgets/custom_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Farmer Name';
  String _phone = '+91 XXXXXXXX';
  String _village = 'Your Village';
  String _photoUrl = "";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lang = context.watch<LanguageProvider>().currentLanguage;

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
        body: _buildProfileBody(context),
      ),
    );
  }

  Widget _buildProfileBody(BuildContext context) {
    final lang = context.watch<LanguageProvider>().currentLanguage;
    return SingleChildScrollView(
      child: Column(
        children: [
          // ===== USER HEADER =====
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
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
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    backgroundImage: _photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null,
                    child: _photoUrl.isEmpty
                        ? Icon(
                            Icons.person_outline,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _phone,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(title: lang == 'en' ? 'Location' : 'स्थान', value: _village),
                      const SizedBox(width: 24),
                      _ProfileStat(title: lang == 'en' ? 'Language' : 'भाषा', value: lang == 'en' ? 'English' : 'हिंदी'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _profileTile(
            icon: Icons.edit,
            title: lang == 'en' ? 'Edit Profile' : 'प्रोफ़ाइल संपादित करें',
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/edit-profile');

              if (result is Map) {
                setState(() {
                  _name = result['name'] ?? _name;
                  _phone = result['phone'] ?? _phone;
                  _village = result['location'] ?? _village;
                  _photoUrl = result['photo'] ?? _photoUrl;
                });
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
                  title: Text(lang == 'en' ? 'Logout' : 'लॉग आउट'),
                  content: Text(
                    lang == 'en'
                        ? 'Are you sure you want to logout?'
                        : 'क्या आप वाकई लॉग आउट करना चाहते हैं?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(lang == 'en' ? 'Cancel' : 'रद्द करें'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                      child: Text(lang == 'en' ? 'Logout' : 'लॉग आउट'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
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
          splashColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isLogout ? Colors.red : Theme.of(context).colorScheme.primary,
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
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
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

  const _ProfileStat({
    required this.title,
    required this.value,
  });

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
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
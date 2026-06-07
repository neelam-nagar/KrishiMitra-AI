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
  String _name = 'Neelam Nagar';
  String _phone = '+91 9828833182';
  String _village = 'Baran';

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
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person_outline,
                      size: 42,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  _name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _phone,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat(title: lang == 'en' ? 'Village' : 'गांव', value: _village),
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
                  _village = result['village'] ?? _village;
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
            icon: Icons.notifications,
            title: lang == 'en' ? 'Notifications' : 'सूचनाएं',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    lang == 'en'
                        ? 'Notifications feature coming soon'
                        : 'सूचनाएं फीचर जल्द आ रहा है',
                  ),
                ),
              );
            },
          ),
          _profileTile(
            icon: Icons.help_outline,
            title: lang == 'en' ? 'Help & Support' : 'सहायता',
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(lang == 'en' ? 'Help & Support' : 'सहायता'),
                  content: Text(
                    lang == 'en'
                        ? 'For any help, contact: support@krishimitra.ai'
                        : 'किसी भी सहायता के लिए संपर्क करें: support@krishimitra.ai',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(lang == 'en' ? 'OK' : 'ठीक है'),
                    ),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
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
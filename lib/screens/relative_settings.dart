import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kronik_hasta_takip/screens/login_email_screen.dart';
import 'package:kronik_hasta_takip/screens/relative_profile.dart';
import 'relative_help.dart';
import 'relative_security.dart';

class RelativeSettings extends StatelessWidget {
  const RelativeSettings({super.key});

  final double titleFontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('images/arka_plan.png', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              "Ayarlar",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            automaticallyImplyLeading: false, // ← Geri tuşu gizlenir
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  title: "Profil",
                  icon: Icons.person_outline,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RelativeProfile()),
                      ),
                ),
                _buildSettingsTile(
                  context,
                  title: "Güvenlik",
                  icon: Icons.lock_outline,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RelativeSecurity(),
                        ),
                      ),
                ),
                _buildSettingsTile(
                  context,
                  title: "Yardım",
                  icon: Icons.help_outline,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RelativeHelp()),
                      ),
                ),
                _buildSettingsTile(
                  context,
                  title: "Çıkış Yap",
                  icon: Icons.logout,
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Çıkış Yap"),
                            content: const Text(
                              "Çıkmak istediğinize emin misiniz?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Hayır"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Evet"),
                              ),
                            ],
                          ),
                    );
                    if (confirm == true) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LoginEmailScreen(),
                        ),
                        (_) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        leading: Icon(icon, size: 28, color: Colors.grey[700]),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

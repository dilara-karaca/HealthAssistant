import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kronik_hasta_takip/screens/login_email_screen.dart';
import 'package:kronik_hasta_takip/screens/relative_profile.dart';
import 'relative_help.dart';
import 'relative_security.dart' show RelativeSecurity;

class PatientsSettings extends StatelessWidget {
  final double titleFontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'images/arka_plan.png', // Asset yolunu kontrol et
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text(
              "Ayarlar",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
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
                        MaterialPageRoute(
                          builder: (context) => RelativeProfile(),
                        ),
                      ),
                  fontSize: titleFontSize,
                ),
                _buildSettingsTile(
                  context,
                  title: "Güvenlik",
                  icon: Icons.lock_outline,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RelativeSecurity(),
                        ),
                      ),
                  fontSize: titleFontSize,
                ),
                _buildSettingsTile(
                  context,
                  title: "Yardım",
                  icon: Icons.help_outline,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RelativeHelp()),
                      ),
                  fontSize: titleFontSize,
                ),
                _buildSettingsTile(
                  context,
                  title: "Çıkış Yap",
                  icon: Icons.logout,
                  onTap: () async {
                    final shouldLogout = await showDialog<bool>(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: const Text(
                              "Çıkış Yap",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            content: const Text(
                              "Çıkış yapmak istediğinize emin misiniz?",
                              style: TextStyle(fontSize: 19),
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text(
                                  "Hayır",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text(
                                  "Evet",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (shouldLogout == true) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginEmailScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  fontSize: titleFontSize,
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
    double fontSize = 18,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
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
          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

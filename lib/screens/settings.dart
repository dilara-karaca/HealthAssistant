import 'package:flutter/material.dart';
import 'profile.dart';
import 'security.dart';
import 'device_connection.dart';
import 'help.dart';

class Settings extends StatelessWidget {
  final double titleFontSize = 20;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/arka_plan.png', fit: BoxFit.cover),
          ),
          Padding(
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
                        MaterialPageRoute(builder: (context) => ProfilePage()),
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
                        MaterialPageRoute(builder: (context) => SecurityPage()),
                      ),
                  fontSize: titleFontSize,
                ),
                _buildSettingsTile(
                  context,
                  title: "Cihaz Bağlantısı",
                  icon: Icons.devices_other,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DeviceConnection(),
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
                        MaterialPageRoute(builder: (context) => HelpPage()),
                      ),
                  fontSize: titleFontSize,
                ),
              ],
            ),
          ),
        ],
      ),
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
        color: Colors.white,
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

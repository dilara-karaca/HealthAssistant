import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatelessWidget {
  final List<Map<String, String>> contacts = [
    {'name': 'Helin Özalkan', 'phone': '05*'},
    {'name': 'Zemzem Ertekin', 'phone': '05*'},
    {'name': 'Bedirhan Akarçeşme', 'phone': '05*'},
  ];

  @override
  Widget build(BuildContext context) {
    // Debug için arka plan resmi yüklenip yüklenmediğini kontrol ediyoruz
    final AssetImage assetImage = AssetImage('images/arka_plan.png');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
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
                Center(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 60,
                        vertical: 60,
                      ),
                      shape: const CircleBorder(),
                      elevation: 10,
                      shadowColor: Colors.black54,
                    ),
                    child: const Text(
                      'ACİL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Lütfen Acil Durum Çağrısı için Basınız',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bilgilendirilecek Hasta Yakınlarım',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ...contacts
                    .map(
                      (contact) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: const Color(0x4D5150B2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(
                            contact['name']!,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.phone, color: Colors.black),
                            onPressed: () => _makePhoneCall(contact['phone']!),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Arama başlatılamadı: $phoneNumber';
    }
  }
}

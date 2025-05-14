import 'package:flutter/material.dart';

class RelativeHelp extends StatelessWidget {
  const RelativeHelp({super.key});

  final List<_HelpInfo> helpItems = const [
    _HelpInfo(
      color: Colors.green,
      icon: Icons.watch,
      title: "Giyilebilir Sağlık Teknolojileri",
      description:
          "Pazu bandı sayesinde, tansiyon ve kalp atışı gibi sağlık verilerinizi otomatik takip edin.",
    ),
    _HelpInfo(
      color: Colors.lightBlue,
      icon: Icons.cloud_outlined,
      title: "Sağlık Verilerinize Her An Ulaşın",
      description: "Mobil cihazınızdan her an sağlık verilerine erişin.",
    ),
    _HelpInfo(
      color: Colors.blueGrey,
      icon: Icons.history,
      title: "Sağlık Geçmişinizi Görüntüleyin",
      description:
          "Tüm verilerinize uygulama üzerinden erişin. Geçmişe dönük verilerinizi inceleyin.",
    ),
    _HelpInfo(
      color: Colors.redAccent,
      icon: Icons.emergency,
      title: "112 Acil Butonu ile Acil Durumlarda Çaresiz Kalmayın",
      description:
          "112 acil butonu ile acil durumlarda çağrınızı başlatın. Çağrı başladığında yakınınız da bilgilendirilecektir.",
    ),
    _HelpInfo(
      color: Color.fromARGB(255, 181, 220, 81),
      icon: Icons.smart_toy,
      title: "ChatBot ile Sağlık Önerileri Alın",
      description:
          "ChatBot ile sağlığınız hakkında öneriler alın. Sağlık verilerinizi analiz ederek size önerilerde bulunur.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            itemCount: helpItems.length,
            itemBuilder: (context, index) {
              final item = helpItems[index];
              return Container(
                color: item.color,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 100, color: Colors.white),
                    const SizedBox(height: 40),
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpInfo {
  final Color color;
  final IconData icon;
  final String title;
  final String description;

  const _HelpInfo({
    required this.color,
    required this.icon,
    required this.title,
    required this.description,
  });
}

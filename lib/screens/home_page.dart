import 'package:flutter/material.dart';
import 'package:kronik_hasta_takip/screens/line_chart_sample.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showPatientCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Merhaba',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileRow(),
            const SizedBox(height: 20),
            _buildDataCard("Adım Sayısı", "1200", "Adım", "images/ayak.png"),
            _buildDataCard("Vücut Isısı", "37", "°C", "images/sicaklik.png"),
            _buildDataCard("Kan Oksijen Seviyesi", "96", "%", "images/kan.png"),
            _buildDataCard(
              "Stres Seviyesi",
              "Düşük",
              "",
              "images/stressed.png",
            ),
            const SizedBox(height: 20),
            _buildBpmGraphCard(),
            const SizedBox(height: 20),
            _buildLineChartSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('images/person.png'),
            ),
            const SizedBox(width: 10),
            const Text(
              'Sudenaz Kartal',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        _buildPatientCodeWidget(),
      ],
    );
  }

  Widget _buildPatientCodeWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Text(
            showPatientCode ? "HT6A2B" : "Hasta Kodu",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => showPatientCode = !showPatientCode),
            child: Icon(
              showPatientCode ? Icons.visibility : Icons.visibility_off,
              size: 20,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(
    String title,
    String value,
    String unit,
    String iconPath,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(iconPath, width: 40),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            "$value $unit",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBpmGraphCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Kalp Atış Ritmi (BPM)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text(
              "Son ölçüm: 67 BPM",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 12),
            LinearProgressIndicator(
              value: 0.67,
              minHeight: 10,
              backgroundColor: Colors.grey,
              color: Colors.red,
            ),
            SizedBox(height: 8),
            Text(
              "Yavaş        Normal        Hızlı",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChartSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 6,
      child: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              "Geçmiş Kalp Ritmi",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 12),
            SizedBox(height: 100, child: LineChartSample()),
          ],
        ),
      ),
    );
  }
}

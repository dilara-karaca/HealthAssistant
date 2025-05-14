import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'maps.dart';
import 'relative_security.dart';
import 'relative_settings.dart';

class RelativeHomePage extends StatefulWidget {
  @override
  RelativeHomePageState createState() => RelativeHomePageState();
}

class RelativeHomePageState extends State<RelativeHomePage> {
  final TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final TextStyle valueStyle = const TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w900,
    color: Colors.black,
  );

  String? patientName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPatientName();
  }

  String getPossessiveSuffix(String name) {
    final lowerName = name.toLowerCase();
    final vowels = ['a', 'e', 'ı', 'i', 'o', 'ö', 'u', 'ü'];
    final lastVowel = lowerName
        .split('')
        .lastWhere((c) => vowels.contains(c), orElse: () => 'a');

    String suffix;
    if (['a', 'ı'].contains(lastVowel)) {
      suffix = "'ın";
    } else if (['e', 'i'].contains(lastVowel)) {
      suffix = "'in";
    } else if (['o', 'u'].contains(lastVowel)) {
      suffix = "'un";
    } else {
      suffix = "'ün";
    }

    return "$name$suffix";
  }

  String addPossessiveSuffix(String name) {
    if (name.isEmpty) return "Hasta'nın";

    final vowels = 'aeıioöuü';
    final lastVowel = name
        .split('')
        .reversed
        .firstWhere(
          (char) => vowels.contains(char.toLowerCase()),
          orElse: () => 'a',
        );

    String suffix;
    switch (lastVowel.toLowerCase()) {
      case 'a':
      case 'ı':
        suffix = "'nın";
        break;
      case 'e':
      case 'i':
        suffix = "'nin";
        break;
      case 'o':
      case 'u':
        suffix = "'nun";
        break;
      case 'ö':
      case 'ü':
        suffix = "'nün";
        break;
      default:
        suffix = "'nın";
    }

    return "$name$suffix";
  }

  Future<void> fetchPatientName() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final relativeDoc =
          await FirebaseFirestore.instance
              .collection('relatives')
              .doc(uid)
              .get();

      final linkedPatientId = relativeDoc.data()?['linkedPatient'];
      if (linkedPatientId == null) return;

      final patientDoc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(linkedPatientId)
              .get();

      final name = patientDoc.data()?['name'];
      setState(() {
        patientName = name ?? "Hasta";
        isLoading = false;
      });
    } catch (e) {
      print("Hasta adı alınamadı: $e");
      setState(() => isLoading = false);
    }
  }

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 300,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Bildirimler",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "Nabız",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text("Nabız seviyeniz normal aralıkta."),
                Divider(),
                Text(
                  "Vücut Sıcaklığı",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text("Vücut sıcaklığınız normal."),
                Divider(),
                Text(
                  "Stres Seviyesi",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Text("Stres seviyeniz düşük."),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName =
        isLoading || patientName == null
            ? null
            : "${getPossessiveSuffix(patientName!.split(' ').first)}";

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Merhaba',
            style: TextStyle(
              fontSize: 28,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: _showNotificationsPanel,
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 1,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/arka_plan.png'),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                    "$displayName Verileri",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              const SizedBox(height: 16),
              buildInfoCard(
                title: 'Kalp Atışı',
                value: '67 bpm',
                icon: Image.asset('images/kalp.png', width: 42, height: 42),
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
              buildInfoCard(
                title: 'Vücut Sıcaklığı',
                value: '37°C',
                icon: Image.asset('images/sicaklik.png', width: 42, height: 42),
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
              buildInfoCard(
                title: 'Kan Oksijen',
                value: '96 %',
                icon: Image.asset('images/kan.png', width: 42, height: 42),
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
              buildInfoCard(
                title: 'Stres Seviyesi',
                value: 'Düşük',
                icon: Image.asset('images/stres.png', width: 42, height: 42),
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF18202B),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 40, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.settings, size: 40, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PatientsSettings()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          child: const Icon(Icons.location_on, color: Colors.white, size: 36),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HaritaPage()),
            );
          },
        ),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String value,
    required Widget icon,
    required TextStyle titleStyle,
    required TextStyle valueStyle,
    Color backgroundColor = Colors.white,
  }) {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          icon,
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: titleStyle)),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

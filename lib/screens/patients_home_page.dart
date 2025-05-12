import 'package:flutter/material.dart';
import 'maps.dart';
import 'patients_security.dart';
import 'patients_settings.dart';

class PatientHomePage extends StatefulWidget {
  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientHomePage> {
  final TextStyle titleStyle = const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  final TextStyle valueStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: Color.fromARGB(255, 94, 92, 92),
  );

  void _showNotificationsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            width: MediaQuery.of(context).size.width * 0.95,
            height: 300,
            padding: EdgeInsets.all(16),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Merhaba',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black),
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
              const Text(
                "Sudenaz'ın Verileri",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                icon: Image.asset(
                  'images/termostat.png',
                  width: 42,
                  height: 42,
                ),
                titleStyle: titleStyle,
                valueStyle: valueStyle,
              ),
              buildInfoCard(
                title: 'Kan Oksijen',
                value: '96 %',
                icon: Image.asset('images/oksijen.png', width: 42, height: 42),
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
        color: Color(0xFF303E58),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Container(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, size: 30, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
              ),
              SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.settings, size: 30, color: Colors.white),
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
          shape: CircleBorder(),
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
    Color backgroundColor = const Color.fromARGB(77, 57, 56, 82),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
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

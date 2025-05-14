import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reset_password.dart';
import 'delete_account.dart';

class PatientsSecurity extends StatefulWidget {
  const PatientsSecurity({Key? key}) : super(key: key);

  @override
  State<PatientsSecurity> createState() => _PatientsSecurityState();
}

class _PatientsSecurityState extends State<PatientsSecurity> {
  List<Map<String, String>> relatives = [];

  @override
  void initState() {
    super.initState();
    fetchRelatives();
  }

  Future<void> fetchRelatives() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('relatives')
            .where('linkedPatient', isEqualTo: uid)
            .get();

    setState(() {
      relatives =
          snapshot.docs.map((doc) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            return {
              'name':
                  '${data['name'] as String? ?? ''} ${data['surname'] as String? ?? ''}',
              'email': data['email'] as String? ?? '',
              'uid': data['uid'] as String? ?? '',
            };
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Güvenlik')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                Icons.lock_reset,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text(
                'Şifre Yenile',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResetPasswordPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: Icon(
                Icons.delete_forever,
                color: Theme.of(context).primaryColor,
              ),
              title: const Text(
                'Hesabı Kapat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DeleteAccountPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Hasta Yakınlarım',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...relatives.map(
            (relative) => Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(
                  relative['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(relative['email'] ?? ''),
              ),
            ),
          ),
          if (relatives.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8.0),
              child: Text("Henüz tanımlı hasta yakını bulunmuyor."),
            ),
        ],
      ),
    );
  }
}

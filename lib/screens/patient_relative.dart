import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PatientRelativePage extends StatefulWidget {
  const PatientRelativePage({super.key});

  @override
  State<PatientRelativePage> createState() => _PatientRelativePageState();
}

class _PatientRelativePageState extends State<PatientRelativePage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> _addRelative(BuildContext context) async {
    String newName = '';
    String newPhone = '';

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Yeni Hasta Yakını Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: const InputDecoration(labelText: 'İsim'),
                onChanged: (value) => newName = value,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Telefon Numarası',
                ),
                keyboardType: TextInputType.phone,
                onChanged: (value) => newPhone = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('İptal'),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text('Ekle'),
              onPressed: () async {
                if (newName.trim().isNotEmpty && newPhone.trim().isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('patients')
                      .doc(currentUserId)
                      .collection('relatives')
                      .add({
                        'name': newName,
                        'phone': newPhone,
                        'createdAt': Timestamp.now(),
                      });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRelative(String docId) async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(currentUserId)
        .collection('relatives')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Hasta Yakınlarım',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () => _addRelative(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('images/arka_plan.png', fit: BoxFit.cover),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('patients')
                    .doc(currentUserId)
                    .collection('relatives')
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text("Henüz kayıtlı yakınız yok."));
              }

              final relatives = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: relatives.length,
                itemBuilder: (context, index) {
                  final data = relatives[index];
                  final docId = data.id;
                  final name = data['name'];
                  final phone = data['phone'];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(phone),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteRelative(docId),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

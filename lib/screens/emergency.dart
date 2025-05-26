import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  List<Map<String, dynamic>> relatives = [];

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
            final data = doc.data();
            return {
              'uid': data['uid'] ?? '',
              'name': '${data['name'] ?? ''} ${data['surname'] ?? ''}',
              'phone': data['phone'] ?? '',
            };
          }).toList();
    });
  }

  Future<void> callRelative(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Arama başlatılamadı.")));
    }
  }

  Future<void> sendEmergencyNotification(String relativeUid) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'to': relativeUid,
      'message': 'Hastanız acil durum bildirimi gönderdi.',
      'timestamp': Timestamp.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Bildirim gönderildi.")));
  }

  @override
  Widget build(BuildContext context) {
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
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Colors.red, Color(0xFFB71C1C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade900.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        callRelative("112");
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.all(60),
                        elevation: 0,
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
                ),
                const SizedBox(height: 18),
                const Text(
                  'Lütfen Acil Durum Çağrısı için Yakına Bildirim Gönderiniz',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bilgilendirilecek Hasta Yakınlarım',
                  style: TextStyle(fontSize: 15, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                ...relatives.map(
                  (contact) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: const Color(0x4D5150B2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(
                        contact['name'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.notification_important,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(
                                      Icons.notification_important,
                                      color: Colors.red,
                                    ),
                                    title: const Text("Bildirim Gönder"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      sendEmergencyNotification(
                                        contact['uid'] ?? '',
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                      Icons.phone,
                                      color: Colors.green,
                                    ),
                                    title: const Text("Telefonla Ara"),
                                    onTap: () {
                                      Navigator.pop(context);
                                      callRelative(contact['phone'] ?? '');
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

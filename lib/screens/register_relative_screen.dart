import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterRelativeScreen extends StatefulWidget {
  const RegisterRelativeScreen({super.key});

  @override
  State<RegisterRelativeScreen> createState() => _RegisterRelativeScreenState();
}

class _RegisterRelativeScreenState extends State<RegisterRelativeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController patientCodeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF3EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDFF3EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Kronik Hasta Takip',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.asset(
                    'images/adsiz_tasarim_14.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed:
                              () => Navigator.pushNamed(
                                context,
                                '/registerPatient',
                              ),
                          child: const Text(
                            'Hasta',
                            style: TextStyle(color: Colors.black87),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.black87,
                          ),
                          child: const Text(
                            'Hasta Yakını',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildInputField(label: 'Ad', controller: nameController),
                buildInputField(label: 'Soyad', controller: surnameController),
                buildInputField(label: 'E-posta', controller: emailController),
                buildInputField(
                  label: 'Telefon Numarası',
                  controller: phoneController,
                ),
                buildInputField(
                  label: 'Şifre',
                  controller: passwordController,
                  obscureText: true,
                ),
                buildInputField(
                  label: 'Şifre Tekrar',
                  controller: confirmPasswordController,
                  obscureText: true,
                ),
                buildInputField(
                  label: 'Hasta Bağlantı Kodu',
                  controller: patientCodeController,
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _registerRelative,
                  child: Image.asset('images/frame_60.png', width: 120),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInputField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _registerRelative() async {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final patientCode = patientCodeController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Şifreler eşleşmiyor.")));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre en az 6 karakter olmalı.")),
      );
      return;
    }

    try {
      final patientQuery =
          await FirebaseFirestore.instance
              .collection('patients') // ✅ Hasta kayıtları burada aranmalı
              .where('patientCode', isEqualTo: patientCode)
              .limit(1)
              .get();

      if (patientQuery.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Geçersiz hasta bağlantı kodu.")),
        );
        return;
      }

      final patientDoc = patientQuery.docs.first;
      final patientId = patientDoc.id;

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final relativeUid = userCredential.user!.uid;

      await FirebaseFirestore.instance
          .collection('relatives')
          .doc(relativeUid)
          .set({
            'uid': relativeUid,
            'name': name,
            'surname': surname,
            'email': email,
            'phone': phone,
            'linkedPatient': patientId,
            'role': 'relative',
            'createdAt': Timestamp.now(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarıyla tamamlandı.")),
      );

      Navigator.pushReplacementNamed(context, '/loginEmail');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata oluştu: ${e.toString()}")));
    }
  }
}

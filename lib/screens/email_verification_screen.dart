import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final TextEditingController nameController;
  final TextEditingController surnameController;
  final TextEditingController phoneController;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final DateTime? selectedBirthDate;
  final String? selectedBloodType;
  final String? selectedGender;
  final List<String> selectedDiseases;

  const EmailVerificationScreen({
    super.key,
    required this.email,
    required this.nameController,
    required this.surnameController,
    required this.phoneController,
    required this.weightController,
    required this.heightController,
    required this.selectedBirthDate,
    required this.selectedBloodType,
    required this.selectedGender,
    required this.selectedDiseases,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _resendVerification() async {
    setState(() => _isResending = true);
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Doğrulama maili tekrar gönderildi!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    } finally {
      setState(() => _isResending = false);
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        await _saveToFirestore(user!.uid);
        setState(() => _isVerified = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Doğrulama başarılı!"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lütfen önce emailinizi doğrulayın"),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Doğrulama hatası: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveToFirestore(String uid) async {
    try {
      String generatePatientCode() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
        final rand = Random();
        return 'HT${List.generate(4, (index) => chars[rand.nextInt(chars.length)]).join()}';
      }

      String patientCode;
      bool codeExists;

      do {
        patientCode = generatePatientCode();
        final existing =
            await FirebaseFirestore.instance
                .collection('patients')
                .where('patientCode', isEqualTo: patientCode.toUpperCase())
                .get();
        codeExists = existing.docs.isNotEmpty;
      } while (codeExists);

      await FirebaseFirestore.instance.collection('patients').doc(uid).set({
        'uid': uid,
        'email': widget.email,
        'name': widget.nameController.text.trim(),
        'surname': widget.surnameController.text.trim(),
        'phone': '+90${widget.phoneController.text.trim()}',
        'weight': widget.weightController.text.trim(),
        'height': widget.heightController.text.trim(),
        'birthDate': widget.selectedBirthDate?.toIso8601String(),
        'bloodType': widget.selectedBloodType,
        'gender': widget.selectedGender,
        'diseases': widget.selectedDiseases,
        'patientCode': patientCode.toUpperCase(),
        'emailVerified': true,
        'createdAt': Timestamp.now(),
        'lastLogin': Timestamp.now(),
        'role': 'patient',
      });
    } on FirebaseException catch (e) {
      throw FirebaseException(
        plugin: 'firestore',
        code: e.code,
        message: 'Firestore kayıt hatası: ${e.message}',
      );
    } catch (e) {
      throw Exception('Beklenmeyen hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        // ⭐️ Tam ekran kaplama
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/arka_plan.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(borderRadius: BorderRadius.circular(24)),
                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Hesap Doğrulama",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Doğrulama linki şu adrese gönderildi:",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.email,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        if (_isVerified) ...[
                          const Icon(
                            Icons.verified,
                            color: Colors.green,
                            size: 50,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "Hesabınız Doğrulandı",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                context,
                                '/loginEmail',
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCDE7DA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                            ),
                            child: const Text(
                              "GİRİŞ EKRANINA DÖN",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else ...[
                          ElevatedButton(
                            onPressed: _isLoading ? null : _checkVerification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCDE7DA),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                    : const Text(
                                      "DOĞRULADIM",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed:
                                  _isResending ? null : _resendVerification,
                              child:
                                  _isResending
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : const Text(
                                        "Doğrulama Mailini Tekrar Gönder",
                                        style: TextStyle(
                                          fontSize: 19,
                                          color: Color.fromARGB(
                                            255,
                                            26,
                                            100,
                                            161,
                                          ),
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "• Eğer emaili bulamadıysanız spam klasörünü kontrol edin\n",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

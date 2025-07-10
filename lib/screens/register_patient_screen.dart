import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:kronik_hasta_takip/screens/email_verification_screen.dart';

class RegisterPatientScreen extends StatefulWidget {
  const RegisterPatientScreen({super.key});

  @override
  State<RegisterPatientScreen> createState() => _RegisterPatientScreenState();
}

class _RegisterPatientScreenState extends State<RegisterPatientScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  DateTime? selectedBirthDate;
  String? selectedBloodType;
  String? selectedGender;
  List<String> selectedDiseases = [];

  final List<String> diseaseList = [
    "KOAH",
    "Panik Atak",
    "Uyku apnesi ve Uyku Bozuklukları",
    "Diyabet",
    "Tansiyon",
    "Kalp",
    "Astım",
  ];

  bool _isValidEmail(String email) {
    return RegExp(
          r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
        ).hasMatch(email) &&
        !email.contains(' ') && // Boşluk kontrolü
        email
            .split('@')[1]
            .contains('.'); // @ sonrası nokta kontrolü (gmail.com gibi)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDFF3EC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
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
              const SizedBox(height: 10),
              const Text(
                'Kronik Hasta Takip',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'images/adsiz_tasarim_14.png',
                  width: 100,
                  height: 100,
                ),
              ),
              const SizedBox(height: 16),
              _buildUserTypeButtons(context),
              const SizedBox(height: 20),
              _buildTextFields(),
              _buildPhysicalInputs(),
              _buildDropdowns(),
              _buildDiseaseSelection(),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: _registerPatient,
                child: Image.asset('images/frame_60.png', width: 120),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButtons(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Hasta', style: TextStyle(color: Colors.white)),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed:
                  () => Navigator.pushNamed(context, '/registerRelative'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Hasta Yakını',
                style: TextStyle(color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        buildInputField(label: 'Ad', controller: nameController),
        buildInputField(label: 'Soyad', controller: surnameController),
        buildInputField(label: 'E-posta', controller: emailController),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Telefon Numarası',
              prefixText: '+90 ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        buildInputField(
          label: 'Şifre',
          controller: passwordController,
          obscureText: true,
        ),
        buildInputField(
          label: 'Şifre Tekrarı',
          controller: confirmPasswordController,
          obscureText: true,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime(2000),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  selectedBirthDate = picked;
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedBirthDate == null
                        ? 'Doğum Tarihi Seçiniz'
                        : '${selectedBirthDate!.day}.${selectedBirthDate!.month}.${selectedBirthDate!.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Icon(Icons.calendar_today, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildPhysicalInputs() {
    return Row(
      children: [
        Expanded(
          child: buildInputField(label: 'Kg', controller: weightController),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: buildInputField(label: 'cm', controller: heightController),
        ),
      ],
    );
  }

  Widget _buildDropdowns() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedBloodType,
            hint: const Text("Kan Grubu"),
            items:
                ["A+", "A-", "B+", "B-", "AB+", "AB-", "0+", "0-"]
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: Text(type)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => selectedBloodType = value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            hint: const Text("Cinsiyet"),
            items:
                ["Kadın", "Erkek"]
                    .map(
                      (gender) =>
                          DropdownMenuItem(value: gender, child: Text(gender)),
                    )
                    .toList(),
            onChanged: (value) => setState(() => selectedGender = value),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiseaseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        MultiSelectDialogField<String>(
          items: diseaseList.map((e) => MultiSelectItem<String>(e, e)).toList(),
          title: const Text("Hastalıklar"),
          buttonText: const Text("Hastalık Seç"),
          onConfirm: (values) {
            setState(() {
              selectedDiseases = List<String>.from(values);
            });
          },
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
        ),
      ],
    );
  }

  Future<void> _registerPatient() async {
    final name = nameController.text.trim();
    final surname = surnameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final weight = weightController.text.trim();
    final height = heightController.text.trim();

    // Validation checks
    if (name.isEmpty ||
        surname.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        weight.isEmpty ||
        height.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurunuz.")),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Geçerli bir email adresi girin!")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Şifreler uyuşmuyor!")));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre en az 6 karakter olmalı.")),
      );
      return;
    }

    if (selectedDiseases.isEmpty ||
        selectedBloodType == null ||
        selectedGender == null ||
        selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm bilgileri eksiksiz giriniz.")),
      );
      return;
    }

    try {
      // 1. Firebase Auth'da kullanıcı oluştur
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Doğrulama maili gönder
      await userCredential.user?.sendEmailVerification();

      // 3. Benzersiz hasta kodu üret
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

      // 4. Firestore'a hasta verilerini kaydet
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': name,
            'surname': surname,
            'email': email,
            'phone': '+90$phone',
            'weight': weight,
            'height': height,
            'gender': selectedGender,
            'bloodType': selectedBloodType,
            'diseases': selectedDiseases,
            'birthDate': selectedBirthDate?.toIso8601String(),
            'patientCode': patientCode.toUpperCase(),
            'role': 'patient',
            'emailVerified': false, // Doğrulama durumu
            'createdAt': Timestamp.now(),
          });

      // 5. Doğrulama sayfasına yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (context) => EmailVerificationScreen(
                email: email,
                nameController: nameController,
                surnameController: surnameController,
                phoneController: phoneController,
                weightController: weightController,
                heightController: heightController,
                selectedBirthDate: selectedBirthDate,
                selectedBloodType: selectedBloodType,
                selectedGender: selectedGender,
                selectedDiseases: selectedDiseases,
              ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Kayıt hatası: ";
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage += "Bu email zaten kullanımda";
          break;
        case 'invalid-email':
          errorMessage += "Geçersiz email adresi";
          break;
        case 'operation-not-allowed':
          errorMessage += "Email/şifre ile giriş kapalı";
          break;
        case 'weak-password':
          errorMessage += "Şifre en az 6 karakter olmalı";
          break;
        default:
          errorMessage += e.message ?? "Bilinmeyen hata";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Sistem hatası: ${e.toString()}")));
    }
  }
}

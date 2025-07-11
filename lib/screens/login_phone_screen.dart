import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPhoneScreen extends StatefulWidget {
  const LoginPhoneScreen({super.key});

  @override
  State<LoginPhoneScreen> createState() => _LoginPhoneScreenState();
}

class _LoginPhoneScreenState extends State<LoginPhoneScreen> {
  final TextEditingController phoneController = TextEditingController(
    text: "+90",
  );
  final TextEditingController passwordController = TextEditingController();
  bool obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  Future<void> loginWithPhone() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: phoneController.text.trim(),
            password: passwordController.text.trim(),
          );

      final user = userCredential.user;
      if (user == null) return;

      final patientDoc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(user.uid)
              .get();

      if (patientDoc.exists) {
        Navigator.pushReplacementNamed(context, '/patientHome');
      } else {
        final relativeDoc =
            await FirebaseFirestore.instance
                .collection('relatives')
                .doc(user.uid)
                .get();

        if (relativeDoc.exists) {
          Navigator.pushReplacementNamed(context, '/relativeHome');
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("Kullanıcı bulunamadı")));
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: ${e.message ?? "Bilinmeyen hata"}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("images/ana_sayfa_arkaplan.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: 130,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  left: 24,
                  right: 24,
                ),
                child: Column(
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          _buildAuthMethodTabs(),
                          const SizedBox(height: 20),
                          _buildPhoneField(),
                          const SizedBox(height: 15),
                          _buildPasswordField(),
                          const SizedBox(height: 20),
                          _buildLoginButton(),
                          const SizedBox(height: 10),
                          _buildForgotPasswordButton(),
                          const SizedBox(height: 15),
                          _buildRegisterButton(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthMethodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed:
                  () => Navigator.pushReplacementNamed(context, '/loginEmail'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
              ),
              child: const Text(
                'E-mail',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: Colors.black87,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
              ),
              child: const Text(
                'Telefon No',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: phoneController,
      keyboardType: TextInputType.phone,
      validator: (value) => value!.isEmpty ? 'Telefon numarası giriniz' : null,
      decoration: _inputDecoration('Telefon Numarası (+90)'),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      obscureText: obscurePassword,
      validator:
          (value) => value!.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
      decoration: _inputDecoration('Şifre').copyWith(
        suffixIcon: IconButton(
          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => obscurePassword = !obscurePassword),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loginWithPhone,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCDE7DA),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: const Text(
          'Giriş Yap',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.pushNamed(context, '/forgotPassword'),
        child: const Text(
          'Şifremi Unuttum',
          style: TextStyle(
            color: Colors.grey,
            decoration: TextDecoration.underline,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: () => Navigator.pushNamed(context, '/registerPatient'),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.2),
        side: const BorderSide(color: Colors.white, width: 2),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        'Hesabınız yok mu? Kayıt Olun',
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

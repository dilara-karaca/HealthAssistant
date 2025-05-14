import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class RelativeProfile extends StatefulWidget {
  @override
  _RelativeProfileState createState() => _RelativeProfileState();
}

class _RelativeProfileState extends State<RelativeProfile> {
  bool isEditing = false;
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc =
          await FirebaseFirestore.instance
              .collection('relatives')
              .doc(uid)
              .get();
      if (doc.exists) {
        final data = doc.data()!;
        nameController.text = "${data['name']} ${data['surname']}";
        phoneController.text = data['phone'] ?? '';
        emailController.text = data['email'] ?? '';
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Profil verileri alınamadı: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void enableEditing(FocusNode focusNode) {
    setState(() => isEditing = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  @override
  void dispose() {
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/arka_plan.png'),
            fit: BoxFit.cover,
          ),
        ),
        child:
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Column(
                      children: [
                        _buildEditableTile(
                          "Ad Soyad",
                          nameController,
                          nameFocus,
                        ),
                        _buildEditableTile(
                          "Telefon Numarası",
                          phoneController,
                          phoneFocus,
                        ),
                        _buildEditableTile(
                          "Email",
                          emailController,
                          emailFocus,
                        ),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  Future<void> saveSingleField(String label, String newValue) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      String field = "";
      String value = newValue.trim();

      if (label == "Ad Soyad") {
        final names = value.split(' ');
        final name = names.first;
        final surname = names.length > 1 ? names.sublist(1).join(' ') : '';
        await FirebaseFirestore.instance
            .collection('relatives')
            .doc(uid)
            .update({'name': name, 'surname': surname});
      } else if (label == "Telefon Numarası") {
        await FirebaseFirestore.instance
            .collection('relatives')
            .doc(uid)
            .update({'phone': value});
      } else if (label == "Email") {
        await FirebaseFirestore.instance
            .collection('relatives')
            .doc(uid)
            .update({'email': value});
      }

      setState(() => isEditing = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Değişiklik kaydedildi.')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata oluştu: $e')));
    }
  }

  Widget _buildEditableTile(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    final isPhoneField = label == "Telefon Numarası";
    final isEmailField = label == "Email";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: isEditing,
                  keyboardType:
                      isPhoneField
                          ? TextInputType.number
                          : isEmailField
                          ? TextInputType.emailAddress
                          : TextInputType.text,
                  inputFormatters:
                      isPhoneField
                          ? [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ]
                          : null,
                  decoration: InputDecoration.collapsed(
                    hintText: "",
                  ).copyWith(prefixText: isPhoneField ? '+90 ' : null),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => saveSingleField(label, controller.text),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => enableEditing(focusNode),
            child: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

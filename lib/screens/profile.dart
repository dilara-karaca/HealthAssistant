import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;

  final nameController = TextEditingController();
  final birthDateController = TextEditingController();
  final genderController = TextEditingController();
  final bloodGroupController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final diseaseController = TextEditingController();

  late Set<String> selectedDiseases = {};

  final allDiseases = [
    'Tansiyon',
    'Diyabet',
    'Astım',
    'Kalp',
    "KOAH",
    "Panik Atak",
    "Uyku Apnesi ve Uyku Bozuklukları",
  ];

  final FocusNode nameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode diseaseFocus = FocusNode();
  final FocusNode genderFocus = FocusNode();
  final FocusNode birthDateFocus = FocusNode();
  final FocusNode bloodGroupFocus = FocusNode();
  final FocusNode heightFocus = FocusNode();
  final FocusNode weightFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('patients').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        genderController.text = data['gender'] ?? '';
        birthDateController.text = data['birthDate'] ?? '';
        bloodGroupController.text = data['bloodType'] ?? '';
        heightController.text = data['height'] ?? '';
        weightController.text = data['weight'] ?? '';

        if (data['diseases'] != null && data['diseases'] is List) {
          selectedDiseases = Set<String>.from(data['diseases']);
          diseaseController.text = selectedDiseases.join('\n');
        }
      });
    }
  }

  void enableEditing(FocusNode focusNode) {
    setState(() => isEditing = true);
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(focusNode);
    });
  }

  void showDiseaseSelectionPanel() {
    Set<String> tempSelectedDiseases = Set.from(selectedDiseases);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Hastalıklar',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: allDiseases.length,
                          itemBuilder: (context, index) {
                            final disease = allDiseases[index];
                            return CheckboxListTile(
                              title: Text(
                                disease,
                                style: const TextStyle(fontSize: 18),
                              ),
                              value: tempSelectedDiseases.contains(disease),
                              onChanged: (value) {
                                setModalState(() {
                                  if (value == true) {
                                    tempSelectedDiseases.add(disease);
                                  } else {
                                    tempSelectedDiseases.remove(disease);
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDiseases = tempSelectedDiseases;
                            diseaseController.text = selectedDiseases.join(
                              '\n',
                            );
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Kaydet",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    nameFocus.dispose();
    phoneFocus.dispose();
    emailFocus.dispose();
    genderFocus.dispose();
    birthDateFocus.dispose();
    bloodGroupFocus.dispose();
    heightFocus.dispose();
    weightFocus.dispose();
    diseaseFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFEAF4F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildEditableTile("Ad-Soyad", nameController, nameFocus),
                _buildEditableTile(
                  "Telefon Numarası",
                  phoneController,
                  phoneFocus,
                ),
                _buildEditableTile("Email", emailController, emailFocus),
                _buildEditableTile("Cinsiyet", genderController, genderFocus),
                _buildEditableTile(
                  "Doğum Tarihi",
                  birthDateController,
                  birthDateFocus,
                ),
                _buildEditableTile(
                  "Kan Grubu",
                  bloodGroupController,
                  bloodGroupFocus,
                ),
                _buildEditableTile("Boy", heightController, heightFocus),
                _buildEditableTile("Kilo", weightController, weightFocus),
                _buildEditableTile(
                  "Kayıtlı Hastalıklar",
                  diseaseController,
                  diseaseFocus,
                  maxLines: 4,
                  onEdit: showDiseaseSelectionPanel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTile(
    String label,
    TextEditingController controller,
    FocusNode focusNode, {
    int maxLines = 1,
    VoidCallback? onEdit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  enabled: isEditing && onEdit == null,
                  maxLines: maxLines,
                  decoration: const InputDecoration.collapsed(hintText: ""),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit ?? () => enableEditing(focusNode),
            child: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}

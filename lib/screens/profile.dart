import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
      final name = data['name'] ?? '';
      final surname = data['surname'] ?? '';
      setState(() {
        nameController.text = '$name $surname';
        emailController.text = data['email'] ?? '';
        phoneController.text = data['phone'] ?? '';
        genderController.text = data['gender'] ?? '';
        bloodGroupController.text = data['bloodType'] ?? '';
        heightController.text = data['height'] ?? '';
        weightController.text = data['weight'] ?? '';
        if (data['diseases'] != null && data['diseases'] is List) {
          selectedDiseases = Set<String>.from(data['diseases']);
          diseaseController.text = selectedDiseases.join('\n');
          final rawBirthDate = data['birthDate'];
          if (rawBirthDate != null && rawBirthDate is String && rawBirthDate.contains('T')) {
            final parsedDate = DateTime.tryParse(rawBirthDate);
            if (parsedDate != null) {
              birthDateController.text = DateFormat('dd.MM.yyyy').format(parsedDate);
            } else {
              birthDateController.text = rawBirthDate;
            }
          } else {
            birthDateController.text = rawBirthDate ?? '';
          }

        }
      });
    }
  }

  Future<void> updateSingleField(String field, String value) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    if (field == 'name_surname') {
      final parts = value.trim().split(' ');
      final name = parts.first;
      final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      await FirebaseFirestore.instance.collection('patients').doc(uid).update({
        'name': name,
        'surname': surname,
      });
    } else {
      await FirebaseFirestore.instance.collection('patients').doc(uid).update({
        field: value,
      });
    }
  }

  void showEditableDialog({
    required String label,
    required TextEditingController controller,
    required String field,
  }) {
    final tempController = TextEditingController(text: controller.text);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(label),
            content: TextField(controller: tempController, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İptal"),
              ),
              TextButton(
                onPressed: () {
                  setState(() => controller.text = tempController.text);
                  if (field == 'name_surname') {
                    updateSingleField('name_surname', tempController.text);
                  } else {
                    updateSingleField(field, tempController.text);
                  }
                  Navigator.pop(context);
                },
                child: Text("Kaydet"),
              ),
            ],
          ),
    );
  }

  void showPhoneInputDialog() {
    final tempController = TextEditingController(text: phoneController.text);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Telefon Numarası"),
            content: TextField(
              controller: tempController,
              keyboardType: TextInputType.number,
              maxLength: 10,
              buildCounter:
                  (
                    _, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) => null,
              decoration: InputDecoration(
                prefixText: "+90 | ",
                hintText: "5xx xxx xx xx",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("İptal"),
              ),
              TextButton(
                onPressed: () {
                  if (tempController.text.length == 10) {
                    setState(() => phoneController.text = tempController.text);
                    updateSingleField('phone', tempController.text);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Lütfen 10 haneli bir numara girin."),
                      ),
                    );
                  }
                },
                child: Text("Kaydet"),
              ),
            ],
          ),
    );
  }

  void showGenderPicker() {
    String? selectedGender = genderController.text;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Cinsiyet Seçimi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  RadioListTile<String>(
                    title: const Text("Kadın"),
                    value: "Kadın",
                    groupValue: selectedGender,
                    onChanged:
                        (value) => setModalState(() => selectedGender = value),
                  ),
                  RadioListTile<String>(
                    title: const Text("Erkek"),
                    value: "Erkek",
                    groupValue: selectedGender,
                    onChanged:
                        (value) => setModalState(() => selectedGender = value),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedGender != null) {
                            setState(
                              () => genderController.text = selectedGender!,
                            );
                            updateSingleField('gender', selectedGender!);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Kaydet"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showDatePickerDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formatted = DateFormat('dd.MM.yyyy').format(picked);
      setState(() => birthDateController.text = formatted);
      updateSingleField('birthDate', formatted);
    }
  }

  void showBloodTypePicker() {
    final bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', '0+', '0-'];
    String? selectedBlood = bloodGroupController.text;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    "Kan Grubu Seçimi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ...bloodTypes.map(
                    (type) => RadioListTile<String>(
                      title: Text(type),
                      value: type,
                      groupValue: selectedBlood,
                      onChanged:
                          (value) => setModalState(() => selectedBlood = value),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (selectedBlood != null) {
                            setState(
                              () => bloodGroupController.text = selectedBlood!,
                            );
                            updateSingleField('bloodType', selectedBlood!);
                          }
                          Navigator.pop(context);
                        },
                        child: const Text("Kaydet"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showNumberPickerDialog({
    required TextEditingController controller,
    required int min,
    required int max,
    required String unit,
  }) {
    int selectedValue =
        int.tryParse(controller.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? min;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        FixedExtentScrollController scrollController =
            FixedExtentScrollController(initialItem: selectedValue - min);
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: 300,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Değer Seçimi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      controller: scrollController,
                      itemExtent: 50,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged:
                          (index) =>
                              setModalState(() => selectedValue = min + index),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder:
                            (context, index) => Center(
                              child: Text(
                                "${min + index} $unit",
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                        childCount: max - min + 1,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("İptal"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final selectedText = "$selectedValue $unit";
                          setState(() => controller.text = selectedText);
                          updateSingleField(
                            unit == "cm" ? 'height' : 'weight',
                            selectedText,
                          );
                          Navigator.pop(context);
                        },
                        child: const Text("Kaydet"),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
                          FirebaseFirestore.instance
                              .collection('patients')
                              .doc(FirebaseAuth.instance.currentUser!.uid)
                              .update({'diseases': selectedDiseases.toList()});
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Kaydet",
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildEditableTile(
                "Ad-Soyad",
                nameController,
                field: 'name_surname',
                onEdit:
                    () => showEditableDialog(
                      label: "Ad-Soyad",
                      controller: nameController,
                      field: 'name_surname',
                    ),
              ),
              _buildEditableTile(
                "Telefon Numarası",
                phoneController,
                onEdit: showPhoneInputDialog,
              ),
              _buildEditableTile(
                "Email",
                emailController,
                field: 'email',
                onEdit:
                    () => showEditableDialog(
                      label: "Email",
                      controller: emailController,
                      field: 'email',
                    ),
              ),
              _buildEditableTile(
                "Cinsiyet",
                genderController,
                onEdit: showGenderPicker,
              ),
              _buildEditableTile(
                "Doğum Tarihi",
                birthDateController,
                onEdit: showDatePickerDialog,
              ),
              _buildEditableTile(
                "Kan Grubu",
                bloodGroupController,
                onEdit: showBloodTypePicker,
              ),
              _buildEditableTile(
                "Boy",
                heightController,
                onEdit:
                    () => showNumberPickerDialog(
                      controller: heightController,
                      min: 120,
                      max: 220,
                      unit: "cm",
                    ),
              ),
              _buildEditableTile(
                "Kilo",
                weightController,
                onEdit:
                    () => showNumberPickerDialog(
                      controller: weightController,
                      min: 30,
                      max: 150,
                      unit: "kg",
                    ),
              ),
              _buildEditableTile(
                "Kayıtlı Hastalıklar",
                diseaseController,
                maxLines: 4,
                onEdit: showDiseaseSelectionPanel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableTile(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    VoidCallback? onEdit,
    String? field,
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
                  enabled: false,
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
          if (onEdit != null)
            GestureDetector(
              onTap: onEdit,
              child: Icon(Icons.edit, size: 20, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }
}

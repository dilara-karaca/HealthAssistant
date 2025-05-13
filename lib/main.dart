import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kronik_hasta_takip/screens/forgot_password_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Screens
import 'screens/login_email_screen.dart';
import 'screens/login_phone_screen.dart';
import 'screens/login_sms_screen.dart';
import 'screens/register_patient_screen.dart';
import 'screens/register_relative_screen.dart';
import 'screens/forgot_password_verify_screen.dart';
import 'screens/forgot_password_reset_screen.dart';
import 'screens/emergency.dart';
import 'screens/patients_home_page.dart';
import 'screens/patients_settings.dart';
import 'screens/patients_profile.dart';
import 'screens/patients_security.dart';
import 'screens/patients_help.dart';
import 'screens/home_page.dart'; // Hasta ekranı
import 'screens/settings.dart' as general_settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const KronikHastaTakipApp());
}

class KronikHastaTakipApp extends StatelessWidget {
  const KronikHastaTakipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kronik Hasta Takip',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFDFF3EC),
      ),
      initialRoute: '/loginEmail',
      routes: {
        '/loginEmail': (context) => const LoginEmailScreen(),
        '/loginPhone': (context) => const LoginPhoneScreen(),
        '/loginSms': (context) => const LoginSmsScreen(),
        '/registerPatient': (context) => const RegisterPatientScreen(),
        '/registerRelative': (context) => const RegisterRelativeScreen(),
        '/forgotPassword': (context) => const ForgotPasswordScreen(),
        '/forgotVerify': (context) => ForgotVerifyScreen(),
        '/resetPassword': (context) => const ForgotResetScreen(),
        '/home': (context) => const AltNavigasyon(),
        '/relativeHome': (context) => PatientHomePage(),
        '/patientsSettings': (context) => PatientsSettings(),
        '/patientsProfile': (context) => PatientsProfile(),
        '/patientsSecurity': (context) => const PatientsSecurity(),
        '/patientsHelp': (context) => const PatientsHelp(),
        '/redirectAfterLogin': (context) => const RedirectAfterLogin(),
      },
    );
  }
}

class RedirectAfterLogin extends StatelessWidget {
  const RedirectAfterLogin({super.key});

  Future<String?> getUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final patientsDoc =
          await FirebaseFirestore.instance
              .collection('patients')
              .doc(user.uid)
              .get();

      if (patientsDoc.exists) return 'patient';

      final relativesDoc =
          await FirebaseFirestore.instance
              .collection('relatives')
              .doc(user.uid)
              .get();

      if (relativesDoc.exists) return relativesDoc.data()?['role'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          final role = snapshot.data;
          if (role == 'patient') {
            Future.microtask(
              () => Navigator.pushReplacementNamed(context, '/home'),
            );
          } else if (role == 'relative') {
            Future.microtask(
              () => Navigator.pushReplacementNamed(context, '/relativeHome'),
            );
          } else {
            return const Scaffold(
              body: Center(child: Text('Geçersiz kullanıcı rolü.')),
            );
          }
        } else {
          return const Scaffold(
            body: Center(
              child: Text('Giriş başarısız veya kullanıcı verisi yok.'),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class AltNavigasyon extends StatefulWidget {
  const AltNavigasyon({super.key});

  @override
  State<AltNavigasyon> createState() => _AltNavigasyonState();
}

class _AltNavigasyonState extends State<AltNavigasyon> {
  int _seciliIndex = 0;

  final List<Widget> _sayfalar = [
    const HomePage(),
    general_settings.Settings(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _sayfalar[_seciliIndex],
      floatingActionButton: SizedBox(
        width: 80,
        height: 80,
        child: FloatingActionButton(
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          child: const Text(
            "ACİL",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Emergency()),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFF18202B),
        shape: const CircularNotchedRectangle(),
        notchMargin: 6,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _seciliIndex == 0 ? Colors.white : Colors.grey,
                  size: 45,
                ),
                onPressed: () => setState(() => _seciliIndex = 0),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.settings,
                  color: _seciliIndex == 1 ? Colors.red : Colors.white,
                  size: 45,
                ),
                onPressed: () => setState(() => _seciliIndex = 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

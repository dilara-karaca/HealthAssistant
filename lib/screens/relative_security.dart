import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'reset_password.dart';
import 'delete_account.dart';

class RelativeSecurity extends StatefulWidget {
  const RelativeSecurity({Key? key}) : super(key: key);

  @override
  State<RelativeSecurity> createState() => _RelativeSecurityState();
}

class _RelativeSecurityState extends State<RelativeSecurity> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset('images/arka_plan.png', fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Güvenlik'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: Colors.white.withOpacity(0.85),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.lock_reset,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Şifre Yenile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ResetPasswordPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: Colors.white.withOpacity(0.85),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: const Text(
                    'Hesabı Kapat',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DeleteAccountPage()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

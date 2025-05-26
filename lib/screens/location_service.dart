import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Konum iznini iste ve geçerli konumu döndür
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are denied.');
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  /// Hastanın konumunu Firestore'a yaz
  Future<void> updatePatientLocation() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      final position = await getCurrentLocation();

      await _firestore.collection('patients').doc(uid).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': Timestamp.now(),
        }
      });
    } catch (e) {
      print('Location update error: $e');
    }
  }

  /// Sürekli olarak (örneğin 30 saniyede bir) konum güncelle
  Timer? _timer;
  void startPeriodicLocationUpdates() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      updatePatientLocation();
    });
  }

  void stopPeriodicLocationUpdates() {
    _timer?.cancel();
  }
}

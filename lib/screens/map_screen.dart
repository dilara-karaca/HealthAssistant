import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? patientLocation;
  LatLng? relativeLocation;
  late GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Hasta yakınının konumu
      Position relativePos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      relativeLocation = LatLng(relativePos.latitude, relativePos.longitude);

      // Hasta ID'sini öğren
      DocumentSnapshot relativeDoc = await FirebaseFirestore.instance
          .collection('relatives')
          .doc(uid)
          .get();

      final linkedPatientId = relativeDoc['linkedPatient'];

      // Hastanın konumunu Firestore'dan çek
      DocumentSnapshot patientDoc = await FirebaseFirestore.instance
          .collection('patients')
          .doc(linkedPatientId)
          .get();

      Map<String, dynamic> location = patientDoc['location'];
      patientLocation = LatLng(location['latitude'], location['longitude']);

      setState(() {});
    } catch (e) {
      print("Konumlar alınamadı: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (patientLocation == null || relativeLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Konumlar Yükleniyor")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('patient'),
        position: patientLocation!,
        infoWindow: const InfoWindow(title: "Hasta"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
      Marker(
        markerId: const MarkerId('relative'),
        position: relativeLocation!,
        infoWindow: const InfoWindow(title: "Siz"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: const Text("Haritada Konumlar")),
      body: GoogleMap(
        onMapCreated: (controller) {
          _mapController = controller;
        },
        initialCameraPosition: CameraPosition(
          target: patientLocation!,
          zoom: 14,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

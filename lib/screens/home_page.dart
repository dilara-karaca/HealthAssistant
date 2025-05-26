import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_bot.dart';
import 'dart:async';
import 'package:kronik_hasta_takip/screens/bluetooth_manager.dart';
import 'location_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final LocationService _locationService = LocationService();
  final BluetoothManager _bluetoothManager = BluetoothManager();
  StreamSubscription<String>? dataSubscription;
  Timer? refreshTimer;

  Map<String, String> sensorData = {
    'BPM': '-',
    'TEMP': '-',
    'SPO2': '-',
    'STRESS': '-',
    'BP': '-',
    'STEPS': '-',
  };
  String lastRawData = "-";

  bool showPatientCode = false;
  Map<String, dynamic>? userData;

  double? currentBpm;
  List<double> bpmList = [];
  Timer? bpmTimer;

  double? currentTemp;
  List<double> TempList = [];
  Timer? TempTimer;

  double _botTop = 600;
  double _botLeft = 20;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    _locationService.startPeriodicLocationUpdates();
    listenToBluetoothData();
    setupPeriodicRefresh();
    BluetoothManager().dataStream.listen((data) {
      _handleBluetoothData(data);
    });

    bpmTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      setState(() {});
    });
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc =
        await FirebaseFirestore.instance.collection('patients').doc(uid).get();
    if (doc.exists) {
      setState(() {
        userData = doc.data();
      });
    }
  }

  @override
  void dispose() {
    _locationService.stopPeriodicLocationUpdates();
    dataSubscription?.cancel();
    refreshTimer?.cancel();
    bpmTimer?.cancel();
    super.dispose();
  }

  void _handleBluetoothData(String data) {
    List<String> parts = data.split('|');
    double? temp;
    double? bpm;

    for (var part in parts) {
      if (part.startsWith("TEMP:")) {
        String val = part.substring(5);
        temp = double.tryParse(val);
      } else if (part.startsWith("BPM:")) {
        String val = part.substring(4);
        bpm = double.tryParse(val);
      }
    }

    setState(() {
      currentTemp = (temp == null || temp <= 0) ? null : temp;
      currentBpm = (bpm == null || bpm <= 0) ? null : bpm;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFEAF4F4),
      body:
          userData == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  Container(
                    height: screenHeight,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("images/arka_plan.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.015,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const CircleAvatar(
                                        radius: 24,
                                        backgroundImage: AssetImage(
                                          'images/person.png',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        userData?['name'] ?? '...',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.055,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.03,
                                      vertical: screenHeight * 0.008,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          showPatientCode
                                              ? (userData?['patientCode'] ??
                                                  'Kod yok')
                                              : "Hasta Kodu",
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.048,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showPatientCode =
                                                  !showPatientCode;
                                            });
                                          },
                                          child: Icon(
                                            showPatientCode
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            size: screenWidth * 0.05,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            SizedBox(
                              height: screenHeight * 0.3,
                              child: PageView(
                                children: [
                                  _buildHeartCard(screenWidth),
                                  _buildHeartGraphCard(
                                    screenHeight,
                                    screenWidth,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.02),
                            SizedBox(
                              height: screenHeight * 0.3,
                              child: PageView(
                                children: [
                                  _buildPressureCard(screenWidth),
                                  _buildPressureGraphCard(screenWidth),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.025),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                              ),
                              child: Column(
                                children: [
                                  _buildBottomCard(
                                    "Adım Sayısı",
                                    "images/ayak.png",
                                    "1200 Adım",
                                    screenWidth,
                                  ),
                                  _buildBottomCard(
                                    "Kan Oksijen Seviyesi",
                                    "images/kan.png",
                                    "96%",
                                    screenWidth,
                                  ),
                                  _buildBottomCard(
                                    "Stres Seviyesi",
                                    "images/stressed.png",
                                    "Düşük",
                                    screenWidth,
                                  ),
                                  _buildBottomCard(
                                    "Vücut Isısı",
                                    "images/temp.png",
                                    currentTemp != null
                                        ? "${currentTemp!.toStringAsFixed(1)}°C"
                                        : "-",
                                    screenWidth,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.03),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    top: _botTop,
                    left: _botLeft,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        setState(() {
                          _botTop += details.delta.dy;
                          _botLeft += details.delta.dx;
                        });
                      },
                      onPanEnd: (_) {
                        final screenWidth = MediaQuery.of(context).size.width;
                        setState(() {
                          _botLeft =
                              _botLeft > screenWidth / 2
                                  ? screenWidth - 70
                                  : 10;
                        });
                      },
                      child: _buildChatBotButton(screenWidth),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildHeartCard(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "bpm",
              style: TextStyle(
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  currentBpm != null ? currentBpm!.toStringAsFixed(0) : "-",
                  style: TextStyle(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Image.asset("images/kalp.png", height: screenWidth * 0.12),
              ],
            ),
            const SizedBox(height: 16),
            // 📊 Çubuk + iğne
            Stack(
              children: [
                // Renkli çubuk her zaman görünür
                Container(
                  height: 18,
                  width: screenWidth - 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.orange,
                        Colors.red,
                      ],
                    ),
                  ),
                ),
                // İğne sadece veri varsa görünür
                if (currentBpm != null)
                  Positioned(
                    left:
                        ((currentBpm!.clamp(50, 150) - 50) / 100) *
                        (screenWidth - 64),
                    top: 3,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            if (currentBpm != null)
              Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Yavaş",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Normal",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Hızlı",
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeartGraphCard(double screenHeight, double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        height: screenHeight * 0.28,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Kalp Ritmi Grafiği",
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 65),
            bpmList.isEmpty
                ? Center(
                  child: Text(
                    "Grafik görüntülenemiyor.\nLütfen cihazınızı bağlayın.",
                    style: TextStyle(
                      fontSize: screenWidth * 0.055,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                )
                : SizedBox(
                  height: screenHeight * 0.18,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots:
                              bpmList
                                  .asMap()
                                  .entries
                                  .map(
                                    (e) => FlSpot(
                                      e.key.toDouble() *
                                          (60 /
                                              bpmList.length), // Zaman aralığı
                                      e.value,
                                    ),
                                  )
                                  .toList(),
                          isCurved: true,
                          color: Colors.red,
                          barWidth: 2,
                          dotData: FlDotData(show: false),
                        ),
                      ],
                      titlesData: FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureCard(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset("images/tansiyon.png", width: 65, height: 65),
                const SizedBox(width: 8),
                Text(
                  "Tansiyon",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Büyük Tansiyon",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "126",
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 70,
                  child: VerticalDivider(
                    color: const Color.fromARGB(255, 134, 130, 130),
                    thickness: 3,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Küçük Tansiyon",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "96",
                      style: TextStyle(
                        fontSize: screenWidth * 0.08,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPressureGraphCard(double screenWidth) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "1 Mayıs 2025",
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      "Büyük Tansiyon",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Max   Min"),
                    const SizedBox(height: 8),
                    Text(
                      "142   109",
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                  child: VerticalDivider(
                    color: const Color.fromARGB(255, 134, 130, 130),
                    thickness: 3,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      "Küçük Tansiyon",
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Max   Min"),
                    const SizedBox(height: 8),
                    Text(
                      "98   68",
                      style: TextStyle(
                        fontSize: screenWidth * 0.065,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCard(
    String title,
    String imagePath,
    String value,
    double screenWidth,
  ) {
    return Container(
      height: 85,
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBotButton(double screenWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatBotScreen()),
        );
      },
      child: Container(
        width: screenWidth * 0.18,
        height: screenWidth * 0.18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            'images/chat_bot.png',
            width: screenWidth * 0.2,
            height: screenWidth * 0.2,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }

  void listenToBluetoothData() {
    dataSubscription = _bluetoothManager.dataStream.listen((data) {
      lastRawData = data;
    });
  }

  void setupPeriodicRefresh() {
    refreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      Map<String, String> parsed = parseSensorData(lastRawData);
      setState(() {
        sensorData = parsed;
        lastRawData = "-";
      });
    });
  }

  Map<String, String> parseSensorData(String rawData) {
    Map<String, String> parsedData = {
      'BPM': '-',
      'TEMP': '-',
      'SPO2': '-',
      'STRESS': '-',
      'BP': '-',
      'STEPS': '-',
    };

    if (rawData == "-" || rawData.isEmpty) return parsedData;

    List<String> parts = rawData.split("|");
    for (var part in parts) {
      var keyValue = part.split(":");
      if (keyValue.length == 2) {
        parsedData[keyValue[0].trim()] = keyValue[1].trim();
      }
    }

    return parsedData;
  }
}

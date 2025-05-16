import 'package:flutter/material.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> messages = [
    {"text": "Merhaba, size nasıl yardımcı olabilirim?", "isBot": true},
    {"text": "Bugünkü tansiyon değerlerim normal mi?", "isBot": false},
    {
      "text": "Tansiyonunuz ideal aralıkta. Günlük ölçümlere devam edin.",
      "isBot": true,
    },
  ];

  final List<String> quickQuestions = [
    "Kalp ritmim normal mi?",
    "Bugünkü adım sayımım yeterli mi?",
    "Bugünkü tansiyonum iyi mi?",
  ];

  void _sendMessage([String? text]) {
    final message = text ?? _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      messages.add({"text": message, "isBot": false});
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        messages.add({"text": "Lütfen bekleyiniz.", "isBot": true});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F4F6),
      appBar: AppBar(
        title: const Text("Sağlık Asistanı"),
        backgroundColor: const Color.fromARGB(255, 239, 253, 251),
      ),
      body: Stack(
        children: [
          // Arka Plan
          Positioned.fill(
            child: Image.asset('images/arka_plan.png', fit: BoxFit.cover),
          ),
          // İçerik
          Column(
            children: [
              // Mesajlar
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return Align(
                      alignment:
                          msg['isBot']
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                      child: ChatBubble(
                        message: msg['text'],
                        isBot: msg['isBot'],
                      ),
                    );
                  },
                ),
              ),

              // Hızlı Sorular
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children:
                      quickQuestions.map((question) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
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
                          child: ListTile(
                            title: Text(
                              question,
                              style: const TextStyle(fontSize: 18),
                            ),
                            onTap: () => _sendMessage(question),
                            trailing: const Icon(
                              Icons.send,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),

              // Mesaj Yazma Alanı
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: "Ne sormak istersiniz?",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 5, 153, 138),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          onPressed: () => _sendMessage(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isBot;

  const ChatBubble({super.key, required this.message, required this.isBot});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: isBot ? Colors.white : const Color.fromARGB(255, 5, 153, 138),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(isBot ? 0 : 16),
          bottomRight: Radius.circular(isBot ? 16 : 0),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isBot ? Colors.black : Colors.white,
          fontSize: 18,
        ),
      ),
    );
  }
}

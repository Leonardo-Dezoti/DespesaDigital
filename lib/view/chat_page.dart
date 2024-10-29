import 'package:flutter/material.dart';
import 'package:despesa_digital/controller/gemini_serviceChat.dart';  // Certifique-se de que o caminho está correto

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, String>> _messages = [];  // Lista de mensagens com remetente e conteúdo
  final GeminiServiceChat _geminiServiceChat = GeminiServiceChat();  // Instância do GeminiServiceChat

  // Função para enviar a mensagem e obter resposta da IA
  void _sendMessage(String message) async {
    setState(() {
      _messages.add({"sender": "Você", "message": message});
    });

    // Chama o serviço para obter a resposta da IA
    String response = await _geminiServiceChat.handleFinanceQuestion(message);

    setState(() {
      _messages.add({"sender": "IA", "message": response});
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat sobre Finanças",
          style: TextStyle(color: Colors.white),  // Cor branca para o texto do título
        ),
        backgroundColor: Colors.purple[800],  // Alterado para um tom de roxo
      ),
      body: Container(
        color: Colors.grey[250],  // Fundo cinza claro
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    bool isUserMessage = message['sender'] == "Você";

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Align(
                        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUserMessage ? Colors.purple[300] : Colors.purple[400],  // Alterado para tons de roxo
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.all(12),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Text(
                            "${message['message']}",
                            style: TextStyle(
                              color: isUserMessage ? Colors.white : Colors.white,  // Melhor contraste para o usuário e IA
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Digite sua pergunta sobre finanças...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Colors.purple[800]),  // Botão de envio roxo
                    onPressed: () {
                      if (_controller.text.isNotEmpty) {
                        _sendMessage(_controller.text);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

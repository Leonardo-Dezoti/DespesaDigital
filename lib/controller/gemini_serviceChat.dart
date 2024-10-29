import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiServiceChat {
  final GenerativeModel _model = GenerativeModel(
    model: 'gemini-1.5-flash-latest', // Atualize para o modelo correto se necessário
    apiKey: 'AIzaSyCU40NL8BLy7pQmL5iBpK_wRCrOUM5ZjDY', // Substitua pela sua chave de API
  );

  Future<String> handleFinanceQuestion(String text) async {
    try {
      final content = [
        Content.text(
            "Responda a seguinte pergunta sobre finanças de forma simples e direta e quando não for uma pergunta sobre finanças informar a mensagem 'Essa pergunta não é sobre finanças': $text"
        )
      ];
      final response = await _model.generateContent(content);

      if (response.candidates.isNotEmpty) {
        String? generatedText = response.candidates.first.text;
        if (generatedText != null && generatedText.isNotEmpty) {
          return generatedText;
        }
      }
      return 'Não foi possível gerar uma resposta para sua pergunta.';
    } catch (e) {
      print('Erro ao processar a pergunta: $e');
      return 'Erro ao tentar processar sua pergunta.';
    }
  }
}

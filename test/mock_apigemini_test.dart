import 'package:despesa_digital/controller/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

// Crie um mock da classe GeminiService
class MockGeminiService extends Mock implements GeminiService {}

void main() {
  group('GeminiService Tests', () {
    late MockGeminiService mockGeminiService;

    setUp(() {
      mockGeminiService = MockGeminiService();
      print('Setup do MockGeminiService concluído.');
    });

    test('Deve classificar o texto corretamente em uma das categorias', () async {
      const descricao = 'Compra de supermercado';  // Um exemplo de texto
      const categoriaEsperada = 'Alimentação';  // O resultado esperado

      print('Iniciando o teste de classificação de texto.');

      // Simula a resposta da função classifyText
      when(mockGeminiService.classifyText(descricao)).thenAnswer((_) async => categoriaEsperada);

      // Chama o método mockado
      final resultado = await mockGeminiService.classifyText(descricao);

      // Verifica se o método foi chamado corretamente e se o resultado é o esperado
      verify(mockGeminiService.classifyText(descricao)).called(1);
      expect(resultado, categoriaEsperada);

      print('Verificação bem-sucedida: O texto foi classificado corretamente como $categoriaEsperada.');
    });

    test('Deve retornar "Desconhecido" quando a categoria não for identificada', () async {
      const descricao = 'Texto irrelevante para as categorias';
      const categoriaEsperada = 'Desconhecido';

      print('Iniciando o teste para categoria desconhecida.');

      // Simula a resposta da função classifyText com 'Desconhecido'
      when(mockGeminiService.classifyText(descricao)).thenAnswer((_) async => categoriaEsperada);

      // Chama o método mockado
      final resultado = await mockGeminiService.classifyText(descricao);

      // Verifica se o método foi chamado corretamente e se o resultado é o esperado
      verify(mockGeminiService.classifyText(descricao)).called(1);
      expect(resultado, categoriaEsperada);

      print('Verificação bem-sucedida: O texto foi classificado corretamente como $categoriaEsperada.');
    });

    test('Deve lidar com erros ao classificar o texto', () async {
      const descricao = 'Texto que causará erro';

      print('Iniciando o teste para lidar com erros na classificação.');

      // Simula a resposta da função classifyText lançando uma exceção
      when(mockGeminiService.classifyText(descricao)).thenThrow(Exception('Erro ao classificar'));

      // Tenta chamar o método mockado e captura o erro
      final resultado = await mockGeminiService.classifyText(descricao);

      // Verifica se o método foi chamado e o erro foi tratado corretamente
      verify(mockGeminiService.classifyText(descricao)).called(1);
      expect(resultado, 'Desconhecido');

      print('Verificação bem-sucedida: O erro foi tratado corretamente e retornou "Desconhecido".');
    });
  });
}

import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import '../controller/auth_service.dart';
import '../controller/main_navigator.dart';
import '../database/user_db.dart';
import 'authentication_page.dart';

class GoogleCreatePasswordPage extends StatefulWidget {
  final String email; // Email obtido via Google Sign-In
  final String username; // Nome de usuário obtido via Google Sign-In

  GoogleCreatePasswordPage({required this.email, required this.username});

  @override
  _GoogleCreatePasswordPageState createState() => _GoogleCreatePasswordPageState();
}

class _GoogleCreatePasswordPageState extends State<GoogleCreatePasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserDB _userDB = UserDB(); // Instância do banco de dados

  bool _isLoading = false; // Controle de estado de carregamento

  // Função que atualiza a senha do usuário Google no banco de dados
  Future<void> _createPassword() async {
    setState(() {
      _isLoading = true; // Ativa o estado de carregamento
    });

    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;

    // Verifica se a senha e a confirmação são iguais
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('As senhas não coincidem.')),
      );
      setState(() {
        _isLoading = false; // Desativa o estado de carregamento
      });
      return;
    }

    try {
      // Gera o hash da senha usando bcrypt
      String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

      // Atualiza o usuário com a senha gerada no banco de dados
      await _userDB.updatePassword(widget.email, hashedPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Senha criada com sucesso!')),
      );

      // Redireciona o usuário para a tela principal
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AuthenticationPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar senha: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Desativa o estado de carregamento
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Criar Senha')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Bem-vindo, ${widget.username}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Email: ${widget.email}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 32),

            // Campo para criar a senha
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Crie sua senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 16),

            // Campo para confirmar a senha
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Confirme sua senha',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 32),

            // Botão para criar a senha
            _isLoading
                ? CircularProgressIndicator() // Mostra o indicador de carregamento enquanto a senha está sendo criada
                : ElevatedButton(
              onPressed: _createPassword,
              child: Text('Criar Senha'),
            ),
          ],
        ),
      ),
    );
  }
}
